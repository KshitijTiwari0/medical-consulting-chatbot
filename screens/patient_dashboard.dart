import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_proj/services/ai_service.dart';
import 'package:flutter_proj/models/user_model.dart';
import 'package:flutter_proj/models/message_model.dart';
import 'package:flutter_proj/widgets/message_bubble.dart';
import 'package:flutter_proj/screens/report_screen.dart';
import 'package:flutter_proj/services/auth_service.dart';

class PatientDashboard extends StatefulWidget {
  final UserModel user;
  const PatientDashboard({super.key, required this.user});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final TextEditingController _messageController = TextEditingController();
  late AIService _aiService;
  late String _sessionId;
  late Stream<List<Message>> _messagesStream;
  String _selectedPromptType = 'general';

  @override
  void initState() {
    super.initState();
    _aiService = AIService(apiKey: '');
    _sessionId = _aiService.createNewSession(widget.user.uid);
    _messagesStream = _aiService.getMessagesForSession(widget.user.uid, _sessionId);
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;
    _messageController.clear();
    await _aiService.processMessage(
      userId: widget.user.uid,
      messageText: messageText,
      sessionId: _sessionId,
      promptType: _selectedPromptType,
      healthData: widget.user.healthData.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with MediFlow'),
        actions: [
          DropdownButton<String>(
            value: _selectedPromptType,
            items: const [
              DropdownMenuItem(value: 'general', child: Text('General')),
              DropdownMenuItem(value: 'acuteSymptom', child: Text('Acute Symptom')),
              DropdownMenuItem(value: 'chronicCondition', child: Text('Chronic Condition')),
              DropdownMenuItem(value: 'medications', child: Text('Medications')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedPromptType = value);
            },
          ),
          IconButton(
            icon: const Icon(Icons.report),
            onPressed: () async {
              final report = await _aiService.generatePreVisitReport(widget.user.uid, _sessionId);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportScreen(report: report)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) => MessageBubble(message: messages[index]),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

