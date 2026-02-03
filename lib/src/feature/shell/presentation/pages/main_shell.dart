import 'package:expense_splitter/src/core/router/all/home_routes.dart';
import 'package:expense_splitter/src/core/theme/theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(HomeRoutes.selfPage)) return 3;
    if (location.startsWith(HomeRoutes.splitterPage)) return 2;
    if (location.startsWith(HomeRoutes.familiaPage)) return 1;
    return 0; // /app/splitter default
  }

  void _onTap(BuildContext context, int index) {
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    switch (index) {
      case 0:
        context.go(HomeRoutes.dashBoardPage);
        break;
      case 1:
        context.go(HomeRoutes.familiaPage);
        break;
      case 2:
        context.go(HomeRoutes.splitterPage);
        break;
      case 3:
        context.go(HomeRoutes.selfPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            child: _FancyBottomNav(
              isDark: isDark,
              currentIndex: currentIndex,
              onTap: (i) => _onTap(context, i),
            ),
          ),
        ),
      ),
    );
  }
}

class _FancyBottomNav extends StatefulWidget {
  final bool isDark;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FancyBottomNav({
    required this.isDark,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_FancyBottomNav> createState() => _FancyBottomNavState();
}

class _FancyBottomNavState extends State<_FancyBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _bubbleController;
  late Animation<double> _bubbleScale;

  @override
  void initState() {
    super.initState();

    // Controller for bubble pop animation
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bubbleScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.85,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_bubbleController);
  }

  @override
  void didUpdateWidget(_FancyBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _bubbleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced color scheme with better depth
    final barColor = widget.isDark
        ? const Color(0xFF111827).withAlpha(217)
        : Colors.white.withAlpha(235);
    final borderColor = widget.isDark
        ? Colors.white.withAlpha(31)
        : Colors.black.withAlpha(20);
    final inactive = widget.isDark ? Colors.grey[400]! : Colors.grey[600]!;

    const barHeight = 56.0;
    const bubbleSize = 48.0;
    const notchDepth = 18.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final itemW = w / 4;
        final targetCenterX = (widget.currentIndex + 0.5) * itemW;

        IconData activeIcon = widget.currentIndex == 0
            ? Icons.home_rounded
            : widget.currentIndex == 1
            ? Icons.family_restroom
            : widget.currentIndex == 2
            ? Icons.splitscreen
            : Icons.person;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: targetCenterX, end: targetCenterX),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, animatedCenterX, _) {
            final bubbleLeft = animatedCenterX - bubbleSize / 2;

            return SizedBox(
              height: barHeight + bubbleSize / 2 - 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Pill bar with animated notch
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: CustomPaint(
                        painter: _NotchedPillPainter(
                          centerX: animatedCenterX,
                          barColor: barColor,
                          borderColor: borderColor,
                          shadowColor: Colors.black.withAlpha(
                            widget.isDark ? 102 : 38,
                          ),
                          notchDepth: notchDepth,
                        ),
                        child: SizedBox(
                          height: barHeight,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),

                  // Items row (icons + labels)
                  SizedBox(
                    height: barHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: _PillNavItem(
                            active: widget.currentIndex == 0,
                            icon: Icons.home_rounded,
                            label: 'Home',
                            inactiveColor: inactive,
                            onTap: () => widget.onTap(0),
                          ),
                        ),
                        Expanded(
                          child: _PillNavItem(
                            active: widget.currentIndex == 1,
                            icon: Icons.family_restroom,
                            label: 'familia',
                            inactiveColor: inactive,
                            onTap: () => widget.onTap(1),
                          ),
                        ),
                        Expanded(
                          child: _PillNavItem(
                            active: widget.currentIndex == 2,
                            icon: Icons.splitscreen,
                            label: 'splitter',
                            inactiveColor: inactive,
                            onTap: () => widget.onTap(2),
                          ),
                        ),
                        Expanded(
                          child: _PillNavItem(
                            active: widget.currentIndex == 3,
                            icon: Icons.person,
                            label: 'Self',
                            inactiveColor: inactive,
                            onTap: () => widget.onTap(3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active bubble with enhanced animation
                  Positioned(
                    left: bubbleLeft,
                    bottom: barHeight - bubbleSize / 4 - 12,
                    child: AnimatedBuilder(
                      animation: _bubbleScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _bubbleScale.value,
                          child: Container(
                            width: bubbleSize,
                            height: bubbleSize,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.white.withAlpha(242),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.premiumPurple.withAlpha(51),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withAlpha(31),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                activeIcon,
                                color: AppTheme.premiumPurple,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PillNavItem extends StatefulWidget {
  final bool active;
  final IconData icon;
  final String label;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _PillNavItem({
    required this.active,
    required this.icon,
    required this.label,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  State<_PillNavItem> createState() => _PillNavItemState();
}

class _PillNavItemState extends State<_PillNavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      selected: widget.active,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          splashColor: AppTheme.premiumPurple.withAlpha(26),
          highlightColor: AppTheme.premiumPurple.withAlpha(13),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  transform: Matrix4.translationValues(
                    0,
                    widget.active ? -8 : (_isPressed ? 2 : 0),
                    0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    transform: Matrix4.diagonal3Values(
                      _isPressed ? 0.9 : 1.0,
                      _isPressed ? 0.9 : 1.0,
                      1.0,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.active
                          ? AppTheme.premiumPurple
                          : widget.inactiveColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: widget.active ? 1 : 0.7,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: widget.active
                          ? AppTheme.premiumPurple
                          : widget.inactiveColor,
                      fontWeight: widget.active
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotchedPillPainter extends CustomPainter {
  final double centerX;
  final Color barColor;
  final Color borderColor;
  final Color shadowColor;
  final double notchDepth;

  _NotchedPillPainter({
    required this.centerX,
    required this.barColor,
    required this.borderColor,
    required this.shadowColor,
    required this.notchDepth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const radius = 28.0;
    const notchWidth = 92.0;
    const notchR = 20.0;

    final cx = centerX.clamp(70.0, w - 70.0);
    final left = cx - notchWidth / 2;
    final right = cx + notchWidth / 2;

    final path = Path();
    path.moveTo(radius, 0);

    // Top-left edge to notch start
    path.lineTo(left - notchR, 0);

    // Smoother notch curve with better control points
    path.cubicTo(
      left - notchR * 0.2,
      0,
      left + notchR * 0.3,
      notchDepth * 0.9,
      cx,
      notchDepth,
    );
    path.cubicTo(
      right - notchR * 0.3,
      notchDepth * 0.9,
      right + notchR * 0.2,
      0,
      right + notchR,
      0,
    );

    // Continue top edge to top-right corner
    path.lineTo(w - radius, 0);
    path.quadraticBezierTo(w, 0, w, radius);

    // Right side
    path.lineTo(w, h - radius);
    path.quadraticBezierTo(w, h, w - radius, h);

    // Bottom edge
    path.lineTo(radius, h);
    path.quadraticBezierTo(0, h, 0, h - radius);

    // Left side
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    // Enhanced shadow with layering
    canvas.drawShadow(path, shadowColor, 16, true);

    // Fill
    final fill = Paint()..color = barColor;
    canvas.drawPath(path, fill);

    // Border
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = borderColor;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _NotchedPillPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.barColor != barColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.notchDepth != notchDepth;
  }
}
