import 'dart:ffi';
import 'package:onnx_genai/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'llm_service.g.dart';

class LLMService {
  final Model model;
  final Tokenizer tokenizer;
  final TokenizerStream tokenizerStream;

  LLMService(this.model, this.tokenizer, this.tokenizerStream);

  String inference(String text) {
    var prompt = '<|user|>\n$text <|end|>\n<|assistant|>';

    var tokens = tokenizer.encode(prompt);

    var params = GeneratorParams.create(model.genai, model.handle);

    params.setInputIds(tokens);

    var generator = Generator.create(model.genai, model.handle, params.handle);

    var output = '';

    while (!generator.isDone()) {
      generator.computeLogits();
      generator.generateNextToken();
      var newToken = generator.getSequence(0).last;

      output += tokenizerStream.decode(newToken);
    }

    return output;
  }
}

@Riverpod(keepAlive: true)
Future<LLMService> llmService(LlmServiceRef ref) async {
  // Need to add this to ensure that the linked .so works
  DynamicLibrary.open('assets/libonnxruntime.so.1.18.0');
  var genaiLib = DynamicLibrary.open('assets/libonnxruntime-genai.so');

  var model = Model.create('assets/phi-3-mini', genaiLib);

  var tokenizer = Tokenizer.create(model.genai, model.handle);

  var tokenizerStream = tokenizer.createStream();

  return LLMService(model, tokenizer, tokenizerStream);
}
