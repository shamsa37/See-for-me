import 'dart:ui';
import 'package:flutter/material.dart';
import 'FamilyLoginScreen.dart';
import 'FamilyDashboard.dart';
import 'auth_service.dart';

class FamilyRegScreen extends StatefulWidget {
  const FamilyRegScreen({super.key});

  @override
  State<FamilyRegScreen> createState() => _FamilyRegScreenState();
}

class _FamilyRegScreenState extends State<FamilyRegScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController blindCodeController = TextEditingController();

  String? selectedRelation;

  void _registerUser() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passController.text.isEmpty ||
        confirmController.text.isEmpty ||
        blindCodeController.text.isEmpty ||
        selectedRelation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all fields before registering."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (passController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await AuthService().signupUser(
        emailController.text.trim(),
        passController.text.trim(),
        "family",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FamilyDashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B0211),
              Color(0xFF2E0249),
              Color(0xFF570A57),
              Color(0xFF0B0211),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF8000FF).withOpacity(0.5),
                      width: 1.8,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Family Registration",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildTextField(Icons.person, "Full Name", nameController),
                      const SizedBox(height: 15),

                      _buildTextField(Icons.phone, "Phone Number", phoneController),
                      const SizedBox(height: 15),

                      _buildTextField(Icons.email, "Email", emailController),
                      const SizedBox(height: 15),

                      _buildTextField(Icons.lock, "Password", passController, isPassword: true),
                      const SizedBox(height: 15),

                      _buildTextField(Icons.lock_outline, "Confirm Password", confirmController, isPassword: true),
                      const SizedBox(height: 15),

                      _buildDropdownField(Icons.favorite, "Relationship"),
                      const SizedBox(height: 15),

                      _buildTextField(Icons.qr_code, "Linked Blind Code", blindCodeController),

                      const SizedBox(height: 30),

                      /// 🔥 BUTTON UPDATED
                      ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8000FF),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white, // ✅ WHITE TEXT
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FamilyLoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8000FF)),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  /// 🔥 DROPDOWN UPDATED
  Widget _buildDropdownField(IconData icon, String label) {
    return DropdownButtonFormField<String>(
      value: selectedRelation,
      dropdownColor: const Color(0xFF1A001F),
      style: const TextStyle(color: Colors.white), // ✅ SELECTED TEXT WHITE
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8000FF)),
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "Father", child: Text("Father", style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: "Mother", child: Text("Mother", style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: "Brother", child: Text("Brother", style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: "Sister", child: Text("Sister", style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: "Friend", child: Text("Friend", style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: "Other", child: Text("Other", style: TextStyle(color: Colors.white))),
      ],
      onChanged: (value) {
        setState(() {
          selectedRelation = value;
        });
      },
    );
  }
}