import 'package:flutter/material.dart';
import 'package:flutter_onnx_genai/features/chat/ui/chat_page.dart';
import 'package:flutter_onnx_genai/features/shared/ui/not_found_page.dart';
import 'package:flutter_onnx_genai/routing/app_startup.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';

part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

enum AppRoute { chat }

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final appStartupState = ref.watch(appStartupProvider);
  return GoRouter(
    initialLocation: '/chat',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (appStartupState.isLoading || appStartupState.hasError) {
        return '/startup';
      }

      return '/chat';
    },
    routes: [
      GoRoute(
        path: '/startup',
        pageBuilder: (context, state) => NoTransitionPage(
          child: AppStartupWidget(
            onLoaded: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
      GoRoute(
        path: '/chat',
        name: AppRoute.chat.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ChatPage(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => const NoTransitionPage(
      child: NotFoundPage(),
    ),
  );
}
