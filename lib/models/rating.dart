import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String jobId;
  final int stars;
  final String comment;
  final DateTime createdAt;
  final String role; // 'foreman' or 'owner'

  Rating({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.jobId,
    required this.stars,
    required this.comment,
    required this.createdAt,
    required this.role,
  });

  factory Rating.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Rating(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      jobId: data['jobId'] ?? '',
      stars: data['stars'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      role: data['role'] ?? 'foreman',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'jobId': jobId,
      'stars': stars,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'role': role,
    };
  }
}
