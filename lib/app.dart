import 'package:flutter/material.dart';
import 'package:flutter_onnx_genai/routing/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static const Color highlightColor = Color(0xFF222a36);
  static const Color backgroundColor = Color(0xFFecf2f5);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerConfig: goRouter,
      theme: ThemeData(
        canvasColor: highlightColor,
        cardColor: backgroundColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                foregroundColor: backgroundColor,
                backgroundColor: highlightColor)),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
