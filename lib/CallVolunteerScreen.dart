// import 'package:flutter/material.dart';
// class CallVolunteerScreen extends StatelessWidget {
//   const CallVolunteerScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Connecting to Volunteer'),
//         centerTitle: true,
//       ),
//
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             /// 🔄 Animation Icon
//             const CircularProgressIndicator(
//               color: Colors.deepPurple,
//               strokeWidth: 6,
//             ),
//
//             const SizedBox(height: 30),
//
//             const Text(
//               'Calling available volunteers...',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             const SizedBox(height: 10),
//
//             const Text(
//               'You will be connected as soon as a volunteer answers.',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.white70,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             const SizedBox(height: 40),
//
//             /// ❌ Cancel Call
//             ElevatedButton.icon(
//               icon: const Icon(Icons.call_end),
//               label: const Text('Cancel Call'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 30,
//                   vertical: 14,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CallVolunteerScreen extends StatefulWidget {
  final String? callId; // Required

  const CallVolunteerScreen({super.key, this.callId});

  @override
  State<CallVolunteerScreen> createState() => _CallVolunteerScreenState();
}

class _CallVolunteerScreenState extends State<CallVolunteerScreen> {
  Timer? _callTimer;
  final FlutterTts _tts = FlutterTts();
  String _statusMessage = "Calling available volunteers...";
  bool _showAlternativeOptions = false;

  @override
  void initState() {
    super.initState();
    if (widget.callId != null) {
      print("Call ID: ${widget.callId}");
    }
    _startCallTimeout();
    _simulateVolunteerResponse();
  }

  /// ⏳ 30 sec timeout
  void _startCallTimeout() {
    _callTimer = Timer(const Duration(seconds: 30), () async {
      _handleVolunteerUnavailable();
    });
  }

  /// 🔄 Simulate volunteer response
  void _simulateVolunteerResponse() {
    int delaySeconds = 5 + (15 * (DateTime.now().millisecond % 100) / 100).round();

    Timer(Duration(seconds: delaySeconds), () async {
      bool accepted = DateTime.now().millisecond % 2 == 0;

      _callTimer?.cancel();

      if (accepted) {
        setState(() {
          _statusMessage = "Volunteer connected.";
          _showAlternativeOptions = false;
        });
        await _tts.speak(_statusMessage);
        if (mounted) Navigator.pop(context);
      } else {
        _handleVolunteerUnavailable();
      }
    });
  }

  /// Handle volunteer unavailable scenario
  void _handleVolunteerUnavailable() async {
    setState(() {
      _statusMessage =
      "Volunteer is unavailable. You can use AI scene description or offline help.";
      _showAlternativeOptions = true;
    });

    await _tts.speak(_statusMessage);
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connecting to Volunteer'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.deepPurple,
              strokeWidth: 6,
            ),
            const SizedBox(height: 30),
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            /// ❌ Cancel Call
            ElevatedButton.icon(
              icon: const Icon(Icons.call_end),
              label: const Text('Cancel Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                _callTimer?.cancel();
                setState(() {
                  _statusMessage =
                  "Call cancelled. You can use AI scene description or offline help.";
                  _showAlternativeOptions = true;
                });
                await _tts.speak(_statusMessage);
              },
            ),

            /// ⚡ Alternative Options if volunteer unavailable
            if (_showAlternativeOptions) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.info),
                label: const Text('AI Scene Description'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // TODO: integrate AI scene description logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI Scene Description activated')),
                  );
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Offline Help'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // TODO: provide offline help, like emergency contacts
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offline Help activated')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}