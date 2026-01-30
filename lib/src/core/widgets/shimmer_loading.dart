import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:expense_splitter/src/core/theme/theme.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.lightLavender.withAlpha(77),
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          ShimmerLoading(
            width: 64,
            height: 64,
            borderRadius: BorderRadius.circular(18),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 12),
                ShimmerLoading(
                  width: 120,
                  height: 12,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
