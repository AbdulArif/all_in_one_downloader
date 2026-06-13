import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'facebook_page.dart';
import 'instagram_page.dart';
import 'linkedin_page.dart';
import 'youtube_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;

  static const _platforms = [
    _PlatformData(
      name: 'Facebook',
      subtitle: 'Videos & reels',
      colors: [Color(0xFF1877F2), Color(0xFF074AA5)],
      mark: 'f',
    ),
    _PlatformData(
      name: 'Instagram',
      subtitle: 'Reels & posts',
      colors: [Color(0xFFFEDA75), Color(0xFFD62976), Color(0xFF4F5BD5)],
      icon: Icons.camera_alt_rounded,
    ),
    _PlatformData(
      name: 'YouTube',
      subtitle: 'Videos & shorts',
      colors: [Color(0xFFFF3B30), Color(0xFFB50000)],
      icon: Icons.play_arrow_rounded,
    ),
    _PlatformData(
      name: 'LinkedIn',
      subtitle: 'Videos & posts',
      colors: [Color(0xFF0A66C2), Color(0xFF06447F)],
      mark: 'in',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _openPlatform(_PlatformData platform) {
    final Widget page;
    switch (platform.name) {
      case 'Facebook':
        page = const FacebookPage();
      case 'Instagram':
        page = const InstagramPage();
      case 'YouTube':
        page = const YouTubePage();
      case 'LinkedIn':
        page = const LinkedInPage();
      default:
        return;
    }
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _HomeBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 48 : 22,
                    30,
                    wide ? 48 : 22,
                    32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HomeHeader(wide: wide),
                          SizedBox(height: wide ? 52 : 38),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _platforms.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: wide ? 4 : 2,
                                  crossAxisSpacing: wide ? 20 : 14,
                                  mainAxisSpacing: wide ? 20 : 14,
                                ),
                            itemBuilder: (context, index) =>
                                _AnimatedPlatformButton(
                                  data: _platforms[index],
                                  index: index,
                                  animation: _entryController,
                                  onTap: () => _openPlatform(_platforms[index]),
                                ),
                          ),
                          const SizedBox(height: 34),
                          Center(
                            child: Text(
                              'Choose a platform to get started',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.38),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
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
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFF7B61FF), Color(0xFF29D5E8)],
            ),
          ),
          child: const Icon(Icons.arrow_downward_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello there!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'What are we downloading?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: wide ? 27 : 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedPlatformButton extends StatefulWidget {
  const _AnimatedPlatformButton({
    required this.data,
    required this.index,
    required this.animation,
    required this.onTap,
  });

  final _PlatformData data;
  final int index;
  final AnimationController animation;
  final VoidCallback onTap;

  @override
  State<_AnimatedPlatformButton> createState() =>
      _AnimatedPlatformButtonState();
}

class _AnimatedPlatformButtonState extends State<_AnimatedPlatformButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final start = widget.index * 0.13;
    final entrance = CurvedAnimation(
      parent: widget.animation,
      curve: Interval(
        start,
        math.min(start + 0.55, 1),
        curve: Curves.easeOutBack,
      ),
    );

    return FadeTransition(
      opacity: entrance,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.72, end: 1).animate(entrance),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 140),
          child: Semantics(
            button: true,
            label: widget.data.name,
            child: GestureDetector(
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTapUp: (_) => setState(() => _pressed = false),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.data.colors,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.data.colors.last.withValues(alpha: 0.28),
                      blurRadius: 25,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: widget.data.icon != null
                              ? Icon(
                                  widget.data.icon,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : Text(
                                  widget.data.mark!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: widget.data.mark == 'f' ? 58 : 40,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                    letterSpacing: -2,
                                  ),
                                ),
                        ),
                      ),
                      Text(
                        widget.data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlatformData {
  const _PlatformData({
    required this.name,
    required this.subtitle,
    required this.colors,
    this.icon,
    this.mark,
  });

  final String name;
  final String subtitle;
  final List<Color> colors;
  final IconData? icon;
  final String? mark;
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111839), Color(0xFF080C1D), Color(0xFF0C1028)],
          stops: [0, 0.52, 1],
        ),
      ),
    );
  }
}
