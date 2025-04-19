import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_proj/models/user_model.dart';

class UserDataProvider with ChangeNotifier {
  UserModel? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => _user;

  Future<void> setUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> updateUserHealthData(String uid, HealthData healthData) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'healthData': healthData.toMap(),
      });
      if (_user != null && _user!.uid == uid) {
        _user = _user!.copyWith(healthData: healthData);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating health data: $e');
      rethrow;
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}

extension UserModelExtension on UserModel {
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    UserRole? role,
    String? connectedDoctorId,
    List<String>? connectedPatientIds,
    HealthData? healthData,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      connectedDoctorId: connectedDoctorId ?? this.connectedDoctorId,
      connectedPatientIds: connectedPatientIds ?? this.connectedPatientIds,
      healthData: healthData ?? this.healthData,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
