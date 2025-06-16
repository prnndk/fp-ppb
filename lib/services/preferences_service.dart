import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_ppb/models/preferensi.dart';
import 'package:final_project_ppb/models/reservation.dart';
import 'package:final_project_ppb/services/api_service.dart';

class PreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'preferences';

  Future<String> createPreferensi(Preferensi preferensi) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(preferensi.toMap());

      await ApiService.postPreferensi(
        PreferensiRequest(
          userId: preferensi.userId,
          preferences: PreferensiJson(
            seafoodPreference: preferensi.seafoodPreference,
            lactosePreference: preferensi.lactosePreference,
            vegetarianPreference: preferensi.vegetarianPreference,
            allergies: preferensi.allergies,
            note: preferensi.note,
          ),
        ),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  Future<Preferensi?> getPreferensiByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        return Preferensi.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get preferences: $e');
    }
  }

  Future<void> updatePreferensi(Preferensi preferensi) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(preferensi.id)
          .update(preferensi.toMap());

      await ApiService.postPreferensi(
        PreferensiRequest(
          userId: preferensi.userId,
          preferences: PreferensiJson(
            seafoodPreference: preferensi.seafoodPreference,
            lactosePreference: preferensi.lactosePreference,
            vegetarianPreference: preferensi.vegetarianPreference,
            allergies: preferensi.allergies,
            note: preferensi.note,
          ),
        ),
      );
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  Future<void> deletePreferensi(String id, String userId) async {
    try {
      await ApiService.deletePreferensi(userId);

      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete preferences: $e');
    }
  }
}
