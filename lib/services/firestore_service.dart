// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<void> sendRequest(String type) async {
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//
//     await _firestore.collection('requests').add({
//       'blindUserId': uid,
//       'volunteerId': null,
//       'type': type,
//       'status': 'pending',
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= SEND REQUEST =================
  Future<String> sendRequest(String type, String sessionId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentReference requestRef =
    await _firestore.collection('requests').add({
      'blindUserId': uid,
      'sessionId': sessionId,
      'type': type, // call, help, emergency
      'status': 'pending',
      'volunteerId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔥 LINK REQUEST TO SESSION
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'ringing',
      'requestId': requestRef.id,
    });

    return requestRef.id;
  }

  // ================= ACCEPT REQUEST =================
  Future<void> acceptRequest(
      String requestId,
      String sessionId,
      String volunteerId,
      ) async {

    // update request
    await _firestore.collection('requests').doc(requestId).update({
      'volunteerId': volunteerId,
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    // update session (IMPORTANT FIX)
    await _firestore.collection('sessions').doc(sessionId).update({
      'volunteerId': volunteerId,
      'status': 'active',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= REJECT REQUEST =================
  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= LISTEN REQUEST =================
  Stream<DocumentSnapshot> listenRequest(String requestId) {
    return _firestore.collection('requests').doc(requestId).snapshots();
  }

  // ================= LISTEN SESSION =================
  Stream<DocumentSnapshot> listenSession(String sessionId) {
    return _firestore.collection('sessions').doc(sessionId).snapshots();
  }
}