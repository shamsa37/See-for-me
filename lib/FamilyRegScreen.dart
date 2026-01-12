/*import 'dart:ui';
import 'package:flutter/material.dart';
import 'FamilyLoginScreen.dart';

class FamilyRegScreen extends StatefulWidget {
  const FamilyRegScreen({super.key});

  @override
  State<FamilyRegScreen> createState() => _FamilyRegScreenState();
}

class _FamilyRegScreenState extends State<FamilyRegScreen> {
  String? selectedRelation; // Dropdown value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000),
              Colors.purple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                width: 340,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      const Color(0xFF6A00F4).withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.purpleAccent.withOpacity(0.3),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "REGISTER",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),

                      _buildTextField(Icons.person, "Full Name"),
                      const SizedBox(height: 12),

                      _buildTextField(Icons.phone, "Phone Number"),
                      const SizedBox(height: 12),

                      _buildTextField(Icons.email, "Email"),
                      const SizedBox(height: 12),

                      _buildTextField(Icons.lock, "Password", obscure: true),
                      const SizedBox(height: 12),

                      _buildTextField(Icons.lock, "Confirm Password",
                          obscure: true),
                      const SizedBox(height: 12),

                      // 👇 Relationship Dropdown
                      _buildDropdownField(),

                      const SizedBox(height: 12),
                      _buildTextField(Icons.badge, "Linked Blind Code"),

                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FamilyLoginScreen()),
                          );
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Colors.white70),
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

  // TextField widget
  Widget _buildTextField(IconData icon, String label,
      {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.purpleAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Colors.purpleAccent, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
      ),
    );
  }

  // Dropdown for Relationship
  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purpleAccent, width: 0.8),
        color: Colors.white.withOpacity(0.05),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.black87,
        value: selectedRelation,
        style: const TextStyle(color: Colors.white),
        iconEnabledColor: Colors.purpleAccent,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.favorite, color: Colors.purpleAccent),
          labelText: "Relationship",
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: const [
          DropdownMenuItem(value: "Father", child: Text("Father")),
          DropdownMenuItem(value: "Mother", child: Text("Mother")),
          DropdownMenuItem(value: "Brother", child: Text("Brother")),
          DropdownMenuItem(value: "Sister", child: Text("Sister")),
        ],
        onChanged: (value) {
          setState(() {
            selectedRelation = value;
          });
        },
      ),
    );
  }
}*/

/*import 'dart:ui';
import 'package:flutter/material.dart';

class FamilyRegScreen extends StatefulWidget {
  const FamilyRegScreen({super.key});

  @override
  State<FamilyRegScreen> createState() => _FamilyRegScreenState();
}

class _FamilyRegScreenState extends State<FamilyRegScreen> {
  String? selectedRelation;

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
              Color(0xFF0B0211),
              Color(0xFF2E0249),
              Color(0xFF570A57),
              Color(0xFF570A57),
              Color(0xFF0B0211),
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF8000FF).withOpacity(0.5),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8000FF).withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Family Registration",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Full Name
                      _buildTextField(Icons.person, "Full Name"),
                      const SizedBox(height: 15),

                      // Phone Number
                      _buildTextField(Icons.phone, "Phone Number"),
                      const SizedBox(height: 15),

                      // Email
                      _buildTextField(Icons.email, "Email"),
                      const SizedBox(height: 15),

                      // Password
                      _buildTextField(Icons.lock, "Password", isPassword: true),
                      const SizedBox(height: 15),

                      // Confirm Password
                      _buildTextField(Icons.lock_outline, "Confirm Password",
                          isPassword: true),
                      const SizedBox(height: 15),

                      // Relationship Dropdown
                      _buildDropdownField(Icons.favorite, "Relationship"),
                      const SizedBox(height: 15),

                      // Linked Blind Code
                      _buildTextField(Icons.qr_code, "Linked Blind Code"),
                      const SizedBox(height: 30),

                      // Register Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8000FF),
                              Color(0xFF570A57),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF8000FF).withOpacity(0.5),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {},
                        child: const Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.white70),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: Color(0xFF8000FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildTextField(IconData icon, String hint,
      {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF8000FF)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: const Color(0xFF8000FF).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF8000FF),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(IconData icon, String label) {
    return DropdownButtonFormField<String>(
      value: selectedRelation,
      dropdownColor: const Color(0xFF1A001F),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: const Color(0xFF8000FF),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8000FF)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        hintText: label,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
          BorderSide(color: const Color(0xFF8000FF).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
          const BorderSide(color: Color(0xFF8000FF), width: 2),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "Father", child: Text("Father")),
        DropdownMenuItem(value: "Mother", child: Text("Mother")),
        DropdownMenuItem(value: "Brother", child: Text("Brother")),
        DropdownMenuItem(value: "Sister", child: Text("Sister")),
        DropdownMenuItem(value: "Friend", child: Text("Friend")),
        DropdownMenuItem(value: "Other", child: Text("Other")),
        DropdownMenuItem(value: "None", child: Text("None")),
      ],
      onChanged: (value) {
        setState(() {
          selectedRelation = value;
        });
      },
    );
  }
}*/
import 'dart:ui';
import 'package:flutter/material.dart';
import 'FamilyLoginScreen.dart';
import 'FamilyDashboard.dart';

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

  void _registerUser() {
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  FamilyDashboard()),
    );
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
              Color(0xFF0B0211),
              Color(0xFF2E0249),
              Color(0xFF570A57),
              Color(0xFF570A57),
              Color(0xFF0B0211),
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF8000FF).withOpacity(0.5),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8000FF).withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Family Registration",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
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

                      // Register Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8000FF),
                              Color(0xFF570A57),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF8000FF).withOpacity(0.5),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _registerUser,
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const FamilyLoginScreen()),
                          );
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.white70),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: Color(0xFF8000FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
        prefixIcon: Icon(icon, color: Color(0xFF8000FF)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: const Color(0xFF8000FF).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF8000FF),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(IconData icon, String label) {
    return DropdownButtonFormField<String>(
      value: selectedRelation,
      isExpanded: true,
      dropdownColor: const Color(0xFF1A001F),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: const Color(0xFF8000FF),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8000FF)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        hintText: label,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
          BorderSide(color: const Color(0xFF8000FF).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
          const BorderSide(color: Color(0xFF8000FF), width: 2),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "Father", child: Text("Father")),
        DropdownMenuItem(value: "Mother", child: Text("Mother")),
        DropdownMenuItem(value: "Brother", child: Text("Brother")),
        DropdownMenuItem(value: "Sister", child: Text("Sister")),
        DropdownMenuItem(value: "Friend", child: Text("Friend")),
        DropdownMenuItem(value: "Other", child: Text("Other")),
      ],
      onChanged: (value) {
        setState(() {
          selectedRelation = value;
        });
      },
    );
  }
}