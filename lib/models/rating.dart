import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String jobId;
  final String jobTitle;
  final int stars;
  final String comment;
  final DateTime createdAt;
  final String role;

  Rating({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.jobId,
    required this.jobTitle,
    required this.stars,
    required this.comment,
    required this.createdAt,
    required this.role,
  });

  // Add fromFirestore and toMap methods if you need them
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'stars': stars,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'role': role,
    };
  }

  factory Rating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rating(
      id: doc.id,
      fromUserId: data['fromUserId'],
      toUserId: data['toUserId'],
      jobId: data['jobId'],
      jobTitle: data['jobTitle'],
      stars: data['stars'],
      comment: data['comment'],
      createdAt: DateTime.parse(data['createdAt']),
      role: data['role'],
    );
  }
}
