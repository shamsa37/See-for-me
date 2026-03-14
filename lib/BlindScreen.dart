import 'package:flutter/material.dart';
import 'RegistrationScreen.dart';
import 'LoginScreen.dart';
import 'SettingScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'speech_service.dart';
import 'package:project/CustomAppBar.dart';

/// GradientText widget
class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;

  const GradientText(this.text, {super.key, this.fontSize = 30});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.black, Colors.pink, Colors.black],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class BlindScreen extends StatefulWidget {
  @override
  State<BlindScreen> createState() => _BlindScreenState();
}

class _BlindScreenState extends State<BlindScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String commandText = "";

  @override
  void initState() {
    super.initState();

    /// STT INIT
    SpeechService().init((words) {
      setState(() {
        commandText = words.toLowerCase();
        print("Heard: $commandText");

        /// LOGIN COMMAND
        if (commandText.contains("login")) {
          SpeechService().stopListening();
          _speak("Navigating to Login Screen");

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          ).then((_) {
            _restartVoiceAssistant();
          });
        }

        /// REGISTRATION COMMAND
        else if (commandText.contains("registration") ||
            commandText.contains("register")) {
          SpeechService().stopListening();
          _speak("Navigating to Registration Screen");

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistrationScreen()),
          ).then((_) {
            _restartVoiceAssistant();
          });
        }

        /// SETTINGS COMMAND
        else if (commandText.contains("setting")) {
          SpeechService().stopListening();
          _speak("Opening Settings");

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingScreen()),
          ).then((_) {
            _restartVoiceAssistant();
          });
        }

        /// BACK COMMAND
        else if (commandText.contains("back")) {
          SpeechService().stopListening();
          _speak("Going back to home screen");
          Navigator.pop(context);
        }
      });
    });

    /// Welcome Message
    _speak(
      "Welcome to the Blind Home Screen. "
          "You can say Go to Login Screen, Go to Registration Screen, "
          "Open Setting, or Back to Home Screen.",
      onComplete: () => SpeechService().startListening(),
    );
  }

  /// Restart voice when user comes back
  void _restartVoiceAssistant() {
    _speak(
      "Welcome back to Blind Home Screen. "
          "You can say Login, Registration, Open Setting or Back.",
      onComplete: () => SpeechService().startListening(),
    );
  }

  /// TTS
  Future<void> _speak(String text, {VoidCallback? onComplete}) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);

    flutterTts.setCompletionHandler(() {
      if (onComplete != null) onComplete();
    });

    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    SpeechService().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Blind Home Screen"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3E5F5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GradientText("Welcome to Blind Screen!", fontSize: 30),

              const SizedBox(height: 40),

              /// REGISTRATION BUTTON
              SizedBox(
                width: 220,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _speak("Navigating to Registration Screen");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationScreen(),
                      ),
                    ).then((_) {
                      _restartVoiceAssistant();
                    });
                  },
                  child: const Text(
                    "Registration",
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// LOGIN BUTTON
              SizedBox(
                width: 220,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _speak("Navigating to Login Screen");

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    ).then((_) {
                      _restartVoiceAssistant();
                    });
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// BACK BUTTON
              SizedBox(
                width: 220,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'RegistrationScreen.dart';
// import 'LoginScreen.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'speech_service.dart';
// import 'package:project/CustomAppBar.dart';
//
// class GradientText extends StatelessWidget {
//   final String text;
//   final double fontSize;
//
//   const GradientText(this.text, {super.key, this.fontSize = 30});
//
//   @override
//   Widget build(BuildContext context) {
//     return ShaderMask(
//       shaderCallback: (bounds) => const LinearGradient(
//         colors: [Colors.black, Colors.pink, Colors.black],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: fontSize,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
//
// class BlindScreen extends StatefulWidget {
//   @override
//   State<BlindScreen> createState() => _BlindScreenState();
// }
//
// class _BlindScreenState extends State<BlindScreen>
//     with WidgetsBindingObserver {
//   final FlutterTts flutterTts = FlutterTts();
//   bool _isSpeaking = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     Future.delayed(const Duration(milliseconds: 300), () {
//       _startVoiceAssistant();
//     });
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     SpeechService().stopListening();
//     flutterTts.stop();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       Future.delayed(const Duration(milliseconds: 300), () {
//         _startVoiceAssistant();
//       });
//     }
//   }
//
//   /// START VOICE ASSISTANT
//   void _startVoiceAssistant() async {
//     await flutterTts.stop();
//     SpeechService().stopListening();
//
//     await _speak(
//       "Welcome to the Blind Home Screen. You can say Go to Login Screen, Go to Registration Screen, or Back to Home Screen.",
//     );
//
//     _listenToCommand();
//   }
//
//   /// LISTEN COMMAND
//   void _listenToCommand() async {
//     await Future.delayed(const Duration(milliseconds: 200));
//
//     SpeechService().init((words) async {
//       String commandText = words.toLowerCase().trim();
//
//       print("Heard: $commandText");
//
//       /// LOGIN
//       if (commandText.contains("login")) {
//         SpeechService().stopListening();
//
//         await _speak("Navigating to Login Screen");
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => LoginScreen()),
//         ).then((_) {
//           _startVoiceAssistant();
//         });
//       }
//
//       /// REGISTRATION
//       else if (commandText.contains("registration") ||
//           commandText.contains("register")) {
//         SpeechService().stopListening();
//
//         await _speak("Navigating to Registration Screen");
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => RegistrationScreen()),
//         ).then((_) {
//           _startVoiceAssistant();
//         });
//       }
//
//       /// BACK
//       else if (commandText.contains("back") ||
//           commandText.contains("home")) {
//         _goBack();
//       }
//
//       /// NOT RECOGNIZED
//       else {
//         SpeechService().stopListening();
//
//         await _speak(
//           "Please say again, I did not recognize that.",
//         );
//
//         _listenToCommand();
//       }
//     });
//   }
//
//   /// SPEAK FUNCTION
//   Future<void> _speak(String text) async {
//     if (_isSpeaking) return;
//
//     _isSpeaking = true;
//
//     await flutterTts.stop();
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setPitch(1.0);
//     await flutterTts.setSpeechRate(0.45);
//     await flutterTts.awaitSpeakCompletion(true);
//
//     await flutterTts.speak(text);
//
//     _isSpeaking = false;
//   }
//
//   /// GO BACK
//   Future<void> _goBack() async {
//     SpeechService().stopListening();
//     await flutterTts.stop();
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "Blind Home Screen"),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: const Color(0xFFF3E5F5),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const GradientText("Welcome to Blind Screen!", fontSize: 30),
//               const SizedBox(height: 40),
//
//               /// REGISTRATION BUTTON
//               SizedBox(
//                 width: 220,
//                 height: 55,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () async {
//                     await _speak("Navigating to Registration Screen");
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => RegistrationScreen()),
//                     ).then((_) {
//                       _startVoiceAssistant();
//                     });
//                   },
//                   child: const Text(
//                     "Registration",
//                     style:
//                     TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               /// LOGIN BUTTON
//               SizedBox(
//                 width: 220,
//                 height: 55,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () async {
//                     await _speak("Navigating to Login Screen");
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginScreen()),
//                     ).then((_) {
//                       _startVoiceAssistant();
//                     });
//                   },
//                   child: const Text(
//                     "Login",
//                     style:
//                     TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               /// BACK BUTTON
//               SizedBox(
//                 width: 220,
//                 height: 55,
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.purple,
//                     side: const BorderSide(color: Colors.purple, width: 2),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: _goBack,
//                   child: const Text(
//                     "Back to Home",
//                     style:
//                     TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }