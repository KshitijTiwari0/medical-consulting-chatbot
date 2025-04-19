import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_proj/services/auth_service.dart';
import 'package:flutter_proj/models/user_model.dart';
import 'package:flutter_proj/screens/login_screen.dart';
import 'package:flutter_proj/screens/patient_dashboard.dart';
import 'package:flutter_proj/screens/doctor_dashboard.dart';
import 'package:flutter_proj/services/user_data_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<UserModel?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        print('AuthWrapper build: snapshot=${snapshot.data?.uid}, connectionState=${snapshot.connectionState}, hasError=${snapshot.hasError}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          print('Error in userStream: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        } else {
          final user = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<UserDataProvider>(context, listen: false).setUser(user.uid);
          });
          if (user.role == UserRole.patient) {
            return PatientDashboard(user: user);
          } else {
            return DoctorDashboard(user: user);
          }
        }
      },
    );
  }
}