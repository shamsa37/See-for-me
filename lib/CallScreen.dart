//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'dart:async';
//
// class CallScreen extends StatefulWidget {
//   final String? contactName;
//   final String? sessionId;
//   final String? volunteerId;
//   final String userType; // 'blind' or 'volunteer'
//
//   const CallScreen({
//     Key? key,
//     this.contactName = "Blind User",
//     this.sessionId,
//     this.volunteerId,
//     this.userType = 'blind',
//   }) : super(key: key);
//
//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }
//
// class _CallScreenState extends State<CallScreen> {
//   bool _isMuted = false;
//   bool _isLoudspeaker = false;
//   int _callDuration = 0;
//   bool _callActive = false;
//
//   RTCVideoRenderer? _remoteRenderer;
//   RTCVideoRenderer? _localRenderer;
//
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//
//   StreamSubscription? _sessionSub;
//   StreamSubscription? _candidateSub;
//
//   late AudioPlayer _player;
//   bool _isRinging = false;
//   bool _incomingCall = false;
//   bool _offerCreated = false;
//
//   String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     _player = AudioPlayer(); // Properly initialize player instance
//
//     _startCallTimer();
//     _initAndListen();
//   }
//
//   Future<void> _initAndListen() async {
//     await _initializeWebRTC();
//
//     // Auto-create offer for blind user (caller)
//     if (widget.userType == 'blind' && widget.sessionId != null) {
//       Future.delayed(const Duration(milliseconds: 800), () async {
//         print('🟢 Blind user - Creating offer automatically');
//         await _createAndSendOffer();
//       });
//     }
//
//     _listenToSignaling();
//   }
//
//   // ================= WEBRTC INITIALIZATION =================
//   Future<void> _initializeWebRTC() async {
//     try {
//       _remoteRenderer = RTCVideoRenderer();
//       _localRenderer = RTCVideoRenderer();
//
//       await _remoteRenderer!.initialize();
//       await _localRenderer!.initialize();
//
//       final config = {
//         "iceServers": [
//           {"urls": ["stun:stun.l.google.com:19302"]},
//           {"urls": ["stun:stun1.l.google.com:19302"]},
//         ]
//       };
//
//       final mediaConstraints = {
//         'audio': true,
//         'video': {
//           'mandatory': {
//             'minWidth': '320',
//             'minHeight': '240',
//             'minFrameRate': '15',
//           },
//           'facingMode': 'user',
//           'optional': [],
//         }
//       };
//
//       _peerConnection = await createPeerConnection(config, mediaConstraints);
//
//       // Get local stream
//       _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
//
//       // Add tracks to peer connection
//       _localStream!.getTracks().forEach((track) {
//         _peerConnection!.addTrack(track, _localStream!);
//       });
//
//       // Set local renderer
//       if (mounted) {
//         setState(() {
//           _localRenderer!.srcObject = _localStream;
//         });
//       }
//
//       // Handle remote stream
//       _peerConnection!.onTrack = (RTCTrackEvent event) {
//         print('🎥 Remote track received: ${event.track.kind}');
//         if (event.streams.isNotEmpty && mounted) {
//           setState(() {
//             _remoteRenderer!.srcObject = event.streams[0];
//           });
//         }
//       };
//
//       // Handle ICE candidates safely
//       _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
//         if (candidate == null || widget.sessionId == null) return;
//
//         String candidateCollection = widget.userType == 'blind'
//             ? 'callerCandidates'
//             : 'calleeCandidates';
//
//         FirebaseFirestore.instance
//             .collection('sessions')
//             .doc(widget.sessionId)
//             .collection(candidateCollection)
//             .add({
//           'candidate': candidate.candidate,
//           'sdpMid': candidate.sdpMid,
//           'sdpMLineIndex': candidate.sdpMLineIndex,
//           'timestamp': FieldValue.serverTimestamp(),
//         }).catchError((e) => print('❌ ICE candidate error: $e'));
//       };
//
//       print('✅ WebRTC initialized successfully');
//     } catch (e, stack) {
//       print('❌ WebRTC initialization error: $e');
//       print(stack);
//       _showError('Failed to initialize call: $e');
//     }
//   }
//
//   // ================= SIGNALING LISTENERS =================
//   void _listenToSignaling() {
//     if (widget.sessionId == null) return;
//
//     // Listen to session status safely
//     _sessionSub = FirebaseFirestore.instance
//         .collection('sessions')
//         .doc(widget.sessionId)
//         .snapshots()
//         .listen((snapshot) async {
//       if (!snapshot.exists) return;
//
//       final data = snapshot.data();
//       if (data == null) return;
//
//       print('📱 Session status: ${data['status']}');
//
//       // Handle offer (Volunteer receives)
//       if (data['offer'] != null &&
//           data['status'] == 'waiting' &&
//           widget.userType == 'volunteer') {
//         print('📨 Offer received by volunteer');
//         _startRinging();
//         await _handleOffer(data['offer']);
//       }
//
//       // Handle answer (Blind user receives)
//       if (data['answer'] != null &&
//           data['status'] == 'active' &&
//           !_callActive &&
//           widget.userType == 'blind') {
//         print('📨 Answer received by blind user');
//         await _handleAnswer(data['answer']);
//         _stopRinging();
//         _callActive = true;
//         if (mounted) setState(() {});
//       }
//
//       // Call active status (for volunteer after accepting)
//       if (data['status'] == 'active' &&
//           widget.userType == 'volunteer' &&
//           !_callActive) {
//         print('📞 Call is now active');
//         _stopRinging();
//         _callActive = true;
//         if (mounted) setState(() {});
//       }
//
//       // Call ended
//       if (data['status'] == 'ended') {
//         print('☎️ Call ended');
//         _stopRinging();
//         _endCall();
//       }
//     }, onError: (e) => print('❌ Session listener error: $e'));
//
//     // Listen to ICE candidates
//     String remoteCandidateCollection = widget.userType == 'blind'
//         ? 'calleeCandidates'
//         : 'callerCandidates';
//
//     _candidateSub = FirebaseFirestore.instance
//         .collection('sessions')
//         .doc(widget.sessionId)
//         .collection(remoteCandidateCollection)
//         .snapshots()
//         .listen((snapshot) async {
//       for (final change in snapshot.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final data = change.doc.data();
//           if (data != null && _peerConnection != null) {
//             try {
//               await _peerConnection!.addCandidate(
//                 RTCIceCandidate(
//                   data['candidate'],
//                   data['sdpMid'],
//                   data['sdpMLineIndex'],
//                 ),
//               );
//               print('✅ ICE candidate added');
//             } catch (e) {
//               print('❌ Failed to add ICE candidate: $e');
//             }
//           }
//         }
//       }
//     }, onError: (e) => print('❌ Candidate listener error: $e'));
//   }
//
//   // ================= HANDLE OFFER (CALLEE - VOLUNTEER) =================
//   Future<void> _handleOffer(dynamic offerData) async {
//     if (_peerConnection == null) return;
//
//     try {
//       await _peerConnection!.setRemoteDescription(
//         RTCSessionDescription(offerData['sdp'], offerData['type']),
//       );
//       print('✅ Remote description set (offer received)');
//
//       RTCSessionDescription answer = await _peerConnection!.createAnswer();
//       await _peerConnection!.setLocalDescription(answer);
//
//       await FirebaseFirestore.instance
//           .collection('sessions')
//           .doc(widget.sessionId)
//           .update({
//         'answer': {
//           'type': answer.type,
//           'sdp': answer.sdp,
//         },
//         'status': 'active',
//         'answeredAt': FieldValue.serverTimestamp(),
//       });
//
//       print('✅ Answer sent to caller');
//     } catch (e) {
//       print('❌ Handle offer error: $e');
//     }
//   }
//
//   // ================= HANDLE ANSWER (CALLER - BLIND USER) =================
//   Future<void> _handleAnswer(dynamic answerData) async {
//     if (_peerConnection == null) return;
//
//     try {
//       await _peerConnection!.setRemoteDescription(
//         RTCSessionDescription(answerData['sdp'], answerData['type']),
//       );
//       print('✅ Answer received and set');
//     } catch (e) {
//       print('❌ Handle answer error: $e');
//     }
//   }
//
//   // ================= CREATE OFFER (CALLER - BLIND USER) =================
//   Future<void> _createAndSendOffer() async {
//     if (_peerConnection == null || _offerCreated) return;
//
//     try {
//       RTCSessionDescription offer = await _peerConnection!.createOffer();
//       await _peerConnection!.setLocalDescription(offer);
//
//       await FirebaseFirestore.instance
//           .collection('sessions')
//           .doc(widget.sessionId)
//           .update({
//         'offer': {
//           'type': offer.type,
//           'sdp': offer.sdp,
//         },
//         'status': 'waiting',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       _offerCreated = true;
//       print('✅ Offer created and sent');
//       _startRinging();
//     } catch (e) {
//       print('❌ Create offer error: $e');
//     }
//   }
//
//   // ================= RINGING =================
//   Future<void> _startRinging() async {
//     if (_isRinging) return;
//     _isRinging = true;
//
//     if (widget.userType == 'volunteer') {
//       _incomingCall = true;
//     }
//
//     try {
//       await _player.setReleaseMode(ReleaseMode.loop);
//       await _player.play(AssetSource("ringtone.mp3"));
//       if (mounted) setState(() {});
//     } catch (e) {
//       print('❌ Ringing error (asset might be missing): $e');
//     }
//   }
//
//   Future<void> _stopRinging() async {
//     _isRinging = false;
//     _incomingCall = false;
//
//     try {
//       await _player.stop();
//       if (mounted) setState(() {});
//     } catch (e) {
//       print('❌ Stop ringing error: $e');
//     }
//   }
//
//   // ================= ACCEPT CALL =================
//   Future<void> _acceptCall() async {
//     try {
//       await _stopRinging();
//
//       await FirebaseFirestore.instance
//           .collection('sessions')
//           .doc(widget.sessionId)
//           .update({
//         'status': 'active',
//         'acceptedAt': FieldValue.serverTimestamp(),
//       });
//
//       _callActive = true;
//       if (mounted) setState(() {});
//     } catch (e) {
//       print('❌ Accept call error: $e');
//     }
//   }
//
//   // ================= REJECT CALL =================
//   Future<void> _rejectCall() async {
//     try {
//       await _stopRinging();
//
//       await FirebaseFirestore.instance
//           .collection('sessions')
//           .doc(widget.sessionId)
//           .update({
//         'status': 'ended',
//         'rejectedAt': FieldValue.serverTimestamp(),
//       });
//
//       _endCall();
//     } catch (e) {
//       print('❌ Reject call error: $e');
//     }
//   }
//
//   // ================= END CALL =================
//   Future<void> _endCall() async {
//     try {
//       if (widget.sessionId != null) {
//         await FirebaseFirestore.instance
//             .collection('sessions')
//             .doc(widget.sessionId)
//             .update({
//           'status': 'ended',
//           'endedAt': FieldValue.serverTimestamp(),
//           'duration': _callDuration,
//         });
//       }
//
//       _localStream?.getTracks().forEach((track) => track.stop());
//       await _remoteRenderer?.dispose();
//       await _localRenderer?.dispose();
//       await _peerConnection?.close();
//
//       await _sessionSub?.cancel();
//       await _candidateSub?.cancel();
//       _timer?.cancel();
//       await _stopRinging();
//
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       print('❌ End call error: $e');
//       if (mounted) Navigator.pop(context);
//     }
//   }
//
//   // ================= MUTE & SPEAKER =================
//   void _toggleMute() {
//     _isMuted = !_isMuted;
//     _localStream?.getAudioTracks().forEach((track) {
//       track.enabled = !_isMuted;
//     });
//     if (mounted) setState(() {});
//   }
//
//   void _toggleSpeaker() {
//     _isLoudspeaker = !_isLoudspeaker;
//     if (mounted) setState(() {});
//   }
//
//   // ================= CALL TIMER =================
//   Timer? _timer;
//
//   void _startCallTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) return;
//       if (_callActive) {
//         setState(() {
//           _callDuration++;
//         });
//       }
//     });
//   }
//
//   String _formatDuration(int seconds) {
//     final minutes = seconds ~/ 60;
//     final secs = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
//   }
//
//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _stopRinging();
//     _player.dispose(); // Dispose player safely
//     _localStream?.getTracks().forEach((track) => track.stop());
//     _remoteRenderer?.dispose();
//     _localRenderer?.dispose();
//     _peerConnection?.close();
//     _sessionSub?.cancel();
//     _candidateSub?.cancel();
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // 📹 1. REMOTE VIDEO (FULL SCREEN)
//             Positioned.fill(
//               child: _remoteRenderer != null
//                   ? RTCVideoView(
//                 _remoteRenderer!,
//                 objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//               )
//                   : Container(
//                 color: const Color(0xFF1A1A1A),
//                 child: const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.person, size: 80, color: Colors.white24),
//                       SizedBox(height: 12),
//                       Text(
//                         "Connecting video stream...",
//                         style: TextStyle(color: Colors.white54, fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             //  gradient overlay for better text contrast
//             Positioned.fill(
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.black87,
//                       Colors.transparent,
//                       Colors.transparent,
//                       Colors.black87,
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     stops: [0.0, 0.25, 0.75, 1.0],
//                   ),
//                 ),
//               ),
//             ),
//
//             // ⏱ 2. TOP HEADER OVERLAY (NAME & TIMER)
//             Positioned(
//               top: 16,
//               left: 16,
//               right: 16,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.45),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.white10),
//                 ),
//                 child: Row(
//                   children: [
//                     const CircleAvatar(
//                       radius: 20,
//                       backgroundColor: Colors.orangeAccent,
//                       child: Icon(Icons.remove_red_eye, color: Colors.white, size: 20),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             widget.contactName ?? 'Blind User',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           Text(
//                             _callActive ? "Live Assistance" : "Connecting...",
//                             style: TextStyle(
//                               color: _callActive ? Colors.greenAccent : Colors.amberAccent,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white12,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         _formatDuration(_callDuration),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // 📷 3. LOCAL VIDEO PREVIEW (FLOATING PICTURE-IN-PICTURE)
//             Positioned(
//               top: 90,
//               right: 16,
//               child: Container(
//                 width: 100,
//                 height: 140,
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.white24, width: 2),
//                   boxShadow: const [
//                     BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(14),
//                   child: _localRenderer != null
//                       ? RTCVideoView(
//                     _localRenderer!,
//                     mirror: true,
//                     objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                   )
//                       : const Center(
//                     child: Icon(Icons.videocam_off, color: Colors.white38),
//                   ),
//                 ),
//               ),
//             ),
//
//             // 🔔 4. INCOMING CALL OVERLAY (MODERN CARD)
//             if (_incomingCall && widget.userType == 'volunteer')
//               Center(
//                 child: Container(
//                   width: MediaQuery.of(context).size.width * 0.85,
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF222222),
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(color: Colors.white12),
//                     boxShadow: const [
//                       BoxShadow(color: Colors.black87, blurRadius: 20, spreadRadius: 5),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.green.withOpacity(0.15),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(Icons.ring_volume, color: Colors.greenAccent, size: 48),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         "Incoming Call",
//                         style: TextStyle(color: Colors.grey[400], fontSize: 14),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         widget.contactName ?? 'Blind User',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: _rejectCall,
//                               icon: const Icon(Icons.call_end, color: Colors.white, size: 20),
//                               label: const Text("Reject", style: TextStyle(color: Colors.white)),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.redAccent,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: _acceptCall,
//                               icon: const Icon(Icons.call, color: Colors.white, size: 20),
//                               label: const Text("Accept", style: TextStyle(color: Colors.white)),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               ),
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//
//             // 🎛 5. BOTTOM CONTROL BAR (PILL CONTAINER)
//             Positioned(
//               bottom: 30,
//               left: 40,
//               right: 40,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.65),
//                   borderRadius: BorderRadius.circular(35),
//                   border: Border.all(color: Colors.white12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     // Mute Button
//                     _buildControlButton(
//                       heroTag: "muteBtn",
//                       icon: _isMuted ? Icons.mic_off : Icons.mic,
//                       color: _isMuted ? Colors.redAccent : Colors.white24,
//                       onPressed: _toggleMute,
//                     ),
//
//                     // End Call Button
//                     _buildControlButton(
//                       heroTag: "endBtn",
//                       icon: Icons.call_end,
//                       color: Colors.red,
//                       isLarge: true,
//                       onPressed: _endCall,
//                     ),
//
//                     // Speaker Button
//                     _buildControlButton(
//                       heroTag: "speakerBtn",
//                       icon: _isLoudspeaker ? Icons.volume_up : Icons.volume_down,
//                       color: _isLoudspeaker ? Colors.blueAccent : Colors.white24,
//                       onPressed: _toggleSpeaker,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper Widget for Clean Round Control Buttons
//   Widget _buildControlButton({
//     required String heroTag,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//     bool isLarge = false,
//   }) {
//     double size = isLarge ? 56 : 46;
//     return SizedBox(
//       width: size,
//       height: size,
//       child: FloatingActionButton(
//         heroTag: heroTag,
//         onPressed: onPressed,
//         elevation: 0,
//         backgroundColor: color,
//         shape: const CircleBorder(),
//         child: Icon(icon, color: Colors.white, size: isLarge ? 28 : 22),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class CallScreen extends StatefulWidget {
  final String? contactName;
  final String? sessionId;
  final String? volunteerId;
  final String userType; // 'blind' or 'volunteer'

  const CallScreen({
    Key? key,
    this.contactName = "Blind User",
    this.sessionId,
    this.volunteerId,
    this.userType = 'blind',
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  bool _isLoudspeaker = false;
  bool _isFrontCamera = true;
  int _callDuration = 0;
  bool _callActive = false;

  RTCVideoRenderer? _remoteRenderer;
  RTCVideoRenderer? _localRenderer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  StreamSubscription? _sessionSub;
  StreamSubscription? _candidateSub;

  late AudioPlayer _player;
  bool _isRinging = false;
  bool _incomingCall = false;
  bool _offerCreated = false;

  late AnimationController _endCallController;
  late Animation<double> _pulseAnimation;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _endCallController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.15).animate(_endCallController);

    _startCallTimer();
    _initAndListen();
  }

  Future<void> _initAndListen() async {
    await _initializeWebRTC();

    if (widget.userType == 'blind' && widget.sessionId != null) {
      Future.delayed(const Duration(milliseconds: 800), () async {
        print('🟢 Blind user - Creating offer automatically');
        await _createAndSendOffer();
      });
    }

    _listenToSignaling();
  }

  // ================= WEBRTC INITIALIZATION =================
  Future<void> _initializeWebRTC() async {
    try {
      _remoteRenderer = RTCVideoRenderer();
      _localRenderer = RTCVideoRenderer();

      await _remoteRenderer!.initialize();
      await _localRenderer!.initialize();

      final config = {
        "iceServers": [
          {"urls": ["stun:stun.l.google.com:19302"]},
          {"urls": ["stun:stun1.l.google.com:19302"]},
        ]
      };

      final mediaConstraints = {
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
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

      _localStream =
      await navigator.mediaDevices.getUserMedia(mediaConstraints);

      for (var track in _localStream!.getAudioTracks()) {
        track.enabled = true;
      }

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      if (mounted) {
        setState(() {
          _localRenderer!.srcObject = _localStream;
        });
      }

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        print('🎥 Remote track received: ${event.track.kind}');
        if (event.streams.isNotEmpty) {
          for (var track in event.streams[0].getAudioTracks()) {
            track.enabled = true;
          }
          if (mounted) {
            setState(() {
              _remoteRenderer!.srcObject = event.streams[0];
            });
          }
        }
      };

      _peerConnection!.onAddStream = (MediaStream stream) {
        for (var track in stream.getAudioTracks()) {
          track.enabled = true;
        }
        if (mounted) {
          setState(() {
            _remoteRenderer!.srcObject = stream;
          });
        }
      };

      _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate == null || widget.sessionId == null) return;

        String candidateCollection = widget.userType == 'blind'
            ? 'callerCandidates'
            : 'calleeCandidates';

        FirebaseFirestore.instance
            .collection('sessions')
            .doc(widget.sessionId)
            .collection(candidateCollection)
            .add({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'timestamp': FieldValue.serverTimestamp(),
        }).catchError((e) => print('❌ ICE candidate error: $e'));
      };

      print('✅ WebRTC initialized successfully with full fix');
    } catch (e, stack) {
      print('❌ WebRTC initialization error: $e');
      print(stack);
      _showError('Failed to initialize call: $e');
    }
  }

  // ================= SIGNALING LISTENERS =================
  void _listenToSignaling() {
    if (widget.sessionId == null) return;

    _sessionSub = FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      print('📱 Session status: ${data['status']}');

      if (data['offer'] != null &&
          data['status'] == 'waiting' &&
          widget.userType == 'volunteer') {
        print('📨 Offer received by volunteer');
        _startRinging();
        await _handleOffer(data['offer']);
      }

      if (data['answer'] != null &&
          data['status'] == 'active' &&
          !_callActive &&
          widget.userType == 'blind') {
        print('📨 Answer received by blind user');
        await _handleAnswer(data['answer']);
        _stopRinging();
        _callActive = true;
        if (mounted) setState(() {});
      }

      if (data['status'] == 'active' &&
          widget.userType == 'volunteer' &&
          !_callActive) {
        print('📞 Call is now active');
        _stopRinging();
        _callActive = true;
        if (mounted) setState(() {});
      }

      if (data['status'] == 'ended') {
        print('☎️ Call ended');
        _stopRinging();
        _endCall();
      }
    }, onError: (e) => print('❌ Session listener error: $e'));

    String remoteCandidateCollection = widget.userType == 'blind'
        ? 'calleeCandidates'
        : 'callerCandidates';

    _candidateSub = FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .collection(remoteCandidateCollection)
        .snapshots()
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null && _peerConnection != null) {
            try {
              await _peerConnection!.addCandidate(
                RTCIceCandidate(
                  data['candidate'],
                  data['sdpMid'],
                  data['sdpMLineIndex'],
                ),
              );
              print('✅ ICE candidate added');
            } catch (e) {
              print('❌ Failed to add ICE candidate: $e');
            }
          }
        }
      }
    }, onError: (e) => print('❌ Candidate listener error: $e'));
  }

  // ================= HANDLE OFFER =================
  Future<void> _handleOffer(dynamic offerData) async {
    if (_peerConnection == null) return;

    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offerData['sdp'], offerData['type']),
      );
      print('✅ Remote description set (offer received)');

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .update({
        'answer': {
          'type': answer.type,
          'sdp': answer.sdp,
        },
        'status': 'active',
        'answeredAt': FieldValue.serverTimestamp(),
      });

      print('✅ Answer sent to caller');
    } catch (e) {
      print('❌ Handle offer error: $e');
    }
  }

  // ================= HANDLE ANSWER =================
  Future<void> _handleAnswer(dynamic answerData) async {
    if (_peerConnection == null) return;

    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answerData['sdp'], answerData['type']),
      );
      print('✅ Answer received and set');
    } catch (e) {
      print('❌ Handle answer error: $e');
    }
  }

  // ================= CREATE OFFER =================
  Future<void> _createAndSendOffer() async {
    if (_peerConnection == null || _offerCreated) return;

    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .update({
        'offer': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _offerCreated = true;
      print('✅ Offer created and sent');
      _startRinging();
    } catch (e) {
      print('❌ Create offer error: $e');
    }
  }

  // ================= RINGING =================
  Future<void> _startRinging() async {
    if (_isRinging) return;
    _isRinging = true;

    if (widget.userType == 'volunteer') {
      _incomingCall = true;
    }

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource("ringtone.mp3"));
      if (mounted) setState(() {});
    } catch (e) {
      print('❌ Ringing error: $e');
    }
  }

  Future<void> _stopRinging() async {
    _isRinging = false;
    _incomingCall = false;

    try {
      await _player.stop();
      if (mounted) setState(() {});
    } catch (e) {
      print('❌ Stop ringing error: $e');
    }
  }

  // ================= ACCEPT CALL =================
  Future<void> _acceptCall() async {
    try {
      await _stopRinging();

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .update({
        'status': 'active',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      _callActive = true;
      if (mounted) setState(() {});
    } catch (e) {
      print('❌ Accept call error: $e');
    }
  }

  // ================= REJECT CALL =================
  Future<void> _rejectCall() async {
    try {
      await _stopRinging();

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .update({
        'status': 'ended',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      _endCall();
    } catch (e) {
      print('❌ Reject call error: $e');
    }
  }

  // ================= END CALL =================
  Future<void> _endCall() async {
    try {
      if (widget.sessionId != null) {
        await FirebaseFirestore.instance
            .collection('sessions')
            .doc(widget.sessionId)
            .update({
          'status': 'ended',
          'endedAt': FieldValue.serverTimestamp(),
          'duration': _callDuration,
        });
      }

      _localStream?.getTracks().forEach((track) => track.stop());
      await _remoteRenderer?.dispose();
      await _localRenderer?.dispose();
      await _peerConnection?.close();

      await _sessionSub?.cancel();
      await _candidateSub?.cancel();
      _timer?.cancel();
      await _stopRinging();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ End call error: $e');
      if (mounted) Navigator.pop(context);
    }
  }

  // ================= CONTROLS =================
  void _toggleMute() {
    _isMuted = !_isMuted;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
    if (mounted) setState(() {});
  }

  void _switchCamera() {
    _isFrontCamera = !_isFrontCamera;
    _localStream?.getVideoTracks().forEach((track) {
      Helper.switchCamera(track);
    });
    if (mounted) setState(() {});
  }

  void _toggleSpeaker() {
    _isLoudspeaker = !_isLoudspeaker;
    _localStream?.getAudioTracks().forEach((track) {
      track.enableSpeakerphone(_isLoudspeaker);
    });
    if (mounted) setState(() {});
  }

  // ================= CALL TIMER =================
  Timer? _timer;

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_callActive) {
        setState(() {
          _callDuration++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _stopRinging();
    _endCallController.dispose();
    _player.dispose();
    _localStream?.getTracks().forEach((track) => track.stop());
    _remoteRenderer?.dispose();
    _localRenderer?.dispose();
    _peerConnection?.close();
    _sessionSub?.cancel();
    _candidateSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _remoteRenderer != null &&
                  _remoteRenderer!.srcObject != null
                  ? RTCVideoView(
                _remoteRenderer!,
                objectFit:
                RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
                  : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.contactName ?? "Unknown Contact",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _callActive
                            ? "Connected"
                            : "Connecting Video Stream...",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    _formatDuration(_callDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 20,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 8),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _localRenderer != null &&
                      _localRenderer!.srcObject != null
                      ? RTCVideoView(
                    _localRenderer!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit
                        .RTCVideoViewObjectFitCover,
                  )
                      : const Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white70,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
            if (_incomingCall && widget.userType == 'volunteer')
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.82,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.call,
                        color: Colors.greenAccent,
                        size: 56,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Incoming Call",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.contactName ?? 'Blind User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _rejectCall,
                            icon: const Icon(Icons.call_end, size: 18),
                            label: const Text("Reject"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _acceptCall,
                            icon: const Icon(Icons.call, size: 18),
                            label: const Text("Accept"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _isMuted
                        ? Colors.redAccent.withOpacity(0.4)
                        : Colors.grey[800],
                    child: IconButton(
                      icon: Icon(
                        _isMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _toggleMute,
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[800],
                    child: IconButton(
                      icon: const Icon(
                        Icons.cameraswitch,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _switchCamera,
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _isLoudspeaker
                        ? Colors.blueAccent.withOpacity(0.5)
                        : Colors.grey[800],
                    child: IconButton(
                      icon: Icon(
                        _isLoudspeaker ? Icons.volume_up : Icons.hearing,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _toggleSpeaker,
                    ),
                  ),
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _endCall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}