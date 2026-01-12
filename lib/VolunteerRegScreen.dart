import 'dart:ui';
import 'package:flutter/material.dart';
import "package:project/VolunteerDashboard.dart";
import 'package:animate_do/animate_do.dart'; // 🎞️ Animation library

class VolunteerRegScreen extends StatefulWidget {
  const VolunteerRegScreen({super.key});

  @override
  State<VolunteerRegScreen> createState() => _VolunteerRegScreenState();
}

class _VolunteerRegScreenState extends State<VolunteerRegScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String phoneNumber = '';
  String password = '';
  String? gender; // ✅ Replaced checkboxes with a single value

  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    // ⚡ Smooth animated gradient background
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: const Color(0xFF0B0211),
      end: const Color(0xFF2E0249),
    ).animate(_controller);

    _color2 = ColorTween(
      begin: const Color(0xFF8000FF),
      end: const Color(0xFF570A57),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (gender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select gender")),
        );
        return;
      }
      _formKey.currentState!.save();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VolunteerDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_color1.value!, _color2.value!],
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
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF8000FF).withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8000FF).withOpacity(0.3),
                            blurRadius: 25,
                            spreadRadius: 3,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// 🌟 Icon Animation
                            SlideInDown(
                              duration: const Duration(milliseconds: 1000),
                              child: const Icon(
                                Icons.volunteer_activism,
                                color: Color(0xFF9D4EDD),
                                size: 65,
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// 🌟 Main Heading
                            SlideInRight(
                              duration: const Duration(milliseconds: 800),
                              child: const Text(
                                "Register Yourself",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.purpleAccent,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            /// 👤 Username Field
                            SlideInLeft(
                              duration: const Duration(milliseconds: 800),
                              child: _buildTextField(
                                icon: Icons.person,
                                label: "Username",
                                onSaved: (val) => username = val!,
                                validator: (v) =>
                                v!.isEmpty ? "Enter Username" : null,
                              ),
                            ),
                            const SizedBox(height: 15),

                            /// 📧 Email Field
                            SlideInRight(
                              duration: const Duration(milliseconds: 900),
                              child: _buildTextField(
                                icon: Icons.email,
                                label: "Email",
                                keyboardType: TextInputType.emailAddress,
                                onSaved: (val) => email = val!,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "Enter Email";
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(v)) {
                                    return "Enter valid Email";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 15),

                            /// 📱 Phone Number Field
                            SlideInLeft(
                              duration: const Duration(milliseconds: 1000),
                              child: _buildTextField(
                                icon: Icons.phone,
                                label: "Phone Number",
                                keyboardType: TextInputType.phone,
                                onSaved: (val) => phoneNumber = val!,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "Enter Phone Number";
                                  }
                                  if (!RegExp(r'^[0-9]{10,15}$').hasMatch(v)) {
                                    return "Enter valid Phone Number";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 15),

                            /// 🔒 Password Field
                            SlideInRight(
                              duration: const Duration(milliseconds: 1100),
                              child: _buildTextField(
                                icon: Icons.lock,
                                label: "Password",
                                isPassword: true,
                                onSaved: (val) => password = val!,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "Enter Password";
                                  }
                                  if (v.length < 8) {
                                    return "Min 8 characters";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// 🚻 Gender Selection (Radio Buttons)
                            SlideInLeft(
                              duration: const Duration(milliseconds: 1150),
                              child: Row(
                                children: [
                                  const Text(
                                    'Gender:',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Radio<String>(
                                    value: 'Male',
                                    groupValue: gender,
                                    onChanged: (val) =>
                                        setState(() => gender = val),
                                    activeColor: const Color(0xFF9D4EDD),
                                  ),
                                  const Text('Male',
                                      style: TextStyle(color: Colors.white70)),
                                  Radio<String>(
                                    value: 'Female',
                                    groupValue: gender,
                                    onChanged: (val) =>
                                        setState(() => gender = val),
                                    activeColor: const Color(0xFF9D4EDD),
                                  ),
                                  const Text('Female',
                                      style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            /// 🟣 Register Button
                            SlideInUp(
                              duration: const Duration(milliseconds: 1200),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8000FF),
                                      Color(0xFF570A57),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF8000FF).withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: _register,
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
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
          ),
        );
      },
    );
  }

  /// 🔧 Reusable TextField Builder
  Widget _buildTextField({
    required IconData icon,
    required String label,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF9D4EDD)),
        hintText: label,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
          BorderSide(color: const Color(0xFF9D4EDD).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF9D4EDD), width: 2),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
