import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String patientId;
  final String doctorId;
  final String title;
  final String content;
  final DateTime date;
  final List<String> sections;
  final String status;

  Report({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.title,
    required this.content,
    required this.date,
    required this.sections,
    required this.status,
  });

  /// Factory constructor to create a Report from Firestore DocumentSnapshot
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Safely convert Firestore Timestamp to DateTime
    final timestamp = data['date'] as Timestamp?;
    final date = timestamp?.toDate() ?? DateTime.now(); // fallback to current time if null

    return Report(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: date,
      sections: List<String>.from(data['sections'] ?? []),
      status: data['status'] ?? 'draft',
    );
  }

  /// Convert Report object to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'sections': sections,
      'status': status,
    };
  }
}
