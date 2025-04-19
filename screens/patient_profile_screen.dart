import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_proj/models/user_model.dart';
import 'package:flutter_proj/services/ai_service.dart';
import 'package:flutter_proj/models/report_model.dart';
import 'package:flutter_proj/screens/report_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  final UserModel patient;
  final UserModel doctor;
  const PatientProfileScreen({super.key, required this.patient, required this.doctor});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late AIService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = AIService(apiKey: '');
  }

  Future<void> _recordVisit() async {
    const audioPath = 'dummy_path';
    final summary = await _aiService.processVisitRecording(audioPath);
    final report = Report(
      id: DateTime.now().toString(),
      patientId: widget.patient.uid,
      doctorId: widget.doctor.uid,
      title: 'Visit Summary',
      content: summary,
      date: DateTime.now(),
      sections: ['Assessment', 'Plan', 'Prescriptions', 'Follow-up'],
      status: 'draft',
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patient.uid)
        .collection('reports')
        .doc(report.id)
        .set(report.toMap());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportScreen(report: report)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: _recordVisit,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${widget.patient.email}'),
                Text('Conditions: ${widget.patient.healthData.conditions.join(', ')}'),
                Text('Medications: ${widget.patient.healthData.medications.join(', ')}'),
                Text('Allergies: ${widget.patient.healthData.allergies.join(', ')}'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.patient.uid)
                  .collection('reports')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final reports = snapshot.data!.docs.map((doc) => Report.fromFirestore(doc)).toList();
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return ListTile(
                        title: Text(report.title),
                        subtitle: Text(report.date.toString()),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReportScreen(report: report)),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}