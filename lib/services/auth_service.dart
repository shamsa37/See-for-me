// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // 🔥 SIGNUP (ALL USERS: volunteer / blind / family)
//   Future<void> signupUser({
//     required String email,
//     required String password,
//     required String role,
//     required String username,
//     required String gender,
//   }) async {
//     try {
//       // 1. Create user in Firebase Auth
//       UserCredential userCredential =
//       await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       String uid = userCredential.user!.uid;
//
//       // 2. Save user data in Firestore
//       await _firestore.collection('users').doc(uid).set({
//         'uid': uid,
//         'username': username,
//         'email': email,
//         'gender': gender,
//         'role': role, // volunteer / blind / family
//
//         // 🔥 availability only for volunteers
//         'isAvailable': role == 'volunteer',
//
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       debugPrint("Signup Error: $e");
//       rethrow;
//     }
//   }
//
//   // 🔥 LOGIN + ROLE ROUTING (MAIN FUNCTION)
//   Future<void> loginAndRoute({
//     required String email,
//     required String password,
//     required BuildContext context,
//   }) async {
//     try {
//       // 1. Login
//       UserCredential user =
//       await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       String uid = user.user!.uid;
//
//       // 2. Get user data
//       DocumentSnapshot doc =
//       await _firestore.collection('users').doc(uid).get();
//
//       if (!doc.exists) {
//         throw Exception("User not found in Firestore");
//       }
//
//       String role = doc['role'] ?? 'blind';
//
//       // 3. Route user
//       switch (role) {
//         case 'volunteer':
//           Navigator.pushReplacementNamed(context, '/volunteer');
//           break;
//
//         case 'blind':
//           Navigator.pushReplacementNamed(context, '/blind');
//           break;
//
//         case 'family':
//           Navigator.pushReplacementNamed(context, '/family');
//           break;
//
//         default:
//           Navigator.pushReplacementNamed(context, '/blind');
//       }
//     } catch (e) {
//       debugPrint("Login Error: $e");
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Login failed. Please try again."),
//         ),
//       );
//     }
//   }
//
//   // 🔥 CURRENT USER
//   User? currentUser() {
//     return _auth.currentUser;
//   }
//
//   // 🔥 GET USER DATA
//   Future<DocumentSnapshot> getUserData(String uid) {
//     return _firestore.collection('users').doc(uid).get();
//   }
//
//   // 🔥 LOGOUT
//   Future<void> logout() async {
//     await _auth.signOut();
//   }
//
//   // 🔥 RESET PASSWORD
//   Future<void> resetPassword(String email) async {
//     await _auth.sendPasswordResetEmail(email: email);
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= LOGIN =================
  Future<UserCredential> loginUser(
      String email,
      String password,
      ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  // ================= SIGNUP =================
  Future<void> signupUser({
    required String email,
    required String password,
    required String role,
    required String username,
    required String gender,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email.trim().toLowerCase(),
        'gender': gender,
        'role': role, // blind / volunteer / family
        'isOnline': true,
        'isAvailable': role == 'volunteer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Signup failed");
    }
  }

  // ================= ROLE ROUTING =================
  Future<void> loginAndRoute({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential user = await loginUser(email, password);
      String uid = user.user!.uid;

      DocumentSnapshot doc =
      await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception("User not found");
      }

      Map<String, dynamic> data =
      doc.data() as Map<String, dynamic>;

      String role = data['role'] ?? 'blind';

      // 🔥 safer navigation
      Widget screen;

      switch (role) {
        case 'volunteer':
          screen = const Placeholder(); // replace with VolunteerHome()
          break;
        case 'blind':
          screen = const Placeholder(); // replace with BlindHome()
          break;
        case 'family':
          screen = const Placeholder(); // replace with FamilyHome()
          break;
        default:
          screen = const Placeholder();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ================= USER HELPERS =================
  User? currentUser() => _auth.currentUser;

  Future<DocumentSnapshot> getUserData(String uid) =>
      _firestore.collection('users').doc(uid).get();

  // ================= LOGOUT =================
  Future<void> logout() async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({
        'isOnline': false,
      });
    }

    await _auth.signOut();
  }

  // ================= RESET PASSWORD =================
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }
}