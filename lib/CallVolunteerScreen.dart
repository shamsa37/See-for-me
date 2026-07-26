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
import 'package:flutter_webrtc/flutter_webrtc.dart';
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
  StreamSubscription? _answerSub;
  StreamSubscription? _iceSub;
  Timer? _waitingTimer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCVideoRenderer? _localRenderer;

  bool _remoteDescriptionSet = false;
  bool _signalingStarted = false;

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

      setState(() => _status = 'waiting for volunteer');
      await _tts.speak("Searching for volunteer....");

      _listenForVolunteerAccept();
    } catch (e) {
      print('❌ Request creation error: $e');
      _showError("Error creating request: $e");
    }
  }

  // ================= LISTEN FOR VOLUNTEER ACCEPT =================
  void _listenForVolunteerAccept() {
    _requestSub = FirebaseFirestore.instance
        .collection('requests')
        .doc(_requestId)
        .snapshots()
        .listen(
          (snapshot) async {
        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>;

        setState(() => _status = data['status'] ?? 'pending');

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
          setState(() => _status = 'connecting');

          await _tts.speak("Volunteer connected. Starting video call");

          // Start signaling on existing session
          await _startSignaling();
        }

        // Call rejected
        if (data['status'] == 'rejected') {
          print('❌ Volunteer rejected');
          await _tts.speak("Volunteer rejected the call");
          setState(() => _showAlternativeOptions = true);
        }
      },
      onError: (e) => print('❌ Request listener error: $e'),
    );
  }

  // ================= START SIGNALING =================
  Future<void> _startSignaling() async {
    if (_signalingStarted) return;
    _signalingStarted = true;

    try {
      await _initWebRTC();
      await _createOffer();
      _listenSession();
      _listenAnswer();
      _listenIceCandidates();

      print('✅ Signaling started');
    } catch (e) {
      print('❌ Signaling error: $e');
      _showError("Connection error: $e");
    }
  }

  // ================= WEBRTC INITIALIZATION =================
  Future<void> _initWebRTC() async {
    try {
      final config = {
        "iceServers": [
          {"urls": ["stun:stun.l.google.com:19302"]},
          {"urls": ["stun:stun1.l.google.com:19302"]},
        ]
      };

      final mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '320',
            'minHeight': '240',
            'minFrameRate': '15',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      _peerConnection = await createPeerConnection(config, mediaConstraints);

      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      // Add tracks to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      print('✅ WebRTC initialized');

      // Handle ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate == null || _sessionId == null) return;

        FirebaseFirestore.instance
            .collection('sessions')
            .doc(_sessionId)
            .collection('callerCandidates')
            .add({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'timestamp': FieldValue.serverTimestamp(),
        }).catchError((e) => print('❌ ICE candidate add error: $e'));
      };

      // Handle remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        print('🎥 Remote track received: ${event.track.kind}');
      };

      print('✅ Media stream acquired');
    } catch (e) {
      print('❌ WebRTC init error: $e');
      throw Exception('Failed to initialize WebRTC: $e');
    }
  }

  // ================= CREATE OFFER =================
  Future<void> _createOffer() async {
    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();

      await _peerConnection!.setLocalDescription(offer);

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(_sessionId)
          .update({
        'offer': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
        'status': 'waiting',
        'offerCreatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Offer created and sent');
    } catch (e) {
      print('❌ Create offer error: $e');
      throw Exception('Failed to create offer: $e');
    }
  }

  // ================= LISTEN FOR ANSWER =================
  void _listenAnswer() {
    _answerSub = FirebaseFirestore.instance
        .collection('sessions')
        .doc(_sessionId)
        .snapshots()
        .listen(
          (doc) async {
        final data = doc.data();
        if (data == null) return;

        // Set remote description once answer arrives
        if (data['answer'] != null &&
            !_remoteDescriptionSet &&
            _peerConnection != null) {
          try {
            _remoteDescriptionSet = true;

            await _peerConnection!.setRemoteDescription(
              RTCSessionDescription(
                data['answer']['sdp'],
                data['answer']['type'],
              ),
            );

            print('✅ Answer received and set');
          } catch (e) {
            print('❌ Set remote description error: $e');
          }
        }
      },
      onError: (e) => print('❌ Answer listener error: $e'),
    );
  }

  // ================= LISTEN FOR ICE CANDIDATES =================
  void _listenIceCandidates() {
    _iceSub = FirebaseFirestore.instance
        .collection('sessions')
        .doc(_sessionId)
        .collection('calleeCandidates')
        .snapshots()
        .listen(
          (snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data == null || _peerConnection == null) continue;

            try {
              _peerConnection!.addCandidate(
                RTCIceCandidate(
                  data['candidate'],
                  data['sdpMid'],
                  data['sdpMLineIndex'],
                ),
              );
              print('✅ ICE candidate added');
            } catch (e) {
              print('❌ Add ICE candidate error: $e');
            }
          }
        }
      },
      onError: (e) => print('❌ ICE listener error: $e'),
    );
  }

  // ================= LISTEN SESSION STATUS =================
  void _listenSession() {
    _sessionSub = FirebaseFirestore.instance
        .collection('sessions')
        .doc(_sessionId)
        .snapshots()
        .listen(
          (snapshot) {
        final data = snapshot.data();
        if (data == null) return;

        final status = data['status'] as String?;

        setState(() => _status = status ?? 'connecting');

        print('📱 Session status: $status');

        // Call is active - navigate to call screen
        if (status == 'active') {
          print('✅ Call active - navigating to call screen');

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

          setState(() => _showAlternativeOptions = true);

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
      // Update request status
      if (_requestId != null) {
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(_requestId)
            .update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      }

      // Update session status if exists
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
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ================= CLEANUP =================
  void _cleanup() {
    _stopWaitingTimer();
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();
    _requestSub?.cancel();
    _sessionSub?.cancel();
    _answerSub?.cancel();
    _iceSub?.cancel();
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
            const CircularProgressIndicator(
              strokeWidth: 3,
            ),
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