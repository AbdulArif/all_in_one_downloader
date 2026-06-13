import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const DownloaderApp());
}

class DownloaderApp extends StatelessWidget {
  const DownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Droply',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080C1D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _navigationTimer = Timer(const Duration(seconds: 2), _openHomePage);
  }

  void _openHomePage() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final shortestSide = math.min(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final compact = constraints.maxHeight < 620;
          final logoSize = (shortestSide * 0.30).clamp(112.0, 174.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              const _Backdrop(),
              _FloatingChip(
                icon: Icons.music_note_rounded,
                color: const Color(0xFFFF6F91),
                alignment: const Alignment(-0.78, -0.48),
                animation: _controller,
                phase: 0.1,
                reduceMotion: reduceMotion,
              ),
              _FloatingChip(
                icon: Icons.play_arrow_rounded,
                color: const Color(0xFFFFB25B),
                alignment: const Alignment(0.78, -0.32),
                animation: _controller,
                phase: 0.55,
                reduceMotion: reduceMotion,
              ),
              _FloatingChip(
                icon: Icons.photo_rounded,
                color: const Color(0xFF58E1C1),
                alignment: const Alignment(-0.72, 0.40),
                animation: _controller,
                phase: 0.8,
                reduceMotion: reduceMotion,
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _AnimatedLogo(
                            size: logoSize,
                            animation: _controller,
                            reduceMotion: reduceMotion,
                          ),
                          SizedBox(height: compact ? 26 : 38),
                          const _BrandName(),
                          const SizedBox(height: 14),
                          Text(
                            'Everything you love, saved in one tap.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.62),
                              fontSize: compact ? 15 : 17,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.1,
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: compact ? 38 : 64),
                          _LoadingIndicator(
                            animation: _controller,
                            reduceMotion: reduceMotion,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 20 + MediaQuery.paddingOf(context).bottom,
                child: Text(
                  'FAST  |  SIMPLE  |  SECURE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.28),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111839), Color(0xFF080C1D), Color(0xFF0C1028)],
          stops: [0, 0.52, 1],
        ),
      ),
      child: CustomPaint(painter: _GlowPainter()),
    );
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final violet = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF765BFF).withValues(alpha: 0.22),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.22, size.height * 0.16),
              radius: size.shortestSide * 0.66,
            ),
          );
    canvas.drawRect(Offset.zero & size, violet);

    final cyan = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF31D8FF).withValues(alpha: 0.13),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.88, size.height * 0.78),
              radius: size.shortestSide * 0.55,
            ),
          );
    canvas.drawRect(Offset.zero & size, cyan);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.size,
    required this.animation,
    required this.reduceMotion,
  });

  final double size;
  final Animation<double> animation;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final wave = reduceMotion
            ? 0.0
            : math.sin(animation.value * math.pi * 2) * 4;
        return Transform.translate(offset: Offset(0, wave), child: child);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.29),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B61FF), Color(0xFF4B6BFF), Color(0xFF29D5E8)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D6BFF).withValues(alpha: 0.38),
              blurRadius: 44,
              spreadRadius: 4,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.09,
              left: size * 0.12,
              child: Container(
                width: size * 0.48,
                height: size * 0.22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ),
            Icon(
              Icons.arrow_downward_rounded,
              size: size * 0.48,
              color: Colors.white,
            ),
            Positioned(
              bottom: size * 0.22,
              child: Container(
                width: size * 0.50,
                height: size * 0.055,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandName extends StatelessWidget {
  const _BrandName();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFFC7D7FF)],
      ).createShader(bounds),
      child: const Text(
        'Droply',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.8,
          height: 1,
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({
    required this.animation,
    required this.reduceMotion,
  });

  final Animation<double> animation;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final progress = reduceMotion ? 0.68 : animation.value;
          return SizedBox(
            width: 116,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: 0.28 + (progress * 0.62),
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.09),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF62DDF1)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'GETTING THINGS READY',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FloatingChip extends StatelessWidget {
  const _FloatingChip({
    required this.icon,
    required this.color,
    required this.alignment,
    required this.animation,
    required this.phase,
    required this.reduceMotion,
  });

  final IconData icon;
  final Color color;
  final Alignment alignment;
  final Animation<double> animation;
  final double phase;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final angle = (animation.value + phase) * math.pi * 2;
          final offset = reduceMotion
              ? Offset.zero
              : Offset(math.cos(angle) * 4, math.sin(angle) * 7);
          return Transform.translate(offset: offset, child: child);
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF171D3D).withValues(alpha: 0.84),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.16),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 23),
        ),
      ),
    );
  }
}
