import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_onnx_genai/features/chat/data/message_list_provider.dart';
import 'package:flutter_onnx_genai/features/chat/domain/message.dart';
import 'package:flutter_onnx_genai/features/chat/ui/message_bubble.dart';
import 'package:flutter_onnx_genai/shared/services/llm_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageCountProvider =
    StateNotifierProvider<MessageCountNotifier, int>((ref) {
  return MessageCountNotifier();
});

class MessageCountNotifier extends StateNotifier<int> {
  MessageCountNotifier() : super(0);

  int getNextId() {
    state++;
    return state;
  }
}

Future<void> inference(WidgetRef ref, String message) async {
  ref.watch(messageListProvider.notifier).addMessage(Message(
      isMe: true,
      text: message,
      timestamp: DateTime.now(),
      messageId: ref.watch(messageCountProvider.notifier).getNextId()));

  var response = ref.watch(llmServiceProvider).value!.inference(message);

  var id = ref.watch(messageCountProvider.notifier).getNextId();

  await for (var char in response) {
    if (char == endOfText) {
      continue;
    }
    ref.watch(messageListProvider.notifier).streamMessage(id, char);
  }
}

final isProcessingProvider =
    StateNotifierProvider<IsProcessingNotifier, bool>((ref) {
  return IsProcessingNotifier();
});

class IsProcessingNotifier extends StateNotifier<bool> {
  IsProcessingNotifier() : super(false);

  void setIsProcessing(bool value) {
    state = value;
  }
}

class Conversation extends ConsumerWidget {
  const Conversation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messageListProvider);
    final TextEditingController textController = TextEditingController();
    return Column(
      children: [
        Container(
          color: const Color(0xFFe1e7ed),
          height: 70,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('Phi 3 Mini Instruct 4k',
                    style: Theme.of(context).textTheme.headlineSmall)
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView.separated(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: messages[index]);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 16,
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 70,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attachment),
                onPressed: () {},
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Type your message',
                    border: InputBorder.none,
                  ),
                  controller: textController,
                ),
              ),
              ref.watch(isProcessingProvider)
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        var message = textController.text;
                        textController.clear();
                        ref
                            .watch(isProcessingProvider.notifier)
                            .setIsProcessing(true);
                        await inference(ref, message);
                        ref
                            .watch(isProcessingProvider.notifier)
                            .setIsProcessing(false);
                      },
                      child: const Icon(Icons.send),
                    )
            ],
          ),
        ),
      ],
    );
  }
}
