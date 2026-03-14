// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:project/BlindDashboardScreen.dart';
// import 'package:project/BlindScreen.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
//
// class RegistrationScreen extends StatefulWidget {
//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }
//
// class _RegistrationScreenState extends State<RegistrationScreen> with WidgetsBindingObserver {
//   final _formKey = GlobalKey<FormState>();
//
//   late stt.SpeechToText _speech;
//   late FlutterTts _tts;
//
//   int _currentStep = 0;
//   bool isCancelling = false;
//
//   String username = '';
//   String email = '';
//   String phoneNumber = '';
//   String password = '';
//   bool isMale = false;
//   bool isFemale = false;
//
//   double _opacity = 0.0;
//   List<String> steps = ["username","email","phone","password","gender","register"];
//
//   late TextEditingController usernameController;
//   late TextEditingController emailController;
//   late TextEditingController phoneController;
//   late TextEditingController passwordController;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     _speech = stt.SpeechToText();
//     _tts = FlutterTts();
//
//     usernameController = TextEditingController();
//     emailController = TextEditingController();
//     phoneController = TextEditingController();
//     passwordController = TextEditingController();
//
//     // Fade in effect
//     Timer(const Duration(milliseconds: 300), () {
//       setState(() {
//         _opacity = 1.0;
//       });
//     });
//
//     // Start TTS/STT
//     _initTTS();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _speech.stop();
//     _tts.stop();
//     usernameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       Future.delayed(const Duration(milliseconds: 300), () {
//         _speakStep();
//       });
//     }
//   }
//
//   Future<void> _initTTS() async {
//     await _tts.setLanguage("en-US");
//     await _tts.setSpeechRate(0.5);
//     await _tts.awaitSpeakCompletion(true);
//
//     Future.delayed(const Duration(milliseconds: 500), () {
//       _speakStep();
//     });
//   }
//
//   void _speakStep() async {
//     await _speech.stop();
//
//     switch (_currentStep) {
//       case 0: await _tts.speak("Please say your username"); break;
//       case 1: await _tts.speak("Please say your email"); break;
//       case 2: await _tts.speak("Please say your phone number"); break;
//       case 3: await _tts.speak("Please say your password"); break;
//       case 4: await _tts.speak("Say male or female"); break;
//       case 5: await _tts.speak("Say register to complete registration"); break;
//     }
//
//     _listen();
//   }
//
//   void _listen() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       _speech.listen(
//         listenFor: const Duration(seconds: 10),
//         pauseFor: const Duration(seconds: 3),
//         onResult: (result) {
//           if (result.finalResult) {
//             _speech.stop();
//             String input = result.recognizedWords.toLowerCase();
//             if (input.trim().isEmpty) {
//               _tts.speak("Sorry, I did not recognize that. Please say again").then((_) => _listen());
//             } else {
//               _processInput(input);
//             }
//           }
//         },
//       );
//     }
//   }
//
//   bool _isValidEmail(String email) => email.contains("@") && email.contains(".");
//   String _checkPasswordStrength(String pass) {
//     if (pass.length < 6) return "weak";
//     bool hasLetter = pass.contains(RegExp(r'[A-Za-z]'));
//     bool hasNumber = pass.contains(RegExp(r'[0-9]'));
//     if (hasLetter && hasNumber && pass.length >= 8) return "strong";
//     if (hasLetter && hasNumber) return "medium";
//     return "weak";
//   }
//
//   void _processInput(String input) async {
//     // Go back to BlindScreen
//     if (input.contains("go back") || input.contains("back")) {
//       await _tts.speak("Going back to Blind Home Screen");
//       await _speech.stop();
//       await _tts.stop();
//       Navigator.pop(context); // Back to BlindScreen
//       return;
//     }
//
//     // Repeat
//     if (input.contains("repeat")) { await _tts.speak("Repeating"); _speakStep(); return; }
//
//     // Edit email
//     if (input.contains("edit email")) { _currentStep = 1; await _tts.speak("Editing email. Please say your new email"); _listen(); return; }
//
//     // Cancel registration
//     if (input.contains("cancel registration")) {
//       isCancelling = true;
//       await _tts.speak("Are you sure? Say yes to confirm cancellation");
//       _listen();
//       return;
//     }
//
//     if (isCancelling) {
//       if (input.contains("yes")) { await _tts.speak("Registration cancelled"); Navigator.pop(context); return; }
//       else { isCancelling = false; await _tts.speak("Continuing registration"); _speakStep(); return; }
//     }
//
//     // Step-based input processing
//     switch (_currentStep) {
//       case 0: username = input; usernameController.text = username; await _tts.speak("Username saved"); break;
//       case 1:
//         email = input.replaceAll(" ", "");
//         emailController.text = email;
//         if (!_isValidEmail(email)) { await _tts.speak("Invalid email format. Please say your email again"); _listen(); return; }
//         await _tts.speak("Email saved");
//         break;
//       case 2: phoneNumber = input.replaceAll(" ", ""); phoneController.text = phoneNumber; await _tts.speak("Phone number saved"); break;
//       case 3:
//         password = input; passwordController.text = password;
//         String strength = _checkPasswordStrength(password);
//         if (strength == "weak") { await _tts.speak("Weak password. Please use letters and numbers"); _listen(); return; }
//         else if (strength == "medium") await _tts.speak("Medium strength password");
//         else await _tts.speak("Strong password");
//         break;
//       case 4:
//         if (input.contains("female")) { setState(() { isFemale = true; isMale = false; }); await _tts.speak("Female selected"); }
//         else if (input.contains("male")) { setState(() { isMale = true; isFemale = false; }); await _tts.speak("Male selected"); }
//         else { await _tts.speak("Please say male or female"); _listen(); return; }
//         break;
//       case 5:
//         if (input.contains("register")) {
//           usernameController.text = username;
//           emailController.text = email;
//           phoneController.text = phoneNumber;
//           passwordController.text = password;
//           await _tts.speak("Registration successful");
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => BlindDashboardScreen()),
//           );
//           return;
//         } else { await _tts.speak("Please say register to submit"); _listen(); return; }
//     }
//
//     // Move to next step
//     _currentStep++;
//     if (_currentStep < steps.length) Future.delayed(const Duration(seconds: 1), () { _speakStep(); });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7B1FA2), Colors.white]),
//         ),
//         child: Center(
//           child: AnimatedOpacity(
//             duration: const Duration(seconds: 1),
//             opacity: _opacity,
//             child: SingleChildScrollView(
//               child: Container(
//                 width: 350,
//                 padding: const EdgeInsets.all(30),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       const Text('Registration', style: TextStyle(fontSize: 26, color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 20),
//                       buildTextField(label: 'Username', hint: 'Enter your username', controller: usernameController, onSaved: (val) => username = val!),
//                       buildTextField(label: 'Email', hint: 'Enter your email', keyboardType: TextInputType.emailAddress, controller: emailController, onSaved: (val) => email = val!),
//                       buildTextField(label: 'Phone Number', hint: 'Enter your number', keyboardType: TextInputType.phone, controller: phoneController, onSaved: (val) => phoneNumber = val!),
//                       buildTextField(label: 'Password', hint: 'Enter your password', isPassword: true, controller: passwordController, onSaved: (val) => password = val!),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           const Text('Gender:', style: TextStyle(fontWeight: FontWeight.bold)),
//                           Checkbox(value: isMale, activeColor: Colors.purple, onChanged: (val) => setState(() { isMale = val!; if(val) isFemale=false; })),
//                           const Text('Male'),
//                           Checkbox(value: isFemale, activeColor: Colors.purple, onChanged: (val) => setState(() { isFemale = val!; if(val) isMale=false; })),
//                           const Text('Female'),
//                           const SizedBox(width: 20),
//                           Text(
//                             isMale ? "Male selected" : isFemale ? "Female selected" : "",
//                             style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             _formKey.currentState!.save();
//                             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlindDashboardScreen()));
//                           }
//                         },
//                         child: const Text('REGISTER'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildTextField({required String label, required String hint, bool isPassword=false, TextInputType keyboardType=TextInputType.text, required void Function(String?) onSaved, TextEditingController? controller}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label),
//           const SizedBox(height: 5),
//           TextFormField(
//             controller: controller,
//             obscureText: isPassword,
//             keyboardType: keyboardType,
//             decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
//             validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
//             onSaved: onSaved,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/BlindDashboardScreen.dart';
import 'package:project/BlindScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  late stt.SpeechToText _speech;
  late FlutterTts _tts;

  int _currentStep = 0;
  bool isCancelling = false;

  String username = '';
  String email = '';
  String phoneNumber = '';
  String password = '';
  bool isMale = false;
  bool isFemale = false;

  double _opacity = 0.0;
  List<String> steps = ["username","email","phone","password","gender","register"];

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();

    // Fade in effect
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Start TTS/STT
    _initTTS();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speech.stop();
    _tts.stop();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _speakStep();
      });
    }
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.awaitSpeakCompletion(true);

    Future.delayed(const Duration(milliseconds: 500), () {
      _speakStep();
    });
  }

  void _speakStep() async {
    await _speech.stop();

    switch (_currentStep) {
      case 0: await _tts.speak("Please say your username"); break;
      case 1: await _tts.speak("Please say your email"); break;
      case 2: await _tts.speak("Please say your phone number"); break;
      case 3: await _tts.speak("Please say your password"); break;
      case 4: await _tts.speak("Say male or female"); break;
      case 5: await _tts.speak("Say register to complete registration"); break;
    }

    _listen();
  }

  void _listen() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        onResult: (result) {
          if (result.finalResult) {
            _speech.stop();
            String input = result.recognizedWords.toLowerCase();
            if (input.trim().isEmpty) {
              _tts.speak("Sorry, I did not recognize that. Please say again").then((_) => _listen());
            } else {
              _processInput(input);
            }
          }
        },
      );
    }
  }

  bool _isValidEmail(String email) => email.contains("@") && email.contains(".");
  String _checkPasswordStrength(String pass) {
    if (pass.length < 6) return "weak";
    bool hasLetter = pass.contains(RegExp(r'[A-Za-z]'));
    bool hasNumber = pass.contains(RegExp(r'[0-9]'));
    if (hasLetter && hasNumber && pass.length >= 8) return "strong";
    if (hasLetter && hasNumber) return "medium";
    return "weak";
  }

  void _processInput(String input) async {
    // Go back to BlindScreen
    if (input.contains("go back") || input.contains("back")) {
      await _tts.speak("Going back to Blind Home Screen");
      await _speech.stop();
      await _tts.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BlindScreen()),
      );
      return;
    }

    // Repeat
    if (input.contains("repeat")) { await _tts.speak("Repeating"); _speakStep(); return; }

    // Edit email
    if (input.contains("edit email")) { _currentStep = 1; await _tts.speak("Editing email. Please say your new email"); _listen(); return; }

    // Cancel registration
    if (input.contains("cancel registration")) {
      isCancelling = true;
      await _tts.speak("Are you sure? Say yes to confirm cancellation");
      _listen();
      return;
    }

    if (isCancelling) {
      if (input.contains("yes")) { await _tts.speak("Registration cancelled"); Navigator.pop(context); return; }
      else { isCancelling = false; await _tts.speak("Continuing registration"); _speakStep(); return; }
    }

    // Step-based input processing
    switch (_currentStep) {
      case 0: username = input; usernameController.text = username; await _tts.speak("Username saved"); break;
      case 1:
        email = input.replaceAll(" ", "");
        emailController.text = email;
        if (!_isValidEmail(email)) { await _tts.speak("Invalid email format. Please say your email again"); _listen(); return; }
        await _tts.speak("Email saved");
        break;
      case 2: phoneNumber = input.replaceAll(" ", ""); phoneController.text = phoneNumber; await _tts.speak("Phone number saved"); break;
      case 3:
        password = input; passwordController.text = password;
        String strength = _checkPasswordStrength(password);
        if (strength == "weak") { await _tts.speak("Weak password. Please use letters and numbers"); _listen(); return; }
        else if (strength == "medium") await _tts.speak("Medium strength password");
        else await _tts.speak("Strong password");
        break;
      case 4:
        if (input.contains("female")) {
          setState(() { isFemale = true; isMale = false; });
          await _tts.speak("Female selected");
        }
        else if (input.contains("male")) {
          setState(() { isMale = true; isFemale = false; });
          await _tts.speak("Male selected");
        }
        else { await _tts.speak("Please say male or female"); _listen(); return; }
        break;
      case 5:
        if (input.contains("register")) {
          usernameController.text = username;
          emailController.text = email;
          phoneController.text = phoneNumber;
          passwordController.text = password;
          await _tts.speak("Registration successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BlindDashboardScreen()),
          );
          return;
        } else { await _tts.speak("Please say register to submit"); _listen(); return; }
    }

    // Move to next step
    _currentStep++;
    if (_currentStep < steps.length) Future.delayed(const Duration(seconds: 1), () { _speakStep(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7B1FA2), Colors.white]),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: _opacity,
            child: SingleChildScrollView(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // FIX: Align left
                    children: [
                      const Center(
                        child: Text('Registration', style: TextStyle(fontSize: 26, color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      buildTextField(label: 'Username', hint: 'Enter your username', controller: usernameController, onSaved: (val) => username = val!),
                      buildTextField(label: 'Email', hint: 'Enter your email', keyboardType: TextInputType.emailAddress, controller: emailController, onSaved: (val) => email = val!),
                      buildTextField(label: 'Phone Number', hint: 'Enter your number', keyboardType: TextInputType.phone, controller: phoneController, onSaved: (val) => phoneNumber = val!),
                      buildTextField(label: 'Password', hint: 'Enter your password', isPassword: true, controller: passwordController, onSaved: (val) => password = val!),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'Gender:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 5),

                          Row(
                            children: [

                              Checkbox(
                                value: isMale,
                                activeColor: Colors.purple,
                                onChanged: (val) {
                                  setState(() {
                                    isMale = val!;
                                    if (val) isFemale = false;
                                  });
                                },
                              ),

                              const Text('Male'),

                              const SizedBox(width: 20),

                              Checkbox(
                                value: isFemale,
                                activeColor: Colors.purple,
                                onChanged: (val) {
                                  setState(() {
                                    isFemale = val!;
                                    if (val) isMale = false;
                                  });
                                },
                              ),

                              const Text('Female'),

                              const SizedBox(width: 20),

                              Expanded(
                                child: Text(
                                  isMale
                                      ? "Male selected"
                                      : isFemale
                                      ? "Female selected"
                                      : "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlindDashboardScreen()));
                          }
                        },
                        child: const Text('REGISTER'),
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

  Widget buildTextField({required String label, required String hint, bool isPassword=false, TextInputType keyboardType=TextInputType.text, required void Function(String?) onSaved, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
            validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
            onSaved: onSaved,
          ),
        ],
      ),
    );
  }
}