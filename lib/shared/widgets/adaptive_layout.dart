import 'package:flutter/material.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget leftPanel;
  final Widget rightPanel;

  const AdaptiveLayout({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),
            drawer: Drawer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: leftPanel,
              ),
            ),
            body: rightPanel,
          );
        } else {
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: leftPanel,
              ),
              Expanded(
                flex: 2,
                child: rightPanel,
              ),
            ],
          );
        }
      },
    );
  }
}
