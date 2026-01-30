import 'package:flutter/material.dart';
import 'package:expense_splitter/src/core/theme/theme.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: widget.isDark
                ? LinearGradient(
                    begin: Alignment(-1.0 + _animation.value * 0.1, -1.0),
                    end: Alignment(1.0 - _animation.value * 0.1, 1.0),
                    colors: [AppTheme.charcoalBlack, AppTheme.midnightBlue],
                  )
                : LinearGradient(
                    begin: Alignment(-1.0 + _animation.value * 0.1, -1.0),
                    end: Alignment(1.0 - _animation.value * 0.1, 1.0),
                    colors: [
                      AppTheme.offWhite,
                      AppTheme.softLavender.withAlpha(
                        ((0.3 + _animation.value * 0.2) * 255).round(),
                      ),
                    ],
                  ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
