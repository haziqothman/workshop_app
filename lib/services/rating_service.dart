import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRating(Rating rating) async {
    await _firestore.collection('ratings').doc(rating.id).set(rating.toMap());
  }

  Future<double> getAverageRating(String userId) async {
    final snapshot =
        await _firestore
            .collection('ratings')
            .where('toUserId', isEqualTo: userId)
            .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final total = snapshot.docs.fold(
      0,
      (sum, doc) => sum + (doc.data()['stars'] as int),
    );
    return total / snapshot.docs.length;
  }

  Future<int> getRatingCount(String userId) async {
    final snapshot =
        await _firestore
            .collection('ratings')
            .where('toUserId', isEqualTo: userId)
            .get();
    return snapshot.docs.length;
  }

  Stream<List<Rating>> getRatingsForUser(String userId) {
    return _firestore
        .collection('ratings')
        .where('toUserId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Rating.fromFirestore(doc)).toList(),
        );
  }
}
