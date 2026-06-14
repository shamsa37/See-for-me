import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Dashboard screen ka placeholder (Isay apne dashboard file se link karein)
// import 'package:your_app/blind_dashboard.dart';

class RegistrationScreen extends StatefulWidget {
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

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      if (userCredential.user != null) {
        // Firestore Data Save
        await FirebaseFirestore.instance.collection('blind').doc(userCredential.user!.uid).set({
          'username': usernameController.text.trim(),
          'email': cleanEmail,
          'phone': phoneController.text.trim(),
          'gender': isMale ? 'male' : 'female',
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _tts.speak("Registration successful. Navigating to dashboard.");

        // ---------------- NAVIGATION ----------------
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BlindDashboard()), // Apni class ka sahi naam likhein
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
          emailController.text = input.replaceAll(" ", "").replaceAll("at", "@").replaceAll("dot", ".");
          break;
        case 2:
          phoneController.text = input.replaceAll(" ", "");
          break;
        case 3:
          passwordController.text = input.replaceAll(" ", "");
          break;
        case 4:
          if (input.contains("male")) {
            isMale = true; isFemale = false;
          } else if (input.contains("female")) {
            isFemale = true; isMale = false;
          } else {
            _tts.speak("Please say male or female");
            _listen(); return;
          }
          break;
        case 5:
          if (input.contains("register")) {
            _registerUser(); return;
          } else {
            _tts.speak("Say register to finish");
            _listen(); return;
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
      case 0: message = "Please enter your username"; break;
      case 1: message = "Please enter your email address"; break;
      case 2: message = "Please enter your phone number"; break;
      case 3: message = "Please create a password. It must be at least six characters"; break;
      case 4: message = "What is your gender? Say male or female"; break;
      case 5: message = "Review your details and say register to complete"; break;
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

  // ---------------- UI (UNCHANGED) ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFFF3E5F5)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text("Registration", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 20),
                  buildField("Username", usernameController),
                  buildField("Email", emailController),
                  buildField("Phone", phoneController),
                  buildField("Password", passwordController, isPass: true),
                  Row(
                    children: [
                      Checkbox(value: isMale, onChanged: (v) => setState(() { isMale = v!; if (v) isFemale = false; })),
                      const Text("Male", style: TextStyle(color: Colors.black)),
                      Checkbox(value: isFemale, onChanged: (v) => setState(() { isFemale = v!; if (v) isMale = false; })),
                      const Text("Female", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  isRegistering
                      ? const CircularProgressIndicator()
                      : ElevatedButton(onPressed: _registerUser, child: const Text("REGISTER")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField(String hint, TextEditingController c, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        obscureText: isPass,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// Dummy Dashboard Class (Agar aapke paas already hai to isay delete kar dein)
class BlindDashboard extends StatelessWidget {
  const BlindDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Dashboard")));
  }
}