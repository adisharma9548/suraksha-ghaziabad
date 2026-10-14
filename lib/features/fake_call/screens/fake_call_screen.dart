import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discreet Fake Call', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.safeGreenLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_in_talk_rounded,
                    size: 40,
                    color: AppColors.safeGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Simulate an Incoming Call',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Schedule a realistic phone call to provide an excuse to step away from uncomfortable or suspicious surroundings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.35),
              ),
              const SizedBox(height: 28),

              // Caller Name
              TextField(
                controller: _callerController,
                decoration: const InputDecoration(
                  labelText: 'Caller Name',
                  prefixIcon: Icon(Icons.person, color: AppColors.primaryPurple),
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                children: _quickCallers.map((name) {
                  return ActionChip(
                    label: Text(name),
                    backgroundColor: Colors.white,
                    onPressed: () => setState(() => _callerController.text = name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Trigger Delay
              const Text(
                'Call Delay',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [5, 15, 30, 60].map((sec) {
                  final isSelected = sec == _delaySeconds;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppColors.primaryPurpleSurface
                              : Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryPurple
                                : AppColors.dividerLight,
                          ),
                          minimumSize: const Size(0, 44),
                        ),
                        onPressed: () => setState(() => _delaySeconds = sec),
                        child: Text(
                          '${sec}s',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primaryPurple
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              if (_isScheduled) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.safeGreenLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.safeGreen),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Call incoming in $_secondsRemaining seconds...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.safeGreenDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lock phone or keep app open. Fullscreen caller screen will trigger automatically.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _cancelSchedule,
                  child: const Text('Cancel Scheduled Call'),
                ),
              ] else ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safeGreen,
                  ),
                  icon: const Icon(Icons.ring_volume_rounded),
                  label: Text('Trigger Call in ${_delaySeconds}s'),
                  onPressed: _scheduleCall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
