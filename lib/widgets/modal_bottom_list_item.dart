import 'package:flutter/material.dart';

class ModalBottomListItem extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? hoverColor;
  final double borderRadius;

  const ModalBottomListItem({
    super.key,
    required this.leading,
    required this.title,
    required this.onPressed,
    this.backgroundColor,
    this.hoverColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: hoverColor ?? Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
          splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.0,
                  ),
                  child: leading,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    child: title,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.0,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}