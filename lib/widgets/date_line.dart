import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateLine extends StatelessWidget {
  final DateTime date;
  final IconData icon;

  const DateLine({
    super.key,
    required this.date,
    this.icon = Icons.schedule_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Colors.grey.shade700),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            DateFormat('EEE, d MMM yyyy  •  h:mm a').format(date),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
