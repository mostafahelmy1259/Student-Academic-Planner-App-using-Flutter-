import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldCompact = compact ||
            (constraints.hasBoundedHeight && constraints.maxHeight < 230);

        final iconSize = shouldCompact ? 56.0 : 84.0;
        final iconRadius = shouldCompact ? 20.0 : 28.0;
        final iconGraphicSize = shouldCompact ? 30.0 : 42.0;
        final padding = shouldCompact ? 14.0 : 28.0;
        final titleStyle = shouldCompact
            ? Theme.of(context).textTheme.titleMedium
            : Theme.of(context).textTheme.titleLarge;

        return Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(iconRadius),
                  ),
                  child: Icon(
                    icon,
                    size: iconGraphicSize,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: shouldCompact ? 10 : 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: shouldCompact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: shouldCompact ? 4 : 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: shouldCompact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: shouldCompact ? 13 : null,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
