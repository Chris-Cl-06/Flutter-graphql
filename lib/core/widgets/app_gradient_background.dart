import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/bg_data.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.14),
                colorScheme.secondary.withValues(alpha: 0.08),
                const Color(0xFFF2F5FB),
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        if (bgList.isNotEmpty)
          Center(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                bgList[0],
                fit: BoxFit.contain,
                width: 520,
                gaplessPlayback: true,
              ),
            ),
          ),
        child,
      ],
    );
  }
}
