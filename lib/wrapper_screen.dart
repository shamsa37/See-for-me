import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'role_selection_screen.dart';
import 'BlindDashboardScreen.dart';
import 'FamilyDashboard.dart';
import 'VolunteerDashboard.dart';

class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {

        // 🔹 Show loading while checking auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 🔹 If user is logged in
        if (authSnapshot.hasData) {
          final user = authSnapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, roleSnapshot) {

              // Loading while fetching role
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // If no user document found
              if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
                return const Scaffold(
                  body: Center(
                    child: Text("User data not found"),
                  ),
                );
              }

              final data =
              roleSnapshot.data!.data() as Map<String, dynamic>;

              final role = data['role'];

              // 🔹 Role based navigation
              if (role == 'blind') {
                return const BlindDashboardScreen();
              } else if (role == 'family') {
                return const FamilyDashboard();
              } else if (role == 'volunteer') {
                return const VolunteerDashboard();
              } else {
                return const Scaffold(
                  body: Center(
                    child: Text("Invalid role found"),
                  ),
                );
              }
            },
          );
        }

        // 🔹 If user NOT logged in
        return const RoleSelectionScreen();
      },
    );
  }
}