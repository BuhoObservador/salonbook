import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final List<Widget> listChild;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CustomBottomSheet({
    super.key,
    required this.listChild,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: listChild,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}