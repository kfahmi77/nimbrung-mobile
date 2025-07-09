import 'package:flutter/material.dart';
import 'dart:math' as math;

class EnhancedRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final double size;
  final RefreshStyle style;
  final bool showDefaultIndicator;

  const EnhancedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.primaryColor = const Color(0xFFE17B47),
    this.secondaryColor = const Color(0xFFFF9A56),
    this.backgroundColor = Colors.white,
    this.size = 50.0,
    this.style = RefreshStyle.liquid,
    this.showDefaultIndicator = false,
  });

  @override
  State<EnhancedRefreshIndicator> createState() =>
      _EnhancedRefreshIndicatorState();
}

enum RefreshStyle { liquid, pulse, morphing, neon }

class _EnhancedRefreshIndicatorState extends State<EnhancedRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _waveController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -80.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.bounceOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _waveController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Start all animations
    _mainController.forward();
    _waveController.repeat();
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);

    try {
      await widget.onRefresh();
    } finally {
      // Stop all animations
      _waveController.stop();
      _rotationController.stop();
      _pulseController.stop();
      await _mainController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor:
          widget.showDefaultIndicator
              ? widget.backgroundColor
              : Colors.transparent,
      color:
          widget.showDefaultIndicator
              ? widget.primaryColor
              : Colors.transparent,
      strokeWidth: widget.showDefaultIndicator ? 3.0 : 0,
      displacement: 80.0,
      child: Stack(
        children: [
          widget.child,
          // Custom refresh indicator overlay
          if (!widget.showDefaultIndicator)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _mainController,
                  _waveController,
                  _rotationController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.backgroundColor.withValues(alpha: 0.95),
                              widget.backgroundColor.withValues(alpha: 0.8),
                              widget.backgroundColor.withValues(alpha: 0.4),
                              widget.backgroundColor.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: _scaleAnimation.value,
                                child: _buildRefreshWidget(),
                              ),
                              const SizedBox(height: 8),
                              if (_opacityAnimation.value > 0.5)
                                Transform.translate(
                                  offset: Offset(
                                    0,
                                    (1 - _opacityAnimation.value) * 20,
                                  ),
                                  child: Text(
                                    'Memuat ulang...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.primaryColor.withValues(
                                        alpha: _opacityAnimation.value,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
  }

  Widget _buildRefreshWidget() {
    switch (widget.style) {
      case RefreshStyle.liquid:
        return _buildLiquidRefresh();
      case RefreshStyle.pulse:
        return _buildPulseRefresh();
      case RefreshStyle.morphing:
        return _buildMorphingRefresh();
      case RefreshStyle.neon:
        return _buildNeonRefresh();
    }
  }

  Widget _buildLiquidRefresh() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: ModernLiquidRefreshPainter(
          waveAnimation: _waveAnimation.value,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
          pulseScale: _pulseAnimation.value,
        ),
      ),
    );
  }

  Widget _buildPulseRefresh() {
    return Transform.scale(
      scale: _pulseAnimation.value,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [widget.primaryColor, widget.secondaryColor],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Transform.rotate(
          angle: _rotationAnimation.value,
          child: const Icon(Icons.refresh, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildMorphingRefresh() {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: MorphingRefreshPainter(
        animation: _waveAnimation.value,
        rotationAnimation: _rotationAnimation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      ),
    );
  }

  Widget _buildNeonRefresh() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black87,
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: widget.secondaryColor.withValues(alpha: 0.3),
            blurRadius: 50,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Transform.rotate(
        angle: _rotationAnimation.value,
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: NeonRefreshPainter(
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            pulseScale: _pulseAnimation.value,
          ),
        ),
      ),
    );
  }
}

class ModernLiquidRefreshPainter extends CustomPainter {
  final double waveAnimation;
  final Color primaryColor;
  final Color secondaryColor;
  final double pulseScale;

