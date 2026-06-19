import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    required this.isDark,
    this.padding = const EdgeInsets.all(22),
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (isDark ? const Color(0xFF0F172A) : Colors.white),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              borderColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.transparent),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
