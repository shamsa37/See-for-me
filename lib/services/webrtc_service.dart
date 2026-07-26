import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';


class WebRTCService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  RTCPeerConnection? peerConnection;

  MediaStream? localStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  CollectionReference<Map<String, dynamic>> get _calls =>
      _db.collection('calls');

  /// Create call document
  Future<void> createCall(String sessionId) async {
    await _calls.doc(sessionId).set({
      'status': 'calling',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Future<void> initializeRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }
  Future<void> initializePeerConnection(String sessionId) async {
    final configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun.l.google.com:19302',
          ]
        }
      ]
    };
    peerConnection =
    await createPeerConnection(configuration);

    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
      await _db
          .collection('calls')
          .doc(sessionId)
          .collection('callerCandidates')
          .add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    localRenderer.srcObject = localStream;

    for (var track in localStream!.getTracks()) {
      peerConnection!.addTrack(track, localStream!);
    }

    peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams.first;
      }
    };
  }
  /// Caller creates Offer
  Future<void> createOffer(String sessionId) async {
    if (peerConnection == null) return;

    RTCSessionDescription offer =
    await peerConnection!.createOffer();

    await peerConnection!.setLocalDescription(offer);

    await _db.collection('calls').doc(sessionId).set({
      'offer': {
        'type': offer.type,
        'sdp': offer.sdp,
      }
    }, SetOptions(merge: true));
  }
  Future<RTCSessionDescription?> getOffer(String sessionId) async {
    final doc =
    await _db.collection('calls').doc(sessionId).get();

    if (!doc.exists) return null;

    final data = doc.data();

    if (data == null || data['offer'] == null) {
      return null;
    }

    return RTCSessionDescription(
      data['offer']['sdp'],
      data['offer']['type'],
    );
  }
  Future<void> createAnswer(String sessionId) async {
    if (peerConnection == null) return;

    await setRemoteOffer(sessionId);

    RTCSessionDescription answer =
    await peerConnection!.createAnswer();

    await peerConnection!.setLocalDescription(answer);

    await _db.collection('calls').doc(sessionId).set({
      'answer': {
        'type': answer.type,
        'sdp': answer.sdp,
      }
    }, SetOptions(merge: true));
  }
  /// Set Remote Offer
  Future<void> setRemoteOffer(String sessionId) async {
    final offer = await getOffer(sessionId);

    if (offer == null) return;

    await peerConnection!.setRemoteDescription(offer);
  }

  Future<RTCSessionDescription?> getAnswer(String sessionId) async {
    final doc = await _db.collection('calls').doc(sessionId).get();

    if (!doc.exists) return null;

    final data = doc.data();

    if (data == null || data['answer'] == null) {
      return null;
    }

    return RTCSessionDescription(
      data['answer']['sdp'],
      data['answer']['type'],
    );
  }

  Future<void> saveCalleeCandidate(
      String sessionId,
      RTCIceCandidate candidate,
      ) async {
    await _db
        .collection('calls')
        .doc(sessionId)
        .collection('calleeCandidates')
        .add({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  void listenCallerCandidates(String sessionId) {
    _db
        .collection('calls')
        .doc(sessionId)
        .collection('callerCandidates')
        .snapshots()
        .listen((snapshot) {

      for (var change in snapshot.docChanges) {

        final data = change.doc.data();

        if (data == null) continue;

        peerConnection?.addCandidate(
          RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ),
        );
      }
    });
  }

  void listenCalleeCandidates(String sessionId) {
    _db
        .collection('calls')
        .doc(sessionId)
        .collection('calleeCandidates')
        .snapshots()
        .listen((snapshot) {

      for (var change in snapshot.docChanges) {

        final data = change.doc.data();

        if (data == null) continue;

        peerConnection?.addCandidate(
          RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ),
        );
      }
    });
  }

  Future<void> dispose() async {
    localStream?.getTracks().forEach((track) {
      track.stop();
    });

    await localRenderer.dispose();
    await remoteRenderer.dispose();

    await localStream?.dispose();

    await peerConnection?.close();
    peerConnection = null;
  }

  Future<void> listenForAnswer(String sessionId) async {
    _db.collection('calls').doc(sessionId).snapshots().listen((doc) async {

      if (!doc.exists) return;

      final data = doc.data();

      if (data == null || data['answer'] == null) return;

      RTCSessionDescription answer =
      RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );

      await peerConnection!
          .setRemoteDescription(answer);
    });
  }

  /// Listen Call Document
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamCall(
      String sessionId) {
    return _calls.doc(sessionId).snapshots();
  }

  /// End Call
  Future<void> endCall(String sessionId) async {
    await _calls.doc(sessionId).update({
      'status': 'ended',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }
}