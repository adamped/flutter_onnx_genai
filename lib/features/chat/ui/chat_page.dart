import 'package:flutter/material.dart';
import 'package:flutter_onnx_genai/features/chat/ui/conversation.dart';
import 'package:flutter_onnx_genai/features/chat/ui/conversation_list.dart';
import 'package:flutter_onnx_genai/shared/widgets/adaptive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AdaptiveLayout(
        leftPanel: Container(
            color: Theme.of(context).canvasColor,
            child: const ConversationList()),
        rightPanel: Container(
            color: Theme.of(context).cardColor, child: const Conversation()),
      ),
    );
  }
}
