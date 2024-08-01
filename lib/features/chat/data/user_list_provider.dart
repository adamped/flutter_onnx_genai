import 'package:flutter_onnx_genai/features/chat/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userListProvider =
    StateNotifierProvider<UserListNotifier, List<User>>((ref) {
  return UserListNotifier();
});

class UserListNotifier extends StateNotifier<List<User>> {
  UserListNotifier() : super([User(name: 'Default')]);

  void addUser(User message) {
    state = [...state, message];
  }
}
