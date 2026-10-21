import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/category_data.dart';

/// Plays a confetti shower over the whole app using [overlay].
/// Does nothing when the system "reduce motion" setting is on.
void showConfetti(OverlayState overlay) {
  final reduceMotion =
      MediaQuery.maybeDisableAnimationsOf(overlay.context) ?? false;
  if (reduceMotion) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) =>
        IgnorePointer(child: ConfettiBurst(onFinished: () => entry.remove())),
  );
  overlay.insert(entry);
}

/// Falling confetti drawn with a [CustomPainter]; calls [onFinished] at the
/// end.
class ConfettiBurst extends StatefulWidget {
  /// Creates a burst. [seed] makes the pattern reproducible in tests.
  const ConfettiBurst({super.key, required this.onFinished, this.seed});

  /// Total length of the animation.
  static const Duration duration = Duration(milliseconds: 2800);

  final VoidCallback onFinished;
  final int? seed;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const int _count = 140;
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = Random(widget.seed);
    final colors = [for (final c in CategoryData.all) c.darkColor];
    _particles = List.generate(_count, (_) => _Particle.random(random, colors));
    _controller = AnimationController(
      vsync: this,
      duration: ConfettiBurst.duration,
    )..forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ConfettiPainter(_particles, _controller),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.spin,
    required this.size,
    required this.color,
    required this.round,
  });

  factory _Particle.random(Random r, List<Color> colors) => _Particle(
    x: r.nextDouble(),
    y: -0.05 - r.nextDouble() * 0.3,
    vx: (r.nextDouble() - 0.5) * 0.3,
    vy: 0.25 + r.nextDouble() * 0.45,
    spin: (r.nextDouble() - 0.5) * 12,
    size: 6 + r.nextDouble() * 6,
    color: colors[r.nextInt(colors.length)],
    round: r.nextBool(),
  );

  /// Start position and speed are fractions of the screen per second.
  final double x, y, vx, vy, spin, size;
  final Color color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.progress) : super(repaint: progress);

  static const double _gravity = 0.45;
  static const double _sway = 0.02;
  static const double _swayFrequency = 6;
  static const double _fadeStart = 0.75;

  final List<_Particle> particles;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final seconds =
        progress.value * ConfettiBurst.duration.inMilliseconds / 1000;
    final fade = progress.value < _fadeStart
        ? 1.0
        : 1 - (progress.value - _fadeStart) / (1 - _fadeStart);
    final paint = Paint();
    for (final p in particles) {
      final dx =
          p.x +
          p.vx * seconds +
          sin(seconds * _swayFrequency + p.x * 10) * _sway;
      final dy = p.y + p.vy * seconds + 0.5 * _gravity * seconds * seconds;
      paint.color = p.color.withValues(alpha: fade);
      canvas
        ..save()
        ..translate(dx * size.width, dy * size.height)
        ..rotate(p.spin * seconds);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size / 2,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}
