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

  // GET RESERVATION
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

  // DELETE RESERVASI
  Future<void> deleteReservation(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete reservation: $e');
    }
  }

  // UPDATE RESERVASI
  Future<void> updateReservation(Reservation reservation) async {
    try {
      await _firestore
          .collection('reservations')
          .doc(reservation.id)
          .update(reservation.toMap());
    } catch (e) {
      throw Exception('Failed to update reservation: $e');
    }
  }

  // GET ALL RESERVATION
  Future<List<Reservation>> getAllReservations() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map(
            (doc) =>
                Reservation.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reservations: $e');
    }
  }
}
