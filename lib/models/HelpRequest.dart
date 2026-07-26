import 'package:cloud_firestore/cloud_firestore.dart';

class HelpRequest {
  final String requestId;
  final String userId;
  final String type;
  final String status;
  final String? volunteerId;
  final String? sessionId;
  final Timestamp? createdAt;

  HelpRequest({
    required this.requestId,
    required this.userId,
    required this.type,
    required this.status,
    this.volunteerId,
    this.sessionId,
    this.createdAt,
  });

  factory HelpRequest.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {

    final data = doc.data()!;

    return HelpRequest(
      requestId: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'help',
      status: data['status'] ?? 'pending',
      volunteerId: data['volunteerId'],
      sessionId: data['sessionId'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'status': status,
      'volunteerId': volunteerId,
      'sessionId': sessionId,
      'createdAt': createdAt,
    };
  }
}