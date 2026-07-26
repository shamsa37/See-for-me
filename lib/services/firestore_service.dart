import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/HelpRequest.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// requests collection
  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('requests');

  /// ============================
  /// CREATE HELP REQUEST
  /// ============================
  Future<String> createHelpRequest({
    required String userId,
    String type = 'help',
  }) async {
    final doc = await _requests.add({
      'userId': userId,
      'type': type,
      'status': 'pending',
      'volunteerId': null,
      'sessionId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// ============================
  /// STREAM ALL PENDING REQUESTS
  /// ============================
  Stream<List<HelpRequest>> streamPendingRequests() {
    return _requests
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HelpRequest.fromFirestore(doc))
          .toList();
    });
  }

  /// ============================
  /// STREAM SINGLE REQUEST
  /// ============================
  Stream<HelpRequest?> streamRequest(String requestId) {
    return _requests.doc(requestId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return HelpRequest.fromFirestore(doc);
    });
  }

  /// ============================
  /// ACCEPT REQUEST
  /// ============================
  Future<void> acceptRequest({
    required String requestId,
    required String volunteerId,
    required String sessionId,
  }) async {
    await _requests.doc(requestId).update({
      'status': 'accepted',
      'volunteerId': volunteerId,
      'sessionId': sessionId,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ============================
  /// REJECT REQUEST
  /// ============================
  Future<void> rejectRequest(String requestId) async {
    await _requests.doc(requestId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ============================
  /// CANCEL REQUEST
  /// ============================
  Future<void> cancelRequest(String requestId) async {
    await _requests.doc(requestId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  /// ============================
  /// GET SINGLE REQUEST
  /// ============================
  Future<HelpRequest?> getRequest(String requestId) async {
    final doc = await _requests.doc(requestId).get();

    if (!doc.exists) return null;

    return HelpRequest.fromFirestore(doc);
  }

  /// ============================
  /// USER REQUEST HISTORY
  /// ============================
  Future<List<HelpRequest>> getUserRequests(String userId) async {
    final snapshot = await _requests
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HelpRequest.fromFirestore(doc))
        .toList();
  }
}