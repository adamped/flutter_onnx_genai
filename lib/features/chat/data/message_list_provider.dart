import 'package:flutter_onnx_genai/features/chat/domain/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageListProvider =
    StateNotifierProvider<MessageListNotifier, List<Message>>((ref) {
  return MessageListNotifier();
});

class MessageListNotifier extends StateNotifier<List<Message>> {
  MessageListNotifier() : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }
}