  ModernLiquidRefreshPainter({
    required this.waveAnimation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * pulseScale;

    // Draw outer glow
    final glowPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              primaryColor.withValues(alpha: 0.1),
              primaryColor.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));

    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // Draw main gradient circle
    final mainPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              secondaryColor,
              primaryColor,
              primaryColor.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(
            Rect.fromCircle(center: center, radius: radius * 0.85),
          );

    canvas.drawCircle(center, radius * 0.85, mainPaint);

    // Draw inner highlight
    final highlightPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 0.4));

    canvas.drawCircle(
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.2),
      radius * 0.4,
      highlightPaint,
    );

    // Draw animated ripple waves
    for (int i = 0; i < 3; i++) {
      final waveRadius =
          radius * (0.3 + (0.9 * ((waveAnimation + i * 0.33) % 1.0)));
      if (waveRadius <= radius * 1.3) {
        final alpha = (0.6 -
                (i * 0.15) -
                ((waveAnimation + i * 0.33) % 1.0) * 0.4)
            .clamp(0.0, 1.0);
        final wavePaint =
            Paint()
              ..color = secondaryColor.withValues(alpha: alpha)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5 - (i * 0.5);

        canvas.drawCircle(center, waveRadius, wavePaint);
      }
    }

    // Draw modern refresh icon
    final iconPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;

    // Main arc
    final path = Path();
    final arrowRadius = radius * 0.45;
    path.addArc(
      Rect.fromCircle(center: center, radius: arrowRadius),
      -math.pi / 2,
      math.pi * 1.5,
    );

    canvas.drawPath(path, iconPaint);

    // Arrow head with better design
    final arrowPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(center.dx + arrowRadius, center.dy);
    arrowPath.lineTo(center.dx + arrowRadius - 8, center.dy - 5);
    arrowPath.lineTo(center.dx + arrowRadius - 6, center.dy);
    arrowPath.lineTo(center.dx + arrowRadius - 8, center.dy + 5);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);

    // Add floating particles
    final particlePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (waveAnimation * 2 * math.pi * 0.5) + (i * math.pi / 4);
      final distance = radius * (0.6 + 0.2 * math.sin(waveAnimation * 3 + i));
      final particlePos = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );

      final particleSize = 1.5 + (math.sin(waveAnimation * 4 + i) * 0.5);
      canvas.drawCircle(particlePos, particleSize, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MorphingRefreshPainter extends CustomPainter {
  final double animation;
  final double rotationAnimation;
  final Color primaryColor;
  final Color secondaryColor;

  MorphingRefreshPainter({
    required this.animation,
    required this.rotationAnimation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create morphing shape
    final path = Path();
    final points = 6;

    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * math.pi / points) + rotationAnimation;
      final morphFactor = 0.3 + 0.7 * (math.sin(animation * 2 + i) + 1) / 2;
      final pointRadius = radius * 0.6 * morphFactor;

      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw morphing shape with gradient
    final paint =
        Paint()
          ..shader = RadialGradient(
            colors: [primaryColor, secondaryColor],
          ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);

    // Draw center icon
    final iconPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.2, iconPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NeonRefreshPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double pulseScale;

  NeonRefreshPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw neon glow effect
    final glowPaint =
        Paint()
          ..color = primaryColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0 * pulseScale
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, radius * 0.7, glowPaint);

    // Draw main neon circle
    final neonPaint =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius * 0.7, neonPaint);

    // Draw inner refresh symbol
    final arrowPaint =
        Paint()
          ..color = secondaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius * 0.4),
      -math.pi / 2,
      3 * math.pi / 2,
    );

    canvas.drawPath(path, arrowPaint);

    // Arrow head
    final arrowHead = Path();
    arrowHead.moveTo(center.dx + radius * 0.4, center.dy);
    arrowHead.lineTo(center.dx + radius * 0.4 - 6, center.dy - 4);
    arrowHead.moveTo(center.dx + radius * 0.4, center.dy);
    arrowHead.lineTo(center.dx + radius * 0.4 - 6, center.dy + 4);

    canvas.drawPath(arrowHead, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
