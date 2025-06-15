import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project_ppb/models/review.dart';

class ReviewService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'reviews';

  // Get review for a menu item by current user (1 user 1 menu 1 review)
  Stream<Review?> getUserReviewForMenuItem({required String menuId}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection(_collection)
        .where('menuId', isEqualTo: menuId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return Review.fromMap(snap.docs.first.data(), snap.docs.first.id);
        });
  }

  // Add review (only if not exists)
  Future<void> addReview({
    required String menuId,
    required int rating,
    required String comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    // Check if review already exists
    final existing =
        await _firestore
            .collection(_collection)
            .where('menuId', isEqualTo: menuId)
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Anda sudah memberi review untuk menu ini.');
    }
    await _firestore.collection(_collection).add({
      'menuId': menuId,
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
