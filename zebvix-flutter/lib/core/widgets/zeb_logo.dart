import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════
//  ZebvixLogo — scalable branded logo widget
//  Use size parameter to control size
// ═══════════════════════════════════════════════════════════
class ZebvixLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showGlow;
  final LogoVariant variant;

  const ZebvixLogo({
    super.key,
    this.size = 56,
    this.showText = false,
    this.showGlow = true,
    this.variant = LogoVariant.rounded,
  });

  @override
  Widget build(BuildContext context) {
    final logo = _LogoMark(size: size, showGlow: showGlow, variant: variant);
    if (!showText) return logo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ZEBVIX',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: size * 0.38,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 2,
                height: 1.1,
              ),
            ),
            Text(
              'Exchange',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: size * 0.2,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum LogoVariant { rounded, circle, square, flat }

class _LogoMark extends StatelessWidget {
  final double size;
  final bool showGlow;
  final LogoVariant variant;
  const _LogoMark({required this.size, required this.showGlow, required this.variant});

  @override
  Widget build(BuildContext context) {
    final radius = switch (variant) {
      LogoVariant.circle => size / 2,
      LogoVariant.square => 0.0,
      LogoVariant.rounded => size * 0.22,
      LogoVariant.flat => size * 0.14,
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCD535), Color(0xFFE8B800), Color(0xFFFCD535)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFFFCD535).withOpacity(0.5),
                  blurRadius: size * 0.6,
                  spreadRadius: size * 0.05,
                ),
                BoxShadow(
                  color: const Color(0xFFE8B800).withOpacity(0.2),
                  blurRadius: size * 0.2,
                  spreadRadius: size * 0.02,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _ZLogoMarkPainter(size: size),
      ),
    );
  }
}

// ─── "Z" with lightning bolt accent — drawn with paths ──────
class _ZLogoMarkPainter extends CustomPainter {
  final double size;
  const _ZLogoMarkPainter({required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final s = size;
    final pad = s * 0.22;

    final paint = Paint()
      ..color = const Color(0xFF0B0E11)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw stylized "Z" — thick geometric letterform
    final path = Path();

    // Top bar of Z
    final topLeft = Offset(pad, pad);
    final topRight = Offset(s - pad, pad);
    final strokeW = s * 0.11;

    // Top horizontal
    path.addRect(Rect.fromLTWH(topLeft.dx, topLeft.dy, topRight.dx - topLeft.dx, strokeW));

    // Diagonal (the slash of Z)
    final diagPath = Path();
    diagPath.moveTo(topRight.dx, topLeft.dy + strokeW);
    diagPath.lineTo(pad, s - pad - strokeW);
    diagPath.lineTo(pad + strokeW * 1.8, s - pad - strokeW);
    diagPath.lineTo(topRight.dx + strokeW * 0.0, topLeft.dy + strokeW);
    // thicker diagonal
    final diagPath2 = Path();
    diagPath2.moveTo(topRight.dx, topLeft.dy + strokeW);
    diagPath2.lineTo(pad + strokeW * 0.5, s - pad - strokeW);
    diagPath2.lineTo(pad + strokeW * 0.5 + strokeW * 1.6, s - pad - strokeW);
    diagPath2.lineTo(topRight.dx + strokeW * 1.6, topLeft.dy + strokeW);
    diagPath2.close();
    canvas.drawPath(diagPath2, paint);

    // Bottom horizontal
    path.addRect(Rect.fromLTWH(pad, s - pad - strokeW, s - 2 * pad, strokeW));

    canvas.drawPath(path, paint);

    // Lightning accent dot (small circle near top-right)
    final accentPaint = Paint()
      ..color = const Color(0xFF0B0E11).withOpacity(0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(s - pad - strokeW * 0.5, pad + strokeW * 1.8), strokeW * 0.4, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════
//  Animated logo for splash screen
// ═══════════════════════════════════════════════════════════
class AnimatedZebvixLogo extends StatefulWidget {
  final double size;
  const AnimatedZebvixLogo({super.key, this.size = 100});

  @override
  State<AnimatedZebvixLogo> createState() => _AnimatedZebvixLogoState();
}

class _AnimatedZebvixLogoState extends State<AnimatedZebvixLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.4, end: 0.75).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFCD535), Color(0xFFE8B800), Color(0xFFFCD535)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(widget.size * 0.24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFCD535).withOpacity(_glow.value),
                blurRadius: widget.size * 0.7,
                spreadRadius: widget.size * 0.08,
              ),
              BoxShadow(
                color: const Color(0xFFFCD535).withOpacity(0.25),
                blurRadius: widget.size * 0.25,
                spreadRadius: widget.size * 0.02,
              ),
            ],
          ),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ZLogoMarkPainter(size: widget.size),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Small app-bar logo (32px)
// ═══════════════════════════════════════════════════════════
class AppBarLogo extends StatelessWidget {
  const AppBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ZebvixLogo(size: 32, showGlow: false, variant: LogoVariant.rounded),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'ZEB',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFCD535),
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: 'VIX',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFEAEBED),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
