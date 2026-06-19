import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/widgets/zeb_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoCtrl;
  late AnimationController _contentCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;
  String _loadingText = 'Initializing secure connection...';

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5)),
    );

    // Content animation
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );

    // Particle animation (orbiting dots)
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _contentCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _loadingText = 'Syncing market data...');

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loadingText = 'Ready!');

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _navigate();
  }

  Future<void> _navigate() async {
    final storage = ref.read(secureStorageProvider);
    final isLoggedIn = await storage.isLoggedIn();
    if (!mounted) return;
    if (isLoggedIn) {
      final pin = await storage.getPin();
      context.go(pin != null ? '/auth/pin' : '/home');
    } else {
      context.go('/auth/login');
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background mesh gradient ─────────────────
          Positioned.fill(child: _buildBackground()),

          // ── Orbiting particles ───────────────────────
          Positioned.fill(child: _buildParticles()),

          // ── Main content ─────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Logo
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: const AnimatedZebvixLogo(size: 110),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Brand text
                FadeTransition(
                  opacity: _contentOpacity,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Column(
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'ZEB',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFCD535),
                                  letterSpacing: 5,
                                ),
                              ),
                              TextSpan(
                                text: 'VIX',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFEAEBED),
                                  letterSpacing: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Professional Crypto Exchange',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Loading section
                FadeTransition(
                  opacity: _contentOpacity,
                  child: Column(
                    children: [
                      _buildLoadingBar(),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          _loadingText,
                          key: ValueKey(_loadingText),
                          style: AppTextStyles.micro.copyWith(color: AppColors.textHint),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outlined, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 5),
                          Text(
                            'Secured by 256-bit encryption',
                            style: AppTextStyles.micro.copyWith(color: AppColors.textHint, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return CustomPaint(painter: _MeshGradientPainter());
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) => CustomPaint(
        painter: _ParticlePainter(progress: _particleCtrl.value),
      ),
    );
  }

  Widget _buildLoadingBar() {
    return SizedBox(
      width: 160,
      child: AnimatedBuilder(
        animation: _contentCtrl,
        builder: (_, __) => LinearProgressIndicator(
          backgroundColor: AppColors.surface,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          borderRadius: BorderRadius.circular(10),
          minHeight: 3,
        ),
      ),
    );
  }
}

// ─── Mesh background painter ──────────────────────────────────
class _MeshGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Deep background
    paint.color = const Color(0xFF0B0E11);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Top-left glow
    final tl = RadialGradient(colors: [
      const Color(0xFFFCD535).withOpacity(0.06), Colors.transparent,
    ]).createShader(Rect.fromCircle(center: Offset(0, 0), radius: size.width * 0.8));
    paint.shader = tl;
    canvas.drawCircle(Offset.zero, size.width * 0.8, paint);

    // Bottom-right glow
    final br = RadialGradient(colors: [
      const Color(0xFF1DA2B4).withOpacity(0.06), Colors.transparent,
    ]).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.7));
    paint.shader = br;
    canvas.drawCircle(Offset(size.width, size.height), size.width * 0.7, paint);
    paint.shader = null;
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Orbiting particle painter ────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  const _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;
    final paint = Paint()..style = PaintingStyle.fill;

    final particles = [
      _Particle(orbitRadius: 90, orbitSpeed: 1.0, size: 3.0, angleOffset: 0, opacity: 0.6),
      _Particle(orbitRadius: 90, orbitSpeed: 1.0, size: 2.0, angleOffset: math.pi, opacity: 0.4),
      _Particle(orbitRadius: 120, orbitSpeed: -0.7, size: 2.5, angleOffset: math.pi / 3, opacity: 0.35),
      _Particle(orbitRadius: 120, orbitSpeed: -0.7, size: 1.5, angleOffset: math.pi * 1.3, opacity: 0.25),
      _Particle(orbitRadius: 150, orbitSpeed: 0.5, size: 2.0, angleOffset: math.pi * 0.7, opacity: 0.2),
    ];

    for (final p in particles) {
      final angle = progress * math.pi * 2 * p.orbitSpeed + p.angleOffset;
      final x = cx + math.cos(angle) * p.orbitRadius;
      final y = cy + math.sin(angle) * p.orbitRadius;
      paint.color = const Color(0xFFFCD535).withOpacity(p.opacity);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double orbitRadius, orbitSpeed, size, angleOffset, opacity;
  const _Particle({
    required this.orbitRadius, required this.orbitSpeed,
    required this.size, required this.angleOffset, required this.opacity,
  });
}
