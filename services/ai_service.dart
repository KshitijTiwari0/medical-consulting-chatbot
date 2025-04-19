import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_proj/models/message_model.dart';
import 'package:flutter_proj/models/report_model.dart';
import 'package:uuid/uuid.dart';

class AIService {
  final String apiKey;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GenerativeModel _model;
  late final GenerativeModel _recordingModel;

  AIService({required this.apiKey}) {
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    _recordingModel = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
  }

  String createNewSession(String userId) {
    final sessionId = const Uuid().v4();
    _firestore.collection('users').doc(userId).collection('sessions').doc(sessionId).set({
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
      'title': 'New Chat',
    });
    return sessionId;
  }

  Stream<List<Message>> getMessagesForSession(String userId, String sessionId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('messages')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<Message> processMessage({
    required String userId,
    required String messageText,
    required String sessionId,
    String? promptType,
    Map<String, dynamic>? healthData,
  }) async {
    try {
      final userMessage = Message(
        id: const Uuid().v4(),
        isUser: true,
        message: messageText,
        date: DateTime.now(),
        sessionId: sessionId,
      );
      await _saveMessage(userId, userMessage);

      String prompt = _buildPrompt(promptType, messageText, healthData);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final aiMessage = Message(
        id: const Uuid().v4(),
        isUser: false,
        message: response.text ?? "I'm sorry, I couldn't generate a response.",
        date: DateTime.now(),
        sessionId: sessionId,
      );
      await _saveMessage(userId, aiMessage);

      return aiMessage;
    } catch (e) {
      print('Error processing message: $e');
      final errorMessage = Message(
        id: const Uuid().v4(),
        isUser: false,
        message: "Error occurred. Please try again.",
        date: DateTime.now(),
        sessionId: sessionId,
      );
      await _saveMessage(userId, errorMessage);
      return errorMessage;
    }
  }

  Future<String?> processAudio(String audioPath) async {
    try {
      // Placeholder for Whisper API integration
      await Future.delayed(const Duration(seconds: 2));
      return "Transcribed audio message.";
    } catch (e) {
      print('Error processing audio: $e');
      return null;
    }
  }

  Future<Report> generatePreVisitReport(String userId, String sessionId) async {
    try {
      final messages = await _firestore
          .collection('users')
          .doc(userId)
          .collection('messages')
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('date')
          .get();

      final conversationHistory = messages.docs.map((doc) {
        final msg = Message.fromFirestore(doc);
        return "${msg.isUser ? 'Patient' : 'Assistant'}: ${msg.message}";
      }).join('\n\n');

      final reportPrompt = '''
        Create a structured pre-visit report based on this conversation:
        $conversationHistory
        
        Sections:
        1. Reason for Visit
        2. Symptoms
        3. Medical Background
        4. Patient Goals
      ''';
      final content = [Content.text(reportPrompt)];
      final response = await _recordingModel.generateContent(content);

      final report = Report(
        id: const Uuid().v4(),
        patientId: userId,
        doctorId: '',
        title: 'Pre-Visit Report',
        content: response.text ?? 'Error generating report',
        date: DateTime.now(),
        sections: ['Reason for Visit', 'Symptoms', 'Medical Background', 'Patient Goals'],
        status: 'draft',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reports')
          .doc(report.id)
          .set(report.toMap());

      return report;
    } catch (e) {
      print('Error generating report: $e');
      throw Exception('Failed to generate report');
    }
  }

  Future<String> processVisitRecording(String audioPath) async {
    try {
      // Placeholder for transcription
      await Future.delayed(const Duration(seconds: 2));
      const transcription = "Doctor's visit notes.";

      final summaryPrompt = '''
        Convert this transcription into a structured visit summary:
        $transcription
        
        Sections:
        1. Assessment
        2. Plan
        3. Prescriptions
        4. Follow-up
      ''';
      final content = [Content.text(summaryPrompt)];
      final response = await _recordingModel.generateContent(content);
      return response.text ?? "Error generating summary";
    } catch (e) {
      print('Error processing recording: $e');
      return "Error processing recording.";
    }
  }

  String _buildPrompt(String? promptType, String messageText, Map<String, dynamic>? healthData) {
    final context = healthData?.toString() ?? 'Not available';
    switch (promptType) {
      case 'acuteSymptom':
        return '''
          Summarize this acute symptom report in a reassuring way:
          Patient message: $messageText
          Health data: $context
          Provide practical advice without diagnosis or medication suggestions.
        ''';
      case 'chronicCondition':
        return '''
          Summarize this chronic condition update:
          Patient message: $messageText
          Health data: $context
          Reinforce positive behaviors and suggest lifestyle measures.
        ''';
      case 'medications':
        return '''
          Provide information about this medication query:
          Patient message: $messageText
          Health data: $context
          Include dosage and side effects info, suggest doctor contact if needed.
        ''';
      default:
        return '''
          Collect health information conversationally:
          Patient message: $messageText
          Health data: $context
          Provide reassurance and structure for a pre-visit report.
        ''';
    }
  }

  Future<void> _saveMessage(String userId, Message message) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }
}

