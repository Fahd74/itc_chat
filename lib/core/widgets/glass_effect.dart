import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:itc_chat/core/constants/app_colors.dart';

class GlassEffect extends StatelessWidget {
  const GlassEffect({super.key, required this.borderRadius, required this.child});

  final BorderRadiusGeometry borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                blurRadius: 25,
                spreadRadius: 1,
              ),
            ],
            color: AppColors.glassColor.withValues(alpha: 0.3),
            borderRadius: borderRadius,
            border: Border.symmetric(
              vertical: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.1),
              horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 0.4),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
