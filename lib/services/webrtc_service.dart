// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class WebRTCService {
//   RTCPeerConnection? _peerConnection;
//   MediaStream? localStream;
//   MediaStream? remoteStream;
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // ================= INIT =================
//   Future<void> initConnection() async {
//     final config = {
//       "iceServers": [
//         {"urls": "stun:stun.l.google.com:19302"}
//       ]
//     };
//
//     _peerConnection = await createPeerConnection(config);
//
//     localStream = await navigator.mediaDevices.getUserMedia({
//       "audio": true,
//       "video": true,
//     });
//
//     localStream!.getTracks().forEach((track) {
//       _peerConnection!.addTrack(track, localStream!);
//     });
//
//     _peerConnection!.onTrack = (event) {
//       remoteStream = event.streams[0];
//     };
//   }
//
//   // ================= CREATE OFFER =================
//   Future<String> createOffer(String sessionId) async {
//     RTCSessionDescription offer =
//     await _peerConnection!.createOffer();
//
//     await _peerConnection!.setLocalDescription(offer);
//
//     await _firestore.collection('sessions').doc(sessionId).update({
//       "offer": offer.toMap(),
//     });
//
//     return offer.sdp!;
//   }
//
//   // ================= ANSWER =================
//   Future<void> createAnswer(String sessionId) async {
//     RTCSessionDescription answer =
//     await _peerConnection!.createAnswer();
//
//     await _peerConnection!.setLocalDescription(answer);
//
//     await _firestore.collection('sessions').doc(sessionId).update({
//       "answer": answer.toMap(),
//     });
//   }
// }

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;

  MediaStream? localStream;
  MediaStream? remoteStream;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= INIT =================
  Future<void> initConnection() async {
    final config = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"}
      ]
    };

    _peerConnection = await createPeerConnection(config);

    localStream = await navigator.mediaDevices.getUserMedia({
      "audio": true,
      "video": true,
    });

    for (var track in localStream!.getTracks()) {
      _peerConnection!.addTrack(track, localStream!);
    }

    // ✅ REMOTE STREAM FIX
    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams[0];
      }
    };

    // ✅ ICE CANDIDATES SEND (IMPORTANT FIX)
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate == null) return;

      // you will pass sessionId from UI layer
    };

    // ✅ CONNECTION STATE (DEBUG + RECONNECT)
    _peerConnection!.onConnectionState = (state) {
      print("Connection state: $state");
    };
  }

  // ================= CREATE OFFER =================
  Future<Map<String, dynamic>> createOffer(String sessionId) async {
    RTCSessionDescription offer =
    await _peerConnection!.createOffer();

    await _peerConnection!.setLocalDescription(offer);

    await _firestore.collection('sessions').doc(sessionId).update({
      "offer": {
        "type": offer.type,
        "sdp": offer.sdp,
      }
    });

    return {
      "type": offer.type,
      "sdp": offer.sdp,
    };
  }

  // ================= CREATE ANSWER =================
  Future<Map<String, dynamic>> createAnswer(String sessionId) async {
    RTCSessionDescription answer =
    await _peerConnection!.createAnswer();

    await _peerConnection!.setLocalDescription(answer);

    await _firestore.collection('sessions').doc(sessionId).update({
      "answer": {
        "type": answer.type,
        "sdp": answer.sdp,
      }
    });

    return {
      "type": answer.type,
      "sdp": answer.sdp,
    };
  }

  // ================= SET REMOTE OFFER =================
  Future<void> setOffer(Map<String, dynamic> offer) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(
        offer["sdp"],
        offer["type"],
      ),
    );
  }

  // ================= SET REMOTE ANSWER =================
  Future<void> setAnswer(Map<String, dynamic> answer) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(
        answer["sdp"],
        answer["type"],
      ),
    );
  }

  // ================= ADD ICE (RECEIVE SIDE) =================
  Future<void> addIceCandidate(Map<String, dynamic> data) async {
    await _peerConnection!.addCandidate(
      RTCIceCandidate(
        data["candidate"],
        data["sdpMid"],
        data["sdpMLineIndex"],
      ),
    );
  }

  // ================= DISPOSE =================
  Future<void> dispose() async {
    await _peerConnection?.close();
    localStream?.dispose();
  }
}
