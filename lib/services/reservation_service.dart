import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_ppb/models/reservation.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reservations';

  // Create a new reservation
  Future<String> createReservation(Reservation reservation) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(reservation.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  // Get reservation by ID
  Future<Reservation?> getReservation(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(id).get();

      if (doc.exists) {
        return Reservation.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get reservation: $e');
    }
  }

  // Update reservation status
  Future<void> updateReservationStatus(String id, String status) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update reservation: $e');
    }
  }

  // Get all reservations (for admin purposes)
  Stream<List<Reservation>> getAllReservations() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Reservation.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }
}
