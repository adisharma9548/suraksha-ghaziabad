import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';

/// Native iOS Fake Call Screen
/// Discreet incoming call simulator designed to Apple HIG standards.
class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  final _callerController = TextEditingController(text: 'Papa');
  int _delaySeconds = 5;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  bool _isScheduled = false;

  final List<String> _quickCallers = [
    'Papa',
    'Maa',
    'Bhaiya',
    'Advocate Sharma',
    'Inspector Verma',
  ];

  @override
  void dispose() {
    _callerController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _scheduleCall() {
    setState(() {
      _isScheduled = true;
      _secondsRemaining = _delaySeconds;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _isScheduled = false);
        context.push('/incoming-call', extra: _callerController.text.trim());
      }
    });
  }

  void _cancelSchedule() {
    _countdownTimer?.cancel();
    setState(() {
      _isScheduled = false;
      _secondsRemaining = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        title: Text('Discreet Fake Call', style: IosTypography.headline(color: primaryTextColor)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.secondarySurfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.phone_fill,
                      size: 36,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Simulate an Incoming Call',
                textAlign: TextAlign.center,
                style: IosTypography.title2(color: primaryTextColor),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Trigger a realistic iOS incoming call to discreetly disengage from uncomfortable surroundings.',
                  textAlign: TextAlign.center,
                  style: IosTypography.subhead(color: secondaryTextColor),
                ),
              ),
              const SizedBox(height: 24),

              // Grouped Section: Caller Info
              IosGroupedSection(
                header: 'CALLER DISPLAY IDENTITY',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CupertinoTextField(
                          controller: _callerController,
                          placeholder: 'Caller Name',
                          placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                          style: IosTypography.callout(color: primaryTextColor),
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Icon(CupertinoIcons.person_fill, size: 18, color: primaryTextColor),
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondaryBackgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Suggested Contacts', style: IosTypography.footnote(color: secondaryTextColor)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _quickCallers.map((name) {
                            final isCurrent = _callerController.text == name;
                            return CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 32,
                              onPressed: () => setState(() => _callerController.text = name),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? primaryTextColor
                                      : (isDark ? AppColors.surfaceDark : AppColors.secondaryBackgroundLight),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCurrent
                                        ? primaryTextColor
                                        : (isDark ? AppColors.separatorDark : AppColors.separatorLight),
                                  ),
                                ),
                                child: Text(
                                  name,
                                  style: IosTypography.caption1(
                                    color: isCurrent
                                        ? (isDark ? Colors.black : Colors.white)
                                        : primaryTextColor,
                                    weight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Grouped Section: Timing
              IosGroupedSection(
                header: 'TRIGGER DELAY',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [5, 15, 30, 60].map((sec) {
                        final isSelected = sec == _delaySeconds;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 36,
                              onPressed: () => setState(() => _delaySeconds = sec),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryTextColor
                                      : (isDark ? AppColors.surfaceDark : AppColors.secondaryBackgroundLight),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryTextColor
                                        : (isDark ? AppColors.separatorDark : AppColors.separatorLight),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${sec}s',
                                  style: IosTypography.subhead(
                                    color: isSelected
                                        ? (isDark ? Colors.black : Colors.white)
                                        : primaryTextColor,
                                    weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isScheduled
                    ? IosButton(
                        text: 'Cancel Countdown (${_secondsRemaining}s)',
                        icon: CupertinoIcons.clear_circled_solid,
                        type: IosButtonType.secondary,
                        onPressed: _cancelSchedule,
                      )
                    : IosButton(
                        text: 'Schedule Fake Call (${_delaySeconds}s)',
                        icon: CupertinoIcons.phone_fill,
                        type: IosButtonType.primary,
                        onPressed: _scheduleCall,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
