//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class SessionService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // ================= CREATE SESSION =================
//   Future<String> createSession(String userId) async {
//     DocumentReference doc = await _firestore
//         .collection('sessions')
//         .add({
//       'userId': userId,
//       'volunteerId': null,
//       'status': 'idle', // idle, waiting, active, ended
//       'callId': null,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//
//     return doc.id;
//   }
//
//   // ================= START CALL =================
//   Future<void> startCall(String sessionId, String callId) async {
//     await _firestore.collection('sessions').doc(sessionId).update({
//       'status': 'waiting',
//       'callId': callId,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//
//     // 🔥 ALSO CREATE CALL TRACKING
//     await _firestore.collection('calls').doc(callId).set({
//       'sessionId': sessionId,
//       'status': 'calling',
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }
//
//   // ================= ACCEPT CALL =================
//   Future<void> acceptCall(String sessionId, String volunteerId) async {
//     await _firestore.collection('sessions').doc(sessionId).update({
//       'status': 'active',
//       'volunteerId': volunteerId,
//       'acceptedAt': FieldValue.serverTimestamp(),
//     });
//   }
//
//   // ================= END CALL =================
//   Future<void> endCall(String sessionId) async {
//     await _firestore.collection('sessions').doc(sessionId).update({
//       'status': 'ended',
//       'endedAt': FieldValue.serverTimestamp(),
//     });
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= CREATE SESSION =================
  Future<String> createSession(String userId) async {
    DocumentReference doc =
    await _firestore.collection('sessions').add({
      'userId': userId,
      'volunteerId': null,
      'status': 'idle', // idle, ringing, active, ended
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ================= SET OFFER =================
  Future<void> setOffer(
      String sessionId, Map<String, dynamic> offer) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'offer': {
        'type': offer['type'],
        'sdp': offer['sdp'],
      },
      'status': 'ringing',
    });
  }

  // ================= SET ANSWER =================
  Future<void> setAnswer(
      String sessionId, Map<String, dynamic> answer) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'answer': {
        'type': answer['type'],
        'sdp': answer['sdp'],
      },
      'status': 'active',
    });
  }

  // ================= ADD ICE CANDIDATE ===================
  Future<void> addCandidate(
      String sessionId,
      String role, // callerCandidates / calleeCandidates
      Map<String, dynamic> candidate,
      ) async {
    await _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection(role)
        .add({
      'candidate': candidate['candidate'],
      'sdpMid': candidate['sdpMid'],
      'sdpMLineIndex': candidate['sdpMLineIndex'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= START CALL =================
  Future<void> startCall(String sessionId, String volunteerId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'ringing',
      'volunteerId': volunteerId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= ACCEPT CALL =================
  Future<void> acceptCall(String sessionId, String volunteerId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'active',
      'volunteerId': volunteerId,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= END CALL =================
  Future<void> endCall(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'ended',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= LISTEN SESSION (IMPORTANT) =================
  Stream<DocumentSnapshot> listenSession(String sessionId) {
    return _firestore.collection('sessions').doc(sessionId).snapshots();
  }
}