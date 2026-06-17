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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallVolunteerScreen extends StatefulWidget {
  const CallVolunteerScreen({super.key});

  @override
  State<CallVolunteerScreen> createState() => _CallVolunteerScreenState();
}

class _CallVolunteerScreenState extends State<CallVolunteerScreen> {
  final FlutterTts _tts = FlutterTts();

  String _status = "requesting";
  bool _showAlternativeOptions = false;

  String? _sessionId;
  String? _requestId;
  String? _volunteerId;

  StreamSubscription? _requestSub;
  StreamSubscription? _sessionSub;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _createSessionAndStart();
  }

  // ================= START =================
  Future<void> _createSessionAndStart() async {
    try {
      String userId =
          FirebaseAuth.instance.currentUser?.uid ?? 'blind_user';

      // 1️⃣ CREATE REQUEST
      DocumentReference requestDoc =
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': userId,
        'type': 'help',
        'status': 'pending',
        'timeStamp': FieldValue.serverTimestamp(),
      });

      _requestId = requestDoc.id;
      await _initWebRTC();
      _listenForVolunteerAccept();

      await _tts.speak("Searching for volunteer...");

    } catch (e) {
      _showError("Error: $e");
    }
  }

  // ================= VOLUNTEER ACCEPT =================
  void _listenForVolunteerAccept() {
    _requestSub = FirebaseFirestore.instance
        .collection('requests')
        .doc(_requestId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        _status = data['status'] ?? "pending";
      });

      if (data['status'] == 'accepted') {
        _volunteerId = data['volunteerId'];

        await _tts.speak("Volunteer connected");

        await _createSession();
      }
    });
  }

  // ================= SESSION CREATE =================
  Future<void> _createSession() async {
    try {
      String userId =
          FirebaseAuth.instance.currentUser?.uid ?? 'blind_user';

      DocumentReference sessionDoc =
      await FirebaseFirestore.instance.collection('sessions').add({
        'status': 'waiting',
        'userId': userId,
        'volunteerId': _volunteerId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _sessionId = sessionDoc.id;

      await _initWebRTC();
      await _createOffer();
      _listenSession();
      _listenAnswer();
      _listenIceCandidates();

    } catch (e) {
      _showError("Session error: $e");
    }
  }

  // ================= WEBRTC INIT =================
  Future<void> _initWebRTC() async {
    final config = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ]
    };

    _peerConnection =
    await createPeerConnection(config);

    _localStream =
    await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    // SEND ICE
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate == null || _sessionId == null) return;

      FirebaseFirestore.instance
          .collection('sessions')
          .doc(_sessionId)
          .collection('callerCandidates')
          .add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };
  }

  // ================= OFFER =================
  Future<void> _createOffer() async {
    RTCSessionDescription offer =
    await _peerConnection!.createOffer();

    await _peerConnection!.setLocalDescription(offer);

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(_sessionId)
        .update({
      "offer": {
        "type": offer.type,
        "sdp": offer.sdp,
      },
      "status": "waiting",
    });
  }

  // ================= ANSWER LISTENER =================
  void _listenAnswer() {
    FirebaseFirestore.instance
        .collection('sessions')
        .doc(_sessionId)
        .snapshots()
        .listen((doc) async {
      final data = doc.data();

      if (data == null) return;

      if (data['answer'] != null) {
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          ),
        );
      }
    });
  }

  // ================= ICE LISTENER =================
  void _listenIceCandidates() {
    FirebaseFirestore.instance
        .collection('sessions')
        .doc(_sessionId)
        .collection('calleeCandidates')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          _peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });
  }

  // ================= SESSION LISTENER =================
  void _listenSession() {
    _sessionSub = FirebaseFirestore.instance
        .collection('sessions')
        .doc(_sessionId)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      if (data == null) return;

      setState(() {
        _status = data['status'] ?? "waiting";
      });

      if (_status == "active") {
        Navigator.pushNamed(context, "/videoCall");
      }

      if (_status == "ended") {
        setState(() {
          _showAlternativeOptions = true;
        });
      }
    });
  }

  // ================= CANCEL =================
  Future<void> _cancelCall() async {
    if (_requestId != null) {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(_requestId)
          .update({'status': 'cancelled'});
    }

    if (_sessionId != null) {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(_sessionId)
          .update({'status': 'ended'});
    }

    await _tts.speak("Call cancelled");
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    _requestSub?.cancel();
    _sessionSub?.cancel();
    _peerConnection?.close();
    _localStream?.dispose();
    _tts.stop();
    super.dispose();
  }

  // ================= UI (UNCHANGED) =================
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
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_status,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _cancelCall,
              child: const Text("Cancel Call"),
            ),
          ],
        ),
      ),
    );
  }
}