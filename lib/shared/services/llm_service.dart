import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:onnx_genai/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart';

part 'llm_service.g.dart';

const String endOfText = '\u0003'; // End of Text

void isolateEntryPoint(IsolateMessage message) async {
  final receivePort = ReceivePort();
  message.sendPort.send(receivePort.sendPort);

  var llmService = await load(message.token);

  receivePort.listen((dynamic msg) async {
    if (msg is InferenceMessage) {
      llmService.inferenceStream(msg.text).listen((data) {
        msg.reply.send(data);
      });
    }
  });
}

class InferenceMessage {
  final SendPort reply;
  final String text;
  const InferenceMessage(this.reply, this.text);
}

class IsolateMessage {
  final SendPort sendPort;
  final RootIsolateToken token;
  const IsolateMessage(this.sendPort, this.token);
}

class IsolateManager {
  SendPort? _sendPort;
  Isolate? _isolate;

  Future<void> init() async {
    final token = RootIsolateToken.instance!;

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      isolateEntryPoint,
      IsolateMessage(receivePort.sendPort, token),
      onError: receivePort.sendPort,
    );

    final sendPort = await receivePort.first as SendPort;
    _sendPort = sendPort;
  }

  void close() {
    _isolate?.kill(priority: Isolate.immediate);
  }

  Stream<String> inference(String message) async* {
    final response = ReceivePort();
    final controller = StreamController<String>();
    _sendPort!.send(InferenceMessage(response.sendPort, message));

    response.listen((data) async {
      controller.sink.add(data);
      if (data == endOfText) {
        await controller.close();
      }
    });

    yield* controller.stream;
  }
}

class LLMService {
  final IsolateManager manager;

  const LLMService(this.manager);

  Stream<String> inference(String text) {
    return manager.inference(text);
  }
}

class LLMIsolate {
  final Model model;
  final Tokenizer tokenizer;
  final TokenizerStream tokenizerStream;

  LLMIsolate(this.model, this.tokenizer, this.tokenizerStream);

  Stream<String> inferenceStream(String text) async* {
    var prompt = '<|user|>\n$text <|end|>\n<|assistant|>';

    var tokens = tokenizer.encode(prompt);

    var params = GeneratorParams.create(model.genai, model.handle);

    params.setInputIds(tokens);

    var generator = Generator.create(model.genai, model.handle, params.handle);

    while (!generator.isDone()) {
      generator.computeLogits();
      generator.generateNextToken();
      var newToken = generator.getSequence(0).last;

      yield tokenizerStream.decode(newToken);
    }

    yield endOfText;
  }
}

Future<LLMIsolate> load(RootIsolateToken token) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  DynamicLibrary.open('libonnxruntime.so.1.18.0');
  var genaiLib = DynamicLibrary.open('libonnxruntime-genai.so');
  final assetCacheDirectory = await getApplicationSupportDirectory();
  final path = join(assetCacheDirectory.path, 'phi-3-mini/');
  var model = Model.create(path, genaiLib);

  var tokenizer = Tokenizer.create(model.genai, model.handle);

  var tokenizerStream = tokenizer.createStream();

  return LLMIsolate(model, tokenizer, tokenizerStream);
}

@Riverpod(keepAlive: true)
Future<LLMService> llmService(LlmServiceRef ref) async {
  await copyAssetsToDirectory('phi-3-mini');

  var isolateManager = IsolateManager();
  await isolateManager.init();

  return LLMService(isolateManager);
}

copyAssetsToDirectory(String assetsFolder) async {
  final appDocumentsDirectory = await getApplicationSupportDirectory();
  final targetPath = '${appDocumentsDirectory.path}/$assetsFolder';

  final directory = Directory(targetPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  // List all files in the assets folder
  var assets = await rootBundle.loadString('AssetManifest.json');
  Map json = jsonDecode(assets);

  // Copy each file
  for (final fileName in json.keys) {
    if (!fileName.toString().startsWith('assets/$assetsFolder/')) {
      continue;
    }
    final bytes = await rootBundle.load(fileName);
    var destFileName =
        fileName.toString().replaceAll("assets/$assetsFolder/", "");
    final filePath = '$targetPath/$destFileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes.buffer.asUint8List());
  }
}
