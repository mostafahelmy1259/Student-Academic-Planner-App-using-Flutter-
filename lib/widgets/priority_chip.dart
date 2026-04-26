import 'package:flutter/material.dart';

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({super.key, required this.priority});

  Color get _color {
    switch (priority) {
      case 'High':
        return const Color(0xFFD32F2F);
      case 'Medium':
        return const Color(0xFFF57C00);
      case 'Low':
        return const Color(0xFF388E3C);
      default:
        return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _color.withValues(alpha: 0.22)),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
