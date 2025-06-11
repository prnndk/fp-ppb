import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String menuId;
  final String reservationId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.menuId,
    required this.reservationId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'reservationId': reservationId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      menuId: map['menuId'] ?? '',
      reservationId: map['reservationId'] ?? '',
      userId: map['userId'] ?? '',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
