import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/ios_typography.dart';

/// Native iOS Incoming Call Screen
/// Replicates the authentic iOS CallKit screen with multi-cue buttons, SF Pro scale, and tactile haptics.
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),

            // Caller Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF38383A)),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.person_fill,
                  size: 48,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Caller Name
            Text(
              widget.callerName,
              style: IosTypography.largeTitle(color: Colors.white),
            ),
            const SizedBox(height: 6),

            // Call Status Subtitle
            Text(
              _isCallActive
                  ? _formatCallDuration(_callDurationSeconds)
                  : 'iPhone • Mobile',
              style: IosTypography.subhead(color: const Color(0xFFAEAEB2)),
            ),

            const Spacer(),

            if (_isCallActive) ...[
              // In-Call Discreet Prompt Box
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF38383A)),
                ),
                child: Text(
                  '"Haan, main bas 2 minute mein pahunch raha hoon. Wait karna, gate ke paas khade rehna."',
                  textAlign: TextAlign.center,
                  style: IosTypography.callout(
                    color: Colors.white70,
                    style: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // In-call grid controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _InCallAction(icon: CupertinoIcons.mic_slash_fill, label: 'Mute'),
                        _InCallAction(icon: CupertinoIcons.circle_grid_3x3_fill, label: 'Keypad'),
                        _InCallAction(icon: CupertinoIcons.speaker_2_fill, label: 'Speaker'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _InCallAction(icon: CupertinoIcons.plus, label: 'Add Call'),
                        _InCallAction(icon: CupertinoIcons.video_camera_solid, label: 'FaceTime'),
                        _InCallAction(icon: CupertinoIcons.person_crop_circle_fill, label: 'Contacts'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // End Call button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _endCall,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C1C1E),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.phone_down_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'End Call',
                      style: IosTypography.caption1(color: Colors.white, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Native iOS Incoming Call Controls (Decline & Accept with multi-cue icons and text)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Decline
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _endCall,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF545458), width: 1.5),
                            ),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.phone_down_fill,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Decline',
                            style: IosTypography.footnote(color: Colors.white, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    // Accept
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _answerCall,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.phone_fill,
                                color: Colors.black,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Accept',
                            style: IosTypography.footnote(color: Colors.white, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _InCallAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InCallAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF38383A)),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: IosTypography.caption1(color: const Color(0xFFAEAEB2)),
        ),
      ],
    );
  }
}
