import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('sessions');

  /// Create session after volunteer accepts request
  Future<String> createSession({
    required String requestId,
    required String userId,
    required String volunteerId,
  }) async {
    final doc = await _sessions.add({
      'requestId': requestId,
      'userId': userId,
      'volunteerId': volunteerId,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// Listen to a session
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamSession(
      String sessionId) {
    return _sessions.doc(sessionId).snapshots();
  }

  /// End session
  Future<void> endSession(String sessionId) async {
    await _sessions.doc(sessionId).update({
      'status': 'ended',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }
}