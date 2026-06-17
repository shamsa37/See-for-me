// import 'package:flutter/material.dart';
// import 'incoming_volunteer_call_screen.dart';
// import 'VolunteerVideoConnectedScreen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:project/services/session_service.dart';
//
// class CallScreen extends StatefulWidget {
//   final String contactName;
//
//   const CallScreen({
//     super.key,
//     this.contactName = "Blind User",
//   });
//
//   @override
//   State<CallScreen> createState() => _CallScreenState();
//   @override
//   void initState() {
//     super.initState();
//     _listenForCalls();
//   }
// }
//
// class _CallScreenState extends State<CallScreen> {
//
//   int _selectedIndex = 1;
//   bool _isIncomingCall = true;
//   Stream<QuerySnapshot>? _callStream;
//   String? _sessionId;
//   void _listenForCalls() {
//     _callStream = FirebaseFirestore.instance
//         .collection('sessions')
//         .where('status', isEqualTo: 'waiting')
//         .snapshots();
//
//     _callStream!.listen((snapshot) {
//       if (snapshot.docs.isNotEmpty) {
//         final doc = snapshot.docs.first;
//
//         setState(() {
//           _isIncomingCall = true;
//           _sessionId = doc.id;
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screens = [
//       const Center(
//         child: Text("No Call History",
//             style: TextStyle(color: Colors.white)),
//       ),
//
//       // 🔥 ACTIVE CALL TAB
//       _isIncomingCall
//           ? IncomingVolunteerCallScreen(
//         onAccept: () async {
//           final sessionService = SessionService();
//
//           if (_sessionId != null) {
//             await sessionService.acceptCall(_sessionId!, "volunteer_1");
//           }
//
//           setState(() {
//             _isIncomingCall = false;
//           });
//
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => VolunteerVideoConnectedScreen(
//                 blindName: widget.contactName,
//                 volunteerName: "Volunteer",
//               ),
//             ),
//           );
//         },
//         onReject: () {
//           setState(() {
//             _isIncomingCall = false;
//           });
//         },
//       )
//           : const Center(
//         child: Text("No Active Call",
//             style: TextStyle(color: Colors.white)),
//       ),
//
//       const Center(
//         child: Text("No Scheduled Calls",
//             style: TextStyle(color: Colors.white)),
//       ),
//     ];
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Call Screen")),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black, Colors.deepPurple],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: screens[_selectedIndex],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.black,
//         selectedItemColor: Colors.purpleAccent,
//         unselectedItemColor: Colors.white70,
//         currentIndex: _selectedIndex,
//         onTap: (i) => setState(() => _selectedIndex = i),
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.history), label: "Call Back"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.call), label: "Active Call"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.schedule), label: "Scheduled"),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class CallScreen extends StatefulWidget {
  final String? contactName;
  final String? sessionId;

  const CallScreen({
    Key? key,
    this.contactName = "Blind User",
    this.sessionId,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isLoudspeaker = false;
  int _callDuration = 0;

  RTCVideoRenderer? _remoteRenderer;
  RTCVideoRenderer? _localRenderer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  StreamSubscription? _sessionSub;

  // 🔔 RINGING
  AudioPlayer _player = AudioPlayer();
  bool _isRinging = false;
  bool _incomingCall = false;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
    _initializeWebRTC();
    _listenSession();
  }

  // ================= WEBRTC INIT =================
  Future<void> _initializeWebRTC() async {
    _remoteRenderer = RTCVideoRenderer();
    _localRenderer = RTCVideoRenderer();

    await _remoteRenderer!.initialize();
    await _localRenderer!.initialize();

    final config = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ]
    };

    _peerConnection = await createPeerConnection(config);

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    // Remote stream
    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer!.srcObject = event.streams[0];
      }
    };

    // ICE SEND
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate == null || widget.sessionId == null) return;

      FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .collection('calleeCandidates')
          .add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };
  }

  // ================= SESSION LISTENER =================
  void _listenSession() {
    _sessionSub = FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .snapshots()
        .listen((snapshot) async {
      final data = snapshot.data();
      if (data == null) return;

      // 🔔 RINGING TRIGGER
      if (data['offer'] != null && data['status'] == "waiting") {
        _startRinging();
        await _handleOffer(data['offer']);
      }

      // ACTIVE CALL
      if (data['status'] == "active") {
        _stopRinging();
      }

      // END CALL
      if (data['status'] == "ended") {
        _stopRinging();
        _endCall();
      }
    });
  }

  // ================= HANDLE OFFER =================
  Future<void> _handleOffer(dynamic offer) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(
        offer['sdp'],
        offer['type'],
      ),
    );

    // Create answer
    RTCSessionDescription answer =
    await _peerConnection!.createAnswer();

    await _peerConnection!.setLocalDescription(answer);

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .update({
      "answer": {
        "type": answer.type,
        "sdp": answer.sdp,
      }
    });
  }

  // ================= RINGING START =================
  Future<void> _startRinging() async {
    if (_isRinging) return;

    _isRinging = true;
    _incomingCall = true;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource("ringtone.mp3"));

    setState(() {});
  }

  // ================= RINGING STOP =================
  Future<void> _stopRinging() async {
    _isRinging = false;
    _incomingCall = false;

    await _player.stop();

    if (mounted) setState(() {});
  }

  // ================= ACCEPT CALL =================
  Future<void> _acceptCall() async {
    await _stopRinging();

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .update({
      "status": "active"
    });
  }

  // ================= REJECT CALL =================
  Future<void> _rejectCall() async {
    await _stopRinging();

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .update({
      "status": "ended"
    });
  }

  // ================= END CALL =================
  Future<void> _endCall() async {
    _remoteRenderer?.dispose();
    _localRenderer?.dispose();
    _peerConnection?.close();
    _sessionSub?.cancel();

    if (mounted) Navigator.pop(context);
  }

  // ================= TIMER =================
  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _callDuration++;
      });

      _startCallTimer();
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopRinging();
    _remoteRenderer?.dispose();
    _localRenderer?.dispose();
    _peerConnection?.close();
    _sessionSub?.cancel();
    super.dispose();
  }

  // ================= UI (UNCHANGED + RINGING ADDED) =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call"),
        centerTitle: true,
      ),
      body: Stack(
        children: [

          // 🔔 INCOMING CALL UI
          if (_incomingCall)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.call,
                        color: Colors.green, size: 60),
                    const SizedBox(height: 10),
                    const Text(
                      "Incoming Call......",
                      style: TextStyle(
                          color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _acceptCall,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text("Accept"),
                        ),
                        ElevatedButton(
                          onPressed: _rejectCall,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text("Reject"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

          // 📹 REMOTE VIDEO
          _remoteRenderer != null
              ? RTCVideoView(_remoteRenderer!)
              : Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.videocam_off,
                  color: Colors.white, size: 80),
            ),
          ),

          // 📷 LOCAL VIDEO
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              child: _localRenderer != null
                  ? RTCVideoView(_localRenderer!)
                  : Container(color: Colors.grey),
            ),
          ),

          // ⏱ TIMER
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              _formatDuration(_callDuration),
              style: const TextStyle(
                  color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}