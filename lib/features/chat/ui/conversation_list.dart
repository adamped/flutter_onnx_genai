import 'package:flutter/material.dart';
import 'package:flutter_onnx_genai/features/chat/data/user_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationList extends ConsumerWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userListProvider);

    return Column(
      children: [
        SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('Conversations',
                    style: Theme.of(context).primaryTextTheme.headlineSmall)
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                ),
                title: Text(users[index].name,
                    style: Theme.of(context).primaryTextTheme.labelMedium),
              );
            },
          ),
        ),
        const SizedBox(
          height: 70,
          child: Text(''),
        ),
      ],
    );
  }
}
