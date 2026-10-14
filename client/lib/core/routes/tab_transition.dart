import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

abstract final class TabTransition {
  static const duration = Duration(milliseconds: 320);

  static double _direction = 1;

  static void moving(int from, int to) => _direction = to >= from ? 1 : -1;

  static CustomTransition get slide => CustomTransition(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final direction = _direction;
      final entering = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final leaving = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
      );

      return SlideTransition(
        position: Tween(
          begin: Offset.zero,
          end: Offset(-0.35 * direction, 0),
        ).animate(leaving),
        child: SlideTransition(
          position: Tween(
            begin: Offset(0.35 * direction, 0),
            end: Offset.zero,
          ).animate(entering),
          child: FadeTransition(opacity: entering, child: child),
        ),
      );
    },
  );
}
