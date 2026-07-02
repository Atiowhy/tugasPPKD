import 'package:flutter/material.dart';

class GlossyBackground extends StatelessWidget {
  final Widget child;

  const GlossyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Stack(
        children: [
          // Soft aesthetic glowing orb at the top right
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF6366F1).withOpacity(0.15) : const Color(0xFF0EA5E9).withOpacity(0.15),
              ),
              // We use a high blur in a normal Container to make it soft
              foregroundDecoration: const BoxDecoration(
                color: Colors.transparent,
                backgroundBlendMode: BlendMode.overlay,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFFFB7185).withOpacity(0.05) : const Color(0xFFF43F5E).withOpacity(0.05),
              ),
              foregroundDecoration: const BoxDecoration(
                color: Colors.transparent,
                backgroundBlendMode: BlendMode.overlay,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class GlossyCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlossyCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0, // High border radius for aesthetic look
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFF0F172A).withOpacity(0.04), // Dynamic shadow
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}
