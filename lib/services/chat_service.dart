import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_ppb/models/chat.dart';
import 'package:final_project_ppb/services/api_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'chats';

  Future<String> createChat(Chat chat) async {
    try {
      String answer = await ApiService.askQuestion(
        ChatRequest(userId: chat.userId, question: chat.question),
      );

      chat.answer = answer;

      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(chat.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  Future<List<Chat>> getChatsByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Chat.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }

  Future<List<Chat>> getChatOnlyByDate(DateTime date, String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  0,
                  0,
                ),
              )
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Chat.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Enhanced error message including instructions to create the index
      throw Exception(
        'Failed to get chats by date: $e. If this is a missing index error, please visit the Firebase console to create the required composite index on "userId" and "createdAt" fields.',
      );
    }
  }
}
