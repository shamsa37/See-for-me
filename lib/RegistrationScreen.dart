import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'BlindDashboardScreen.dart';
import 'LoginScreen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late stt.SpeechToText _speech;
  late FlutterTts _tts;

  int _currentStep = 0;

  bool isMale = false;
  bool isFemale = false;
  bool isRegistering = false;

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  List<String> steps = [
    "username",
    "email",
    "phone",
    "password",
    "gender",
    "register"
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();

    _initTTS();
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ---------------- NAVIGATION & REGISTER ----------------
  Future<void> _registerUser() async {
    if (isRegistering) return;

    setState(() => isRegistering = true);

    try {
      String cleanEmail = emailController.text.trim();
      String cleanPassword = passwordController.text.trim();

      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      if (userCredential.user != null) {
        // ✅ Saving 'name' and placeholder location to match FamilyDashboard
        await FirebaseFirestore.instance
            .collection('blind')
            .doc(userCredential.user!.uid)
            .set({
          'name': usernameController.text.trim(),
          'username': usernameController.text.trim(),
          'email': cleanEmail,
          'phone': phoneController.text.trim(),
          'gender': isMale ? 'male' : 'female',
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'live_location': {
            'latitude': 0.0,
            'longitude': 0.0,
            'last_updated': FieldValue.serverTimestamp(),
          }
        });

        await _tts.speak("Registration successful. Navigating to dashboard.");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const BlindDashboardScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      await _tts.speak("Error. ${e.message}");
    } catch (e) {
      await _tts.speak("Something went wrong");
    } finally {
      if (mounted) setState(() => isRegistering = false);
    }
  }

  // ---------------- INPUT HANDLER ----------------
  void _processInput(String input) async {
    input = input.toLowerCase().trim();

    setState(() {
      switch (_currentStep) {
        case 0:
          usernameController.text = input;
          break;
        case 1:
          emailController.text = input
              .replaceAll(" ", "")
              .replaceAll("at", "@")
              .replaceAll("dot", ".");
          break;
        case 2:
          phoneController.text = input.replaceAll(" ", "");
          break;
        case 3:
          passwordController.text = input.replaceAll(" ", "");
          break;
        case 4:
          if (input.contains("male")) {
            isMale = true;
            isFemale = false;
          } else if (input.contains("female")) {
            isFemale = true;
            isMale = false;
          } else {
            _tts.speak("Please say male or female");
            _listen();
            return;
          }
          break;
        case 5:
          if (input.contains("register")) {
            _registerUser();
            return;
          } else {
            _tts.speak("Say register to finish");
            _listen();
            return;
          }
      }

      if (_currentStep < steps.length - 1) {
        _currentStep++;
        Future.delayed(const Duration(milliseconds: 500), _speakStep);
      }
    });
  }

  // ---------------- DETAILED VOICE PROMPTS ----------------
  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.awaitSpeakCompletion(true);
    _speakStep();
  }

  void _speakStep() async {
    String message = "";
    switch (_currentStep) {
      case 0:
        message = "Please enter your username";
        break;
      case 1:
        message = "Please enter your email address";
        break;
      case 2:
        message = "Please enter your phone number";
        break;
      case 3:
        message = "Please create a password. It must be at least six characters";
        break;
      case 4:
        message = "What is your gender? Say male or female";
        break;
      case 5:
        message = "Review your details and say register to complete";
        break;
    }
    await _tts.speak(message);
    _listen();
  }

  void _listen() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        listenFor: const Duration(seconds: 10),
        onResult: (result) {
          if (result.finalResult) {
            _speech.stop();
            _processInput(result.recognizedWords);
          }
        },
      );
    }
  }

  // ---------------- ENHANCED PROFESSIONAL UI ----------------
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF8000FF).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Blind User Registration",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 25),

                      buildField(Icons.person, "Username", usernameController),
                      buildField(Icons.email, "Email", emailController),
                      buildField(Icons.phone, "Phone", phoneController),
                      buildField(Icons.lock, "Password", passwordController,
                          isPass: true),

                      // Gender Selection Container
                      Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isMale,
                                  activeColor: const Color(0xFF8000FF),
                                  side: const BorderSide(color: Colors.white60),
                                  onChanged: (v) => setState(() {
                                    isMale = v!;
                                    if (v) isFemale = false;
                                  }),
                                ),
                                const Text("Male",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isFemale,
                                  activeColor: const Color(0xFF8000FF),
                                  side: const BorderSide(color: Colors.white60),
                                  onChanged: (v) => setState(() {
                                    isFemale = v!;
                                    if (v) isMale = false;
                                  }),
                                ),
                                const Text("Female",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      isRegistering
                          ? const CircularProgressIndicator(
                          color: Color(0xFF8000FF))
                          : SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8000FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "REGISTER",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Added Sign-in Navigation Option
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Already have an account? Sign in",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white70,
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

  Widget buildField(
      IconData icon, String hint, TextEditingController c,
      {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        obscureText: isPass,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF8000FF)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white60, fontSize: 14),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF8000FF), width: 1.5),
          ),
        ),
      ),
    );
  }
}