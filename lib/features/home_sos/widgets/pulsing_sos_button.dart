import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
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
      // Show confirmation dialog for short tap
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
      if (i % 4 == 0) {
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.sosRed, size: 28),
            SizedBox(width: 8),
            Text('Confirm SOS Alert?'),
          ],
        ),
        content: const Text(
          'This will trigger an immediate emergency alert, notify police, and dispatch GPS coordinates to your emergency contacts.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sosRed),
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.vibrate();
              widget.onTriggerSos();
            },
            child: const Text('TRIGGER SOS NOW'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.isSosActive ? 1.05 : _pulseAnimation.value;

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow pulse
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sosRed.withOpacity(0.18),
                  ),
                ),
                // Mid pulse ring
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sosRed.withOpacity(0.3),
                  ),
                ),
                // Hold progress circular indicator
                if (_isHolding)
                  SizedBox(
                    width: 174,
                    height: 174,
                    child: CircularProgressIndicator(
                      value: _pressProgress,
                      strokeWidth: 6,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                // Main SOS Core Button (160dp)
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFF5252),
                        AppColors.sosRed,
                        AppColors.sosRedDark,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sosRed.withOpacity(0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emergency_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SOS',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          _isHolding ? 'HOLDING...' : 'HOLD 2 SEC',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.0,
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
    );
  }
}
