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
import 'CallScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class CallVolunteerScreen extends StatefulWidget {
  const CallVolunteerScreen({super.key});

  @override
  State<CallVolunteerScreen> createState() => _CallVolunteerScreenState();
}

class _CallVolunteerScreenState extends State<CallVolunteerScreen> {
  final FlutterTts _tts = FlutterTts();

  String _status = "requesting";
  bool _showAlternativeOptions = false;
  int _waitingTime = 0;

  String? _sessionId;
  String? _requestId;
  String? _volunteerId;

  StreamSubscription? _requestSub;
  StreamSubscription? _sessionSub;
  Timer? _waitingTimer;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _createRequestAndListen();
    _startWaitingTimer();
  }

  // ================= CREATE REQUEST & LISTEN =================
  Future<void> _createRequestAndListen() async {
    try {
      String userId = currentUid ?? 'blind_user';

      // Get location
      Position? location;
      try {
        location = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        print('Location error: $e');
      }

      // Create request in global collection
      DocumentReference requestDoc =
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': userId,
        'type': 'help',
        'status': 'pending',
        'priority': 'normal',
        'location': {
          'latitude': location?.latitude ?? 0.0,
          'longitude': location?.longitude ?? 0.0,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      _requestId = requestDoc.id;
      print('✅ Request created: $_requestId');

      // Also log in user's subcollection
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(userId)
          .collection('call')
          .add({
        'requestId': _requestId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _status = 'waiting for volunteer');
      }
      await _tts.speak("Searching for volunteer....");

      _listenForVolunteerAccept();
    } catch (e) {
      print('❌ Request creation error: $e');
      _showError("Error creating request: $e");
    }
  }

  // ================= LISTEN FOR VOLUNTEER ACCEPT =================
  void _listenForVolunteerAccept() {
    if (_requestId == null) return;

    _requestSub = FirebaseFirestore.instance
        .collection('requests')
        .doc(_requestId)
        .snapshots()
        .listen(
          (snapshot) async {
        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>;

        if (mounted) {
          setState(() => _status = data['status'] ?? 'pending');
        }

        final incomingSessionId = data['sessionId'] as String?;
        final incomingVolunteerId = data['volunteerId'] as String?;

        // Volunteer accepted and created session
        if (data['status'] == 'accepted' &&
            incomingSessionId != null &&
            _sessionId == null) {
          print('✅ Volunteer accepted! Session: $incomingSessionId');

          _volunteerId = incomingVolunteerId;
          _sessionId = incomingSessionId;

          _stopWaitingTimer();
          if (mounted) {
            setState(() => _status = 'connecting');
          }

          await _tts.speak("Volunteer connected. Starting video call");

          // Session status ko listen karein
          _listenSession();
        }

        // Call rejected
        if (data['status'] == 'rejected') {
          print('❌ Volunteer rejected');
          await _tts.speak("Volunteer rejected the call");
          if (mounted) {
            setState(() => _showAlternativeOptions = true);
          }
        }
      },
      onError: (e) => print('❌ Request listener error: $e'),
    );
  }

  // ================= LISTEN SESSION STATUS =================
  void _listenSession() {
    if (_sessionId == null) return;

    _sessionSub = FirebaseFirestore.instance
        .collection('sessions')
        .doc(_sessionId)
        .snapshots()
        .listen(
          (snapshot) {
        if (!snapshot.exists) return;
        final data = snapshot.data();
        if (data == null) return;

        final status = data['status'] as String?;

        if (mounted) {
          setState(() => _status = status ?? 'connecting');
        }

        print('📱 Session status: $status');

        // Volunteer ne accept kar liya (Status 'waiting' ya 'active' hai) -> Navigate to CallScreen
        if ((status == 'waiting' || status == 'active') && mounted) {
          print('✅ Call active - navigating to call screen');

          // Streams cancel karein navigation se pehle
          _cleanupListeners();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CallScreen(
                sessionId: _sessionId,
                volunteerId: _volunteerId,
                userType: 'blind',
              ),
            ),
          );
        }

        // Call ended
        if (status == 'ended') {
          print('☎️ Call ended');
          if (mounted) {
            setState(() => _showAlternativeOptions = true);
          }
          _cleanup();
        }
      },
      onError: (e) => print('❌ Session listener error: $e'),
    );
  }

  // ================= WAITING TIMER =================
  void _startWaitingTimer() {
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _waitingTime++);
      }

      // 60 second timeout
      if (_waitingTime >= 60) {
        _stopWaitingTimer();
        _showError("No volunteer available. Please try again.");
        _cancelCall();
      }
    });
  }

  void _stopWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = null;
  }

  // ================= CANCEL CALL =================
  Future<void> _cancelCall() async {
    try {
      if (_requestId != null) {
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(_requestId)
            .update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      }

      if (_sessionId != null) {
        await FirebaseFirestore.instance
            .collection('sessions')
            .doc(_sessionId)
            .update({
          'status': 'ended',
          'endedAt': FieldValue.serverTimestamp(),
        });
      }

      await _tts.speak("Call cancelled");
      _cleanup();

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      print('❌ Cancel call error: $e');
      if (mounted && Navigator.canPop(context)) Navigator.of(context).pop();
    }
  }

  void _cleanupListeners() {
    _stopWaitingTimer();
    _requestSub?.cancel();
    _sessionSub?.cancel();
  }

  void _cleanup() {
    _cleanupListeners();
  }

  void _showError(String msg) {
    if (!mounted) return;
    print('⚠️ Error: $msg');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatWaitingTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _cleanup();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connecting to Volunteer....'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 30),
            Text(
              _status,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Waiting time: ${_formatWaitingTime(_waitingTime)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _cancelCall,
              icon: const Icon(Icons.call_end),
              label: const Text("Cancel Call"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
            if (_showAlternativeOptions) ...[
              const SizedBox(height: 40),
              const Text(
                "Alternative Options:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/scene'),
                    child: const Text("Scene Description"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/offline'),
                    child: const Text("Offline Help"),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}