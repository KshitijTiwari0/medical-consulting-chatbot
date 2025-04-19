import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_proj/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<UserModel?> get userStream => _auth.authStateChanges().asyncMap(
        (user) async {
      if (user == null) return null;
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        return null;
      } catch (e) {
        print('Error fetching user data: $e');
        return null;
      }
    },
  );

  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? inviteCode,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        String? connectedDoctorId;
        if (inviteCode != null && role == UserRole.patient) {
          final docRef = await _firestore.collection('invites').doc(inviteCode).get();
          if (docRef.exists) {
            connectedDoctorId = docRef.data()?['doctorId'];
            if (connectedDoctorId != null) {
              await _firestore.collection('users').doc(connectedDoctorId).update({
                'connectedPatientIds': FieldValue.arrayUnion([userCredential.user!.uid]),
              });
            }
          }
        }
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          photoUrl: userCredential.user!.photoURL,
          role: role,
          connectedDoctorId: connectedDoctorId,
          connectedPatientIds: role == UserRole.doctor ? [] : null,
          healthData: HealthData(),
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
        notifyListeners();
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign-up: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during sign-up: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
        final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          notifyListeners();
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign-in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during sign-in: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'lastActive': FieldValue.serverTimestamp(),
          });
          notifyListeners();
          return UserModel.fromFirestore(doc);
        } else {
          final newUser = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email!,
            name: userCredential.user!.displayName ?? '',
            photoUrl: userCredential.user!.photoURL,
            role: UserRole.patient,
            healthData: HealthData(),
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
          );
          await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
          notifyListeners();
          return newUser;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Google sign-in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during Google sign-in: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      if (userCredential.user != null) {
        final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'lastActive': FieldValue.serverTimestamp(),
          });
          notifyListeners();
          return UserModel.fromFirestore(doc);
        } else {
          String name = credential.givenName != null && credential.familyName != null
              ? '${credential.givenName} ${credential.familyName}'
              : 'Apple User';
          final newUser = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? credential.email ?? '',
            name: name,
            photoUrl: userCredential.user!.photoURL,
            role: UserRole.patient,
            healthData: HealthData(),
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
          );
          await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
          notifyListeners();
          return newUser;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Apple sign-in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during Apple sign-in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign-out: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during sign-out: $e');
      rethrow;
    }
  }

  Future<String> createInviteCode(String doctorId) async {
    try {
      final inviteDocRef = _firestore.collection('invites').doc();
      await inviteDocRef.set({
        'doctorId': doctorId,
        'createdAt': FieldValue.serverTimestamp(),
        'used': false,
      });
      notifyListeners();
      return inviteDocRef.id;
    } catch (e) {
      print('Error creating invite code: $e');
      rethrow;
    }
  }
}