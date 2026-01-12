/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'BlindDashboardScreen.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _nameDone = false;
  bool _emailDone = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('userName') ?? '';
    _emailController.text = prefs.getString('userEmail') ?? '';

    await Future.delayed(const Duration(seconds: 1));
    await _announceCurrentInfo();
  }

  Future<void> _announceCurrentInfo() async {
    String name = _nameController.text.isEmpty ? "not set" : _nameController.text;
    String email = _emailController.text.isEmpty ? "not set" : _emailController.text;

    await flutterTts.speak(
        "Edit profile screen opened. Your current name is $name and your email is $email. "
            "Please say your name to update it.");

    await Future.delayed(const Duration(seconds: 4));
    _startListening("name");
  }

  Future<void> _startListening(String field) async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      await flutterTts.speak("Listening for your $field");

      _speech.listen(onResult: (result) async {
        if (result.finalResult) {
          String spoken = result.recognizedWords.toLowerCase();
          setState(() {
            if (field == "name") {
              _nameController.text = result.recognizedWords;
              _nameDone = true;
            } else if (field == "email") {
              _emailController.text = result.recognizedWords;
              _emailDone = true;
            }
          });

          _speech.stop();
          setState(() => _isListening = false);

          if (spoken.contains("save")) {
            await _saveProfile();
            return;
          }

          if (field == "name") {
            await flutterTts.speak("Name saved as ${_nameController.text}. Now please say your email.");
            await Future.delayed(const Duration(seconds: 2));
            _startListening("email");
          } else if (field == "email") {
            await flutterTts.speak("Email saved as ${_emailController.text}. Say save to confirm your profile.");
            await Future.delayed(const Duration(seconds: 3));
            _startListening("save"); // listen for save command
          } else if (field == "save") {
            if (spoken.contains("save")) {
              await _saveProfile();
            } else {
              await flutterTts.speak("Please say save to confirm.");
              await Future.delayed(const Duration(seconds: 2));
              _startListening("save");
            }
          }
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userEmail', _emailController.text);

    await flutterTts.speak("Profile updated successfully. Returning to dashboard.");

    await Future.delayed(const Duration(seconds: 3));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BlindDashboardScreen()),
    );

    Future.delayed(const Duration(seconds: 2), () async {
      await flutterTts.speak("You are on Blind Dashboard now.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'BlindDashboardScreen.dart';
import 'dart:ui';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('userName') ?? '';
    _emailController.text = prefs.getString('userEmail') ?? '';
    // aur agar TTS/voice logic hai to wahan handle kar lo
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userEmail', _emailController.text);
    await flutterTts.speak("Profile saved");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BlindDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: Center(
        child: SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.shade300.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Name",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.25),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                          BorderSide(color: Colors.purple, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.25),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                          BorderSide(color: Colors.purple, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: _saveProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
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
    );
  }
}
