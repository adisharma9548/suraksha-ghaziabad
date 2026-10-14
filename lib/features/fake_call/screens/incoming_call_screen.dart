import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerName;

  const IncomingCallScreen({super.key, required this.callerName});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  bool _isCallActive = false;
  int _callDurationSeconds = 0;
  Timer? _callDurationTimer;
  Timer? _vibrateTimer;

  @override
  void initState() {
    super.initState();
    // Simulate periodic phone vibration ring
    _vibrateTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!_isCallActive && mounted) {
        HapticFeedback.vibrate();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _callDurationTimer?.cancel();
    _vibrateTimer?.cancel();
    super.dispose();
  }

  void _answerCall() {
    _vibrateTimer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _isCallActive = true;
    });

    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _callDurationSeconds++);
      }
    });
  }

  void _endCall() {
    _vibrateTimer?.cancel();
    _callDurationTimer?.cancel();
    HapticFeedback.lightImpact();
    context.pop();
  }

  String _formatCallDuration(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B1F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Caller Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF332F37),
              child: const Icon(Icons.person, size: 54, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // Caller Name
            Text(
              widget.callerName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),

            // Call Status Subtitle
            Text(
              _isCallActive
                  ? _formatCallDuration(_callDurationSeconds)
                  : 'Incoming Call • Mobile',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white60,
              ),
            ),
            const Spacer(),

            if (_isCallActive) ...[
              // In-Call Dialog Script Box
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2930),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: const [
                    Text(
                      '"Haan beta, kahan ho? Main bas 2 minute mein car leke pahunch raha hoon. Wait karna, kisi se baat mat karna."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Active Call Options Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallActionIcon(icon: Icons.mic_off, label: 'Mute'),
                  _CallActionIcon(icon: Icons.dialpad, label: 'Keypad'),
                  _CallActionIcon(icon: Icons.volume_up, label: 'Speaker'),
                ],
              ),
              const SizedBox(height: 50),

              // End Call Red Button
              FloatingActionButton(
                backgroundColor: AppColors.sosRed,
                elevation: 4,
                onPressed: _endCall,
                child: const Icon(Icons.call_end, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 40),
            ] else ...[
              // Ringing Accept / Decline Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Decline
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'decline_btn',
                          backgroundColor: AppColors.sosRed,
                          elevation: 4,
                          onPressed: _endCall,
                          child: const Icon(Icons.call_end, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 10),
                        const Text('Decline', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),

                    // Accept
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'accept_btn',
                          backgroundColor: AppColors.safeGreen,
                          elevation: 6,
                          onPressed: _answerCall,
                          child: const Icon(Icons.call, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 10),
                        const Text('Answer', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CallActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CallActionIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xFF2B2930),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
      ],
    );
  }
}
