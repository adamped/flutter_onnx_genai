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

  void streamMessage(int id, String word) {
    if (!state.any((element) => element.messageId == id)) {
      addMessage(Message(
          isMe: false, messageId: id, text: '', timestamp: DateTime.now()));
    }

    var message = state.firstWhere((element) => element.messageId == id);

    var updatedMessage = Message(
        text: message.text + word,
        timestamp: message.timestamp,
        isMe: message.isMe,
        messageId: id);

    state.removeWhere((element) => element.messageId == id);

    addMessage(updatedMessage);
  }
}
