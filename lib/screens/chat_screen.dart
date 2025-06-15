import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:final_project_ppb/models/chat.dart';
import 'package:final_project_ppb/services/chat_service.dart';
import 'package:final_project_ppb/services/user_service.dart';
import 'package:final_project_ppb/widgets/ai_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService cs = ChatService();
  final UserService us = UserService();

  late Future<List<Chat>> dataChatUser;

  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  void _loadChatData() {
    setState(() {
      // dataChatUser = cs.getChatOnlyByDate(DateTime.now(), userId);
      dataChatUser = cs.getChatsByUserId(userId);
    });
  }

  Future<void> handleSendMessage(String message) async {
    if (message.isEmpty) return;
    User? user = us.getCurrentUser();

    if (user != null) {
      Chat chat = Chat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        question: message,
        createdAt: DateTime.now(),
        answer: '',
      );

      try {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                  SizedBox(width: 16),
                  Text('Sending message...'),
                ],
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }

        await cs.createChat(chat);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Message sent: $message'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        _loadChatData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending message: $e'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEE),
      appBar: AppBar(
        title: const Text(
          'Menu Recommendations',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Chat>>(
              future: dataChatUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Start a conversation!',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final chat = snapshot.data![index];
                      final isUserMessage = chat.answer?.isEmpty ?? true;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          spacing: 8,
                          children: [
                            BubbleSpecialThree(
                              text: chat.question ?? '',
                              color: const Color(0xFF8B4513),
                              tail: true,
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              isSender: true,
                            ),
                            AiMessages(message: chat.answer ?? ''),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: MessageBar(onSend: (message) => handleSendMessage(message)),
          ),
        ],
      ),
    );
  }
}
