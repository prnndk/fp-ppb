import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:final_project_ppb/models/reservation.dart';
import 'package:final_project_ppb/models/review.dart';
import 'package:final_project_ppb/services/review_service.dart';

class DetailTransactionScreen extends StatelessWidget {
  final Reservation reservation;
  const DetailTransactionScreen({Key? key, required this.reservation})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reviewService = ReviewService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Reservasi',
          style: TextStyle(color: Color(0xFF4A2C2A)),
        ),
        backgroundColor: const Color(0xFFF8F5F2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A2C2A)),
      ),
      backgroundColor: const Color(0xFFF8F5F2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Reservasi #${reservation.id?.substring(0, 8).toUpperCase() ?? "Unknown"}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 16),
            ...reservation.orderItems.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.menuName} x${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Rp${item.totalPrice.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      StreamBuilder<Review?>(
                        stream: reviewService.getUserReviewForMenuItem(
                          menuId: item.menuId,
                          reservationId: reservation.id!,
                        ),
                        builder: (context, snapshot) {
                          final review = snapshot.data;
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 24,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (review != null) ...[
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: review.rating.toDouble(),
                                      itemBuilder:
                                          (context, _) => const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                      itemCount: 5,
                                      itemSize: 20.0,
                                      direction: Axis.horizontal,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${review.rating.toDouble()}/5)',
                                      style: const TextStyle(
                                        color: Color(0xFFBCAAA4),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  review.comment,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed:
                                          () => _showReviewDialog(
                                            context,
                                            item,
                                            review,
                                            reviewService,
                                            reservation,
                                          ),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await reviewService.deleteReview(
                                          reviewId: review.id,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Review dihapus'),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                ElevatedButton(
                                  onPressed:
                                      () => _showReviewDialog(
                                        context,
                                        item,
                                        null,
                                        reviewService,
                                        reservation,
                                      ),
                                  child: const Text('Tambah Review'),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showReviewDialog(
    BuildContext context,
    OrderItem item,
    Review? review,
    ReviewService reviewService,
    Reservation reservation,
  ) {
    final ratingController = ValueNotifier<double>(
      review?.rating.toDouble() ?? 0.0,
    );
    final commentController = TextEditingController(
      text: review?.comment ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(review == null ? 'Tambah Review' : 'Edit Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: ratingController.value,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) => ratingController.value = rating,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: 'Komentar'),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (ratingController.value == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rating tidak boleh kosong'),
                      ),
                    );
                    return;
                  }
                  if (review == null) {
                    await reviewService.addReview(
                      menuId: item.menuId,
                      reservationId: reservation.id!,
                      rating: ratingController.value.toInt(),
                      comment: commentController.text,
                    );
                  } else {
                    await reviewService.updateReview(
                      reviewId: review.id,
                      rating: ratingController.value.toInt(),
                      comment: commentController.text,
                    );
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: Text(review == null ? 'Simpan' : 'Update'),
              ),
            ],
          ),
    );
  }
}
