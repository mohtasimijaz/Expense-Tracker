import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';

/// Subtle gradient background decorated with soft blobs and faint
/// finance icons (coins, charts, wallets). Purely decorative.
class FinanceBackground extends StatelessWidget {
  /// Wraps [child] with the decorative background.
  const FinanceBackground({super.key, required this.child});

  final Widget child;

  // (alignment x, alignment y, icon, size) for the faint decorations.
  static const List<(double, double, IconData, double)> _icons = [
    (-0.85, -0.55, Icons.savings_outlined, 54),
    (0.9, -0.2, Icons.trending_up_rounded, 46),
    (-0.75, 0.35, Icons.account_balance_wallet_outlined, 50),
    (0.82, 0.62, Icons.pie_chart_outline_rounded, 58),
    (0.05, 0.92, Icons.receipt_long_outlined, 40),
  ];

  static const double _blobLarge = 320;
  static const double _blobSmall = 220;
  static const double _blobOpacity = 0.10;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final decoration = palette.decoration;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: palette.backgroundGradient),
      child: Stack(
        children: [
          Positioned(
            top: -_blobLarge / 3,
            right: -_blobLarge / 3,
            child: _Blob(size: _blobLarge, color: decoration),
          ),
          Positioned(
            bottom: -_blobSmall / 4,
            left: -_blobSmall / 3,
            child: _Blob(
              size: _blobSmall,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          for (final (x, y, icon, size) in _icons)
            Align(
              alignment: Alignment(x, y),
              child: Icon(
                icon,
                size: size,
                color: decoration.withValues(
                  alpha: AppEffects.decorationOpacity,
                ),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: FinanceBackground._blobOpacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
