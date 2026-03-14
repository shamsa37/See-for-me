import 'package:flutter/material.dart';

import 'LoginScreen.dart';
import 'FamilyLoginScreen.dart';
import 'VolunteerLoginScreen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Select Your Role",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(), // const hata diya
                  ),
                );
              },
              child: const Text("Blind"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FamilyLoginScreen(), // const hata diya
                  ),
                );
              },
              child: const Text("Family"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VolunteerLoginScreen(), // const hata diya
                  ),
                );
              },
              child: const Text("Volunteer"),
            ),
          ],
        ),
      ),
    );
  }
}