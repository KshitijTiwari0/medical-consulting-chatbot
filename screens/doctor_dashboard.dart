import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_proj/models/user_model.dart';
import 'package:flutter_proj/screens/patient_profile_screen.dart';
import 'package:flutter_proj/services/auth_service.dart';

class DoctorDashboard extends StatefulWidget {
  final UserModel user;
  const DoctorDashboard({super.key, required this.user});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = UserModel.fromFirestore(snapshot.data!);
            final patientIds = userData.connectedPatientIds ?? [];
            return ListView.builder(
              itemCount: patientIds.length,
              itemBuilder: (context, index) {
                final patientId = patientIds[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
                  builder: (context, patientSnapshot) {
                    if (patientSnapshot.hasData) {
                      final patient = UserModel.fromFirestore(patientSnapshot.data!);
                      return ListTile(
                        title: Text(patient.name),
                        subtitle: Text(patient.email),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientProfileScreen(patient: patient, doctor: widget.user),
                            ),
                          );
                        },
                      );
                    } else {
                      return const ListTile(title: Text('Loading...'));
                    }
                  },
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}