import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { patient, doctor }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final UserRole role;
  final String? connectedDoctorId;
  final List<String>? connectedPatientIds;
  final HealthData healthData;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.role,
    this.connectedDoctorId,
    this.connectedPatientIds,
    required this.healthData,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] == 'doctor' ? UserRole.doctor : UserRole.patient,
      connectedDoctorId: data['connectedDoctorId'],
      connectedPatientIds: data['connectedPatientIds'] != null
          ? List<String>.from(data['connectedPatientIds'])
          : null,
      healthData: HealthData.fromMap(data['healthData'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role == UserRole.doctor ? 'doctor' : 'patient',
      'connectedDoctorId': connectedDoctorId,
      'connectedPatientIds': connectedPatientIds,
      'healthData': healthData.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }
}

class HealthData {
  List<String> medications;
  List<String> conditions;
  List<String> allergies;
  Map<String, dynamic> demographics;
  List<HealthEvent> events;

  HealthData({
    this.medications = const [],
    this.conditions = const [],
    this.allergies = const [],
    Map<String, dynamic>? demographics,
    this.events = const [],
  }) : demographics = demographics ?? {};

  factory HealthData.fromMap(Map<String, dynamic> data) {
    return HealthData(
      medications: data['medications'] != null
          ? List<String>.from(data['medications'])
          : [],
      conditions: data['conditions'] != null
          ? List<String>.from(data['conditions'])
          : [],
      allergies: data['allergies'] != null
          ? List<String>.from(data['allergies'])
          : [],
      demographics: data['demographics'] ?? {},
      events: data['events'] != null
          ? (data['events'] as List).map((e) => HealthEvent.fromMap(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medications': medications,
      'conditions': conditions,
      'allergies': allergies,
      'demographics': demographics,
      'events': events.map((e) => e.toMap()).toList(),
    };
  }
}

class HealthEvent {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime date;
  final String? doctorId;
  final String? patientId;
  final Map<String, dynamic> details;

  HealthEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.doctorId,
    this.patientId,
    this.details = const {},
  });

  factory HealthEvent.fromMap(Map<String, dynamic> data) {
    return HealthEvent(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      doctorId: data['doctorId'],
      patientId: data['patientId'],
      details: data['details'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'date': Timestamp.fromDate(date),
      'doctorId': doctorId,
      'patientId': patientId,
      'details': details,
    };
  }
}