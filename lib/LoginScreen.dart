// import 'package:flutter/material.dart';
// import 'package:project/BlindDashboardScreen.dart';
// import 'RegistrationScreen.dart';
// import 'ForgotPassword.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// void main() => runApp(MaterialApp(home: LoginScreen()));
//
// class LoginScreen extends StatefulWidget {
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   late FlutterTts flutterTts;
//   late stt.SpeechToText speech;
//   bool isListening = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initVoice();
//   }
//
//   Future<void> _initVoice() async {
//     flutterTts = FlutterTts();
//     speech = stt.SpeechToText();
//
//     await Permission.microphone.request();
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setSpeechRate(0.4);
//     await flutterTts.setPitch(1.0);
//     await flutterTts.awaitSpeakCompletion(true);
//
//     await _speak(
//         "Welcome to the login screen. Do you have an account? Please say yes or no.");
//     await _startListeningAccountCheck();
//   }
//
//   Future<void> _speak(String text) async {
//     await flutterTts.stop();
//     await speech.stop();
//     await flutterTts.awaitSpeakCompletion(true);
//     await flutterTts.speak(text);
//   }
//
//   Future<void> _stopListening() async {
//     if (isListening) {
//       await speech.stop();
//       setState(() => isListening = false);
//     }
//   }
//
//   // Step 1: Ask if user has an account
//   Future<void> _startListeningAccountCheck() async {
//     bool available = await speech.initialize();
//     if (!available) {
//       await _speak("Speech recognition not available.");
//       return;
//     }
//
//     setState(() => isListening = true);
//     speech.listen(
//       listenFor: const Duration(seconds: 10),
//       onResult: (result) async {
//         String cmd = result.recognizedWords.toLowerCase();
//         await _stopListening();
//         if (cmd.contains("yes")) {
//           await _speak(
//               "Great. Let's log in. Please say your email.");
//           await _startListeningEmail();
//         } else if (cmd.contains("no")) {
//           await _speak("Okay. Redirecting you to the registration screen.");
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => RegistrationScreen()),
//           ).then((_) => _initVoice());
//         } else {
//           await _speak("Sorry, I did not understand. Please say yes or no.");
//           await _startListeningAccountCheck();
//         }
//       },
//     );
//   }
//
//   // Step 2: Listen for email or phone
//   Future<void> _startListeningEmail() async {
//     if (!speech.isAvailable) return;
//
//     if (emailController.text.isEmpty) {
//       await _speak("Please say your email address.");
//     }
//
//     setState(() => isListening = true);
//
//     speech.listen(
//         listenFor: const Duration(seconds: 12),
//         onResult: (result) async {
//           if (result.finalResult && result.recognizedWords.isNotEmpty) {
//             await _stopListening();
//
//             String input = result.recognizedWords.replaceAll(" ", "");
//
//             bool looksLikeEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input);
//
//             if (!looksLikeEmail) {
//               await _speak("Please say a valid email address.");
//               await _startListeningEmail(); // same function call
//               return;
//             }
//
//             emailController.text = input;
//
//             await _speak("You said $input. Now please say your password.");
//             await _startListeningPassword();
//           }
//         }
//     );
//   }
//
//   // Step 3: Listen for password
//   Future<void> _startListeningPassword() async {
//     if (!speech.isAvailable) return;
//
//     setState(() => isListening = true);
//     await _speak("Please say your password now.");
//
//     speech.listen(
//       listenFor: const Duration(seconds: 10),
//       onResult: (result) async {
//         if (result.finalResult && result.recognizedWords.isNotEmpty) {
//           await _stopListening();
//           passwordController.text = result.recognizedWords;
//           await _speak(
//               "Password recorded. Say login to proceed, or say forgot password, or say register now.");
//           await _startListeningCommands();
//         }
//       },
//     );
//   }
//
//   // Step 4: Listen for commands
//   Future<void> _startListeningCommands() async {
//     if (!speech.isAvailable) return;
//
//     setState(() => isListening = true);
//     await _speak("Please say your command.");
//
//     speech.listen(
//       listenFor: const Duration(seconds: 10),
//       onResult: (result) async {
//         String cmd = result.recognizedWords.toLowerCase().trim();
//         await _stopListening();
//         print("Detected command: $cmd");
//
//         if (cmd.contains("login")) {
//           await _speak("Logging you in now.");
//           _login();
//         } else if (cmd.contains("forgot")) {
//           await _speak("Opening forgot password screen.");
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => ForgotPassword()),
//           ).then((_) => _initVoice());
//         } else if (cmd.contains("register") || cmd.contains("signup")) {
//           await _speak("Opening registration screen.");
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => RegistrationScreen()),
//           ).then((_) => _initVoice());
//         } else {
//           await _speak(
//               "Command not recognized. Please say login, register, or forgot password.");
//           await _startListeningCommands();
//         }
//       },
//     );
//   }
//
//   // 🔹 Firebase login with role check
//   void _login() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         // Firebase login
//         UserCredential userCredential = await FirebaseAuth.instance
//             .signInWithEmailAndPassword(
//             email: emailController.text.trim(),
//             password: passwordController.text.trim());
//
//         // Fetch role from Firestore
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(userCredential.user!.uid)
//             .get();
//
//         String role = '';
//
//         if (userDoc.exists && userDoc.data() != null) {
//           role = userDoc.get('role') ?? '';
//         }
//
//         if (role == 'blind') {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => BlindDashboardScreen()),
//           );
//         } else {
//           await _speak(
//               "This account is not registered as a blind user. Please use the correct login.");
//         }
//       } on FirebaseAuthException catch (e) {
//         String message = '';
//         if (e.code == 'user-not-found') {
//           message = 'No user found for that email.';
//         } else if (e.code == 'wrong-password') {
//           message = 'Wrong password provided.';
//         } else {
//           message = e.message ?? 'Login failed.';
//         }
//         await _speak(message);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     flutterTts.stop();
//     speech.stop();
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   // UI
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF7B1FA2), Color(0xFFF3E5F5)],
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Container(
//               width: 350,
//               padding: const EdgeInsets.all(30),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black26, blurRadius: 8)
//                 ],
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Login',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 30,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     buildInputField(
//                       controller: emailController,
//                       icon: Icons.email,
//                       hint: 'Email',
//                       isPassword: false,
//                     ),
//                     buildInputField(
//                       controller: passwordController,
//                       icon: Icons.lock,
//                       hint: 'Password',
//                       isPassword: true,
//                     ),
//                     const SizedBox(height: 10),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {
//                           _stopListening();
//                           flutterTts.stop();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => ForgotPassword()),
//                           ).then((_) => _initVoice());
//                         },
//                         child: const Text(
//                           'Forgot Password?',
//                           style: TextStyle(color: Colors.red, fontSize: 12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.purple,
//                         foregroundColor: Colors.white,
//                         minimumSize: const Size(double.infinity, 45),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                       ),
//                       onPressed: _login,
//                       child: const Text(
//                         'LOGIN',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     const Text(
//                       'Don\'t have an account?',
//                       style: TextStyle(color: Colors.grey, fontSize: 13),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         _stopListening();
//                         flutterTts.stop();
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => RegistrationScreen()),
//                         ).then((_) => _initVoice());
//                       },
//                       child: const Text(
//                         'Register Now',
//                         style: TextStyle(color: Colors.purpleAccent),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Text Field Builder
//   Widget buildInputField({
//     required TextEditingController controller,
//     required IconData icon,
//     required String hint,
//     required bool isPassword,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: TextFormField(
//         controller: controller,
//         obscureText: isPassword,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Colors.grey),
//           hintText: hint,
//           filled: true,
//           fillColor: Colors.grey[200],
//           contentPadding:
//           const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
//         ),
//         validator: (value) => value!.isEmpty ? 'Please enter $hint' : null,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:project/BlindDashboardScreen.dart';
import 'RegistrationScreen.dart';
import 'ForgotPassword.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MaterialApp(home: LoginScreen()));

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late FlutterTts flutterTts;
  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  Future<void> _initVoice() async {
    flutterTts = FlutterTts();
    speech = stt.SpeechToText();

    await Permission.microphone.request();

    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);

    await _speak(
        "Welcome to the login screen. Do you have an account? Please say yes or no.");

    await _startListeningAccountCheck();
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    await speech.stop();
    await flutterTts.speak(text);
  }

  Future<void> _stopListening() async {
    if (isListening) {
      await speech.stop();
      setState(() => isListening = false);
    }
  }

  Future<void> _startListeningAccountCheck() async {
    bool available = await speech.initialize();
    if (!available) return;

    setState(() => isListening = true);

    speech.listen(
      listenFor: const Duration(seconds: 10),
      onResult: (result) async {
        String cmd = result.recognizedWords.toLowerCase();
        await _stopListening();

        if (cmd.contains("yes")) {
          await _speak("Please say your email.");
          await _startListeningEmail();
        } else if (cmd.contains("no")) {
          await _speak("Redirecting to registration.");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegistrationScreen()),
          ).then((_) => _initVoice());
        } else {
          await _speak("Say yes or no.");
          await _startListeningAccountCheck();
        }
      },
    );
  }

  Future<void> _startListeningEmail() async {
    if (!speech.isAvailable) return;

    setState(() => isListening = true);

    speech.listen(
      listenFor: const Duration(seconds: 12),
      onResult: (result) async {
        if (result.finalResult) {
          await _stopListening();

          String input = result.recognizedWords.replaceAll(" ", "").trim();

          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
            await _speak("Invalid email. Try again.");
            await _startListeningEmail();
            return;
          }

          emailController.text = input;
          await _speak("Now say password.");
          await _startListeningPassword();
        }
      },
    );
  }

  Future<void> _startListeningPassword() async {
    if (!speech.isAvailable) return;

    setState(() => isListening = true);

    speech.listen(
      listenFor: const Duration(seconds: 10),
      onResult: (result) async {
        if (result.finalResult) {
          await _stopListening();

          // 🔥 FIX: clean password properly
          passwordController.text =
              result.recognizedWords.trim().replaceAll(" ", "");

          await _speak("Say login, forgot password, or register.");
          await _startListeningCommands();
        }
      },
    );
  }

  Future<void> _startListeningCommands() async {
    setState(() => isListening = true);

    speech.listen(
      listenFor: const Duration(seconds: 10),
      onResult: (result) async {
        String cmd = result.recognizedWords.toLowerCase().trim();
        await _stopListening();

        if (cmd.contains("login")) {
          await _speak("Logging in.");
          _login();
        } else if (cmd.contains("forgot")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ForgotPassword()),
          ).then((_) => _initVoice());
        } else if (cmd.contains("register")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegistrationScreen()),
          ).then((_) => _initVoice());
        } else {
          await _speak("Try again.");
          await _startListeningCommands();
        }
      },
    );
  }

  // 🔥 FINAL LOGIN FIXED
  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        print("EMAIL: $email");
        print("PASS LENGTH: ${password.length}");

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BlindDashboardScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String msg;

        switch (e.code) {
          case 'user-not-found':
            msg = "User not found";
            break;
          case 'wrong-password':
            msg = "Wrong password";
            break;
          case 'invalid-email':
            msg = "Invalid email";
            break;
          case 'invalid-credential':
            msg = "Invalid login credentials";
            break;
          default:
            msg = "Login failed";
        }

        await _speak(msg);
        print("AUTH ERROR: ${e.code}");
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 UI COMPLETELY SAME (NO CHANGE)
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B1FA2), Color(0xFFF3E5F5)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    buildInputField(
                        controller: emailController,
                        icon: Icons.email,
                        hint: 'Email',
                        isPassword: false),

                    buildInputField(
                        controller: passwordController,
                        icon: Icons.lock,
                        hint: 'Password',
                        isPassword: true),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: _login,
                      child: const Text('LOGIN'),
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

  Widget buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool isPassword,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) =>
        value!.isEmpty ? 'Please enter $hint' : null,
      ),
    );
  }
}