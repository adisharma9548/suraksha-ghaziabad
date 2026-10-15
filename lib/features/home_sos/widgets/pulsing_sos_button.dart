import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/ios_typography.dart';

/// Apple HIG Emergency SOS Button
/// High-contrast tactile emergency control with spring haptic feedback,
/// dual pulse rings, and accessible multi-cue states (never color alone).
class PulsingSosButton extends StatefulWidget {
  final VoidCallback onTriggerSos;
  final bool isSosActive;

  const PulsingSosButton({
    super.key,
    required this.onTriggerSos,
    this.isSosActive = false,
  });

  @override
  State<PulsingSosButton> createState() => _PulsingSosButtonState();
}

class _PulsingSosButtonState extends State<PulsingSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  double _pressProgress = 0.0;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.heavyImpact();
    setState(() {
      _isHolding = true;
      _pressProgress = 0.0;
    });
    _startHoldTimer();
  }

  void _onTapUp(TapUpDetails details) {
    if (_pressProgress < 1.0) {
      setState(() {
        _isHolding = false;
        _pressProgress = 0.0;
      });
      _showTapConfirmationDialog();
    }
  }

  void _onTapCancel() {
    setState(() {
      _isHolding = false;
      _pressProgress = 0.0;
    });
  }

  void _startHoldTimer() async {
    const totalSteps = 20;
    const stepDuration = Duration(milliseconds: 100); // 20 * 100ms = 2.0s

    for (int i = 1; i <= totalSteps; i++) {
      await Future.delayed(stepDuration);
      if (!_isHolding || !mounted) return;
      setState(() {
        _pressProgress = i / totalSteps;
      });
      if (i % 5 == 0) {
        HapticFeedback.mediumImpact();
      }
    }

    if (_isHolding && mounted) {
      HapticFeedback.vibrate();
      setState(() {
        _isHolding = false;
        _pressProgress = 0.0;
      });
      widget.onTriggerSos();
    }
  }

  void _showTapConfirmationDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 22),
            SizedBox(width: 8),
            Text('Confirm SOS Distress?'),
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'This will trigger an immediate emergency alert, stream live GPS to the police control room, and notify emergency contacts.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.vibrate();
              widget.onTriggerSos();
            },
            child: const Text('Trigger SOS Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBg = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final primaryFg = isDark ? Colors.black : Colors.white;
    final ringColor = isDark ? Colors.white : Colors.black;

    return Semantics(
      button: true,
      label: 'Emergency SOS button. Double tap to confirm or hold for 2 seconds to activate.',
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = widget.isSosActive ? 1.04 : _pulseAnimation.value;

          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer subtle pulse ring
                  Container(
                    width: 204,
                    height: 204,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ringColor.withOpacity(0.12),
                        width: 2.0,
                      ),
                    ),
                  ),

                  // Middle tactile ring
                  Container(
                    width: 184,
                    height: 184,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ringColor.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // Hold progress indicator
                  if (_isHolding)
                    SizedBox(
                      width: 174,
                      height: 174,
                      child: CircularProgressIndicator(
                        value: _pressProgress,
                        strokeWidth: 4.5,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                      ),
                    ),

                  // Main 160pt Tactile SOS Core Button
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryBg,
                      border: Border.all(
                        color: isDark ? const Color(0xFFE5E5EA) : const Color(0xFF2C2C2E),
                        width: 3.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.4 : 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.radiowaves_right,
                            color: primaryFg,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SOS',
                            style: IosTypography.largeTitle(
                              color: primaryFg,
                              weight: FontWeight.w900,
                            ).copyWith(letterSpacing: 2.0),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isHolding ? 'HOLDING...' : 'HOLD 2s',
                            style: IosTypography.caption2(
                              color: primaryFg.withOpacity(0.75),
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
