import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_haptics.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import '../utils/share_image.dart';
import '../widgets/common/app_feedback.dart';
import '../widgets/recap/recap_slide_view.dart';
import '../widgets/recap/recap_slides.dart';
import '../widgets/recap/story_progress.dart';

/// "Wrapped"-style story of a month: tap right/left to move, hold to
/// pause, share any slide as an image.
class RecapScreen extends StatefulWidget {
  /// Creates the recap for [month].
  const RecapScreen({super.key, required this.month});

  final DateTime month;

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _slideDuration = Duration(seconds: 5);
  static const double _backZone = 1 / 3;

  final ValueNotifier<int> _index = ValueNotifier(0);
  final GlobalKey _captureKey = GlobalKey();
  final GlobalKey _shareKey = GlobalKey();
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _slideDuration,
  )..addStatusListener(_onProgress);
  late List<RecapSlide> _slides;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final recap = context.read<ExpenseProvider>().insights.recap(widget.month);
    _slides = RecapSlides.build(
      recap,
      context.read<SettingsProvider>().formatter,
    );
    if (AppMotion.enabled(context) && !_progress.isAnimating) {
      _progress.forward();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _index.dispose();
    super.dispose();
  }

  void _onProgress(AnimationStatus status) {
    if (status == AnimationStatus.completed) _go(1);
  }

  void _go(int delta) {
    final next = _index.value + delta;
    if (next < 0 || next >= _slides.length) return;
    AppHaptics.play(context, HapticKind.selection);
    _index.value = next;
    _progress.reset();
    if (AppMotion.enabled(context)) _progress.forward();
  }

  void _onTap(TapUpDetails details, double width) =>
      _go(details.localPosition.dx < width * _backZone ? -1 : 1);

  Future<void> _share() async {
    _progress.stop();
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final month = AppDateFormat.monthYear(widget.month);
    final ok = await ShareImage.share(
      _captureKey,
      fileName: 'expense-recap-${widget.month.year}-${widget.month.month}.png',
      text: AppStrings.recapShareText(month),
      origin: origin,
    );
    if (!mounted) return;
    if (!ok) {
      AppFeedback.showSnack(context, AppStrings.errorShare, isError: true);
    }
    if (AppMotion.enabled(context)) _progress.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _onTap(d, constraints.maxWidth),
          onLongPressStart: (_) => _progress.stop(),
          onLongPressEnd: (_) {
            if (AppMotion.enabled(context)) _progress.forward();
          },
          child: ValueListenableBuilder<int>(
            valueListenable: _index,
            builder: (context, index, _) => Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    key: _captureKey,
                    child: AnimatedSwitcher(
                      duration: AppDurations.medium,
                      child: RecapSlideView(
                        key: ValueKey(index),
                        slide: _slides[index],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        StoryProgress(
                          count: _slides.length,
                          index: index,
                          progress: _progress,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            tooltip: AppStrings.recapClose,
                            color: AppColors.white,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const Spacer(),
                        FilledButton.tonalIcon(
                          key: _shareKey,
                          onPressed: _share,
                          icon: const Icon(Icons.ios_share_rounded),
                          label: const Text(AppStrings.recapShare),
                        ),
                      ],
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
