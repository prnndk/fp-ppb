class Chat {
  String id;
  String question;
  String? answer;
  String userId;
  DateTime createdAt;

  Chat({
    required this.id,
    required this.question,
    this.answer,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'],
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class ChatRequest {
  String userId;
  String question;

  ChatRequest({required this.userId, required this.question});

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'question': question};
  }

  factory ChatRequest.fromJson(Map<String, dynamic> json) {
    return ChatRequest(
      userId: json['userId'] ?? '',
      question: json['question'] ?? '',
    );
  }
}
