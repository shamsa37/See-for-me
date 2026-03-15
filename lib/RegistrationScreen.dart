import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/BlindDashboardScreen.dart';
import 'package:project/BlindScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with WidgetsBindingObserver {

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

  List<String> steps = [
    "username",
    "email",
    "phone",
    "password",
    "gender",
    "register"
  ];

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

    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

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
      case 0:
        await _tts.speak("Please say your username");
        break;

      case 1:
        await _tts.speak("Please say your email");
        break;

      case 2:
        await _tts.speak("Please say your phone number");
        break;

      case 3:
        await _tts.speak("Please say your password");
        break;

      case 4:
        await _tts.speak("Say male or female");
        break;

      case 5:
        await _tts.speak("Say register to complete registration");
        break;
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

              _tts
                  .speak("Sorry I did not recognize that please say again")
                  .then((_) => _listen());

            } else {

              _processInput(input);
            }
          }
        },
      );
    }
  }

  bool _isValidEmail(String email) {
    return email.contains("@") && email.contains(".");
  }

  String _checkPasswordStrength(String pass) {

    if (pass.length < 6) return "weak";

    bool hasLetter = pass.contains(RegExp(r'[A-Za-z]'));
    bool hasNumber = pass.contains(RegExp(r'[0-9]'));

    if (hasLetter && hasNumber && pass.length >= 8) return "strong";
    if (hasLetter && hasNumber) return "medium";

    return "weak";
  }

  void _processInput(String input) async {

    if (input.contains("go back") || input.contains("back")) {
      await _tts.speak("Going back");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BlindScreen()),
      );
      return;
    }

    if (input.contains("repeat")) {
      await _tts.speak("Repeating");
      _speakStep();
      return;
    }

    if (input.contains("edit email")) {
      _currentStep = 1;
      await _tts.speak("Editing email please say new email");
      _listen();
      return;
    }

    if (input.contains("cancel registration")) {

      isCancelling = true;

      await _tts.speak(
          "Are you sure say yes to confirm cancellation");

      _listen();
      return;
    }

    if (isCancelling) {

      if (input.contains("yes")) {

        await _tts.speak("Registration cancelled");

        Navigator.pop(context);

        return;
      }

      else {

        isCancelling = false;

        await _tts.speak("Continuing registration");

        _speakStep();

        return;
      }
    }

    switch (_currentStep) {

      case 0:

        username = input;

        usernameController.text = username;

        await _tts.speak("Username saved");

        break;

      case 1:

        email = input.replaceAll(" ", "");

        emailController.text = email;

        if (!_isValidEmail(email)) {

          await _tts.speak("Invalid email say again");

          _listen();

          return;
        }

        await _tts.speak("Email saved");

        break;

      case 2:

        phoneNumber = input.replaceAll(" ", "");

        phoneController.text = phoneNumber;

        await _tts.speak("Phone number saved");

        break;

      case 3:

        password = input;

        passwordController.text = password;

        String strength = _checkPasswordStrength(password);

        if (strength == "weak") {

          await _tts.speak("Weak password");

          _listen();

          return;
        }

        break;

      case 4:

        if (input.contains("female")) {

          setState(() {
            isFemale = true;
            isMale = false;
          });

          await _tts.speak("Female selected");
        }

        else if (input.contains("male")) {

          setState(() {
            isMale = true;
            isFemale = false;
          });

          await _tts.speak("Male selected");
        }

        else {

          await _tts.speak("Please say male or female");

          _listen();

          return;
        }

        break;

      case 5:

        if (input.contains("register")) {

          try {

            await AuthService().signupUser(
              email,
              password,
              'blind',
            );

            await _tts.speak("Registration successful");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlindDashboardScreen(),
              ),
            );

          } catch (e) {

            await _tts.speak("Registration failed");

          }

          return;
        }

        else {

          await _tts.speak("Please say register");

          _listen();

          return;
        }
    }

    _currentStep++;

    if (_currentStep < steps.length) {

      Future.delayed(
        const Duration(seconds: 1),
            () {
          _speakStep();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: ElevatedButton(

          onPressed: () async {

            try {

              await AuthService().signupUser(
                email,
                password,
                'blind',
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BlindDashboardScreen(),
                ),
              );

            } catch (e) {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Registration failed $e"),
                ),
              );
            }
          },

          child: const Text("REGISTER"),

        ),
      ),
    );
  }
}