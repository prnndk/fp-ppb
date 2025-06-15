import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project_ppb/models/review.dart';

class ReviewService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'reviews';

  // Get review for a menu item by current user and reservation
  Stream<Review?> getUserReviewForMenuItem({
    required int menuId,
    required String reservationId,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection(_collection)
        .where('menuId', isEqualTo: menuId)
        .where('reservationId', isEqualTo: reservationId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return Review.fromMap(snap.docs.first.data(), snap.docs.first.id);
        });
  }

  // Add review
  Future<void> addReview({
    required String menuId,
    required String reservationId,
    required int rating,
    required String comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    await _firestore.collection(_collection).add({
      'menuId': menuId,
      'reservationId': reservationId,
      'userId': user.uid,
      'rating': rating,
      'comment': comment,
      'createdAt': DateTime.now(),
    });
  }

  // Update review
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    await _firestore.collection(_collection).doc(reviewId).update({
      'rating': rating,
      'comment': comment,
    });
  }

  // Delete review
  Future<void> deleteReview({required String reviewId}) async {
    await _firestore.collection(_collection).doc(reviewId).delete();
  }
}
