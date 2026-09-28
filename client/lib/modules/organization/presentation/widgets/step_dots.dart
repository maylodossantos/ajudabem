import 'package:flutter/material.dart';

class StepDots extends StatelessWidget {
  const StepDots({required this.count, required this.current, super.key});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == current
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFFD9D9D9),
            ),
          ),
      ],
    );
  }
}
