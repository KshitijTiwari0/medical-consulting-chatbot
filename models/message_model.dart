import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final bool isUser;
  final String message;
  final DateTime date;
  final String? audioUrl;
  final String sessionId;

  Message({
    required this.id,
    required this.isUser,
    required this.message,
    required this.date,
    this.audioUrl,
    required this.sessionId,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      isUser: data['isUser'] ?? true,
      message: data['message'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      audioUrl: data['audioUrl'],
      sessionId: data['sessionId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isUser': isUser,
      'message': message,
      'date': Timestamp.fromDate(date),
      'audioUrl': audioUrl,
      'sessionId': sessionId,
    };
  }
}