import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  Future<void> signupUser(String email, String password, String role) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
        email: email, password: password);

    String uid = userCredential.user!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'role': role,
      'email': email,
    });
  }

  Future<void> loginUser(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password);
  }
}