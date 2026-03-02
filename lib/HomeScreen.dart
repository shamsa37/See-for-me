
// import 'package:flutter/material.dart';
// import 'package:project/BlindScreen.dart';
// import 'package:project/VolunteerScreen.dart';
// import 'package:project/CustomAppBar.dart';
// import 'package:project/FamilyDashboard.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:project/FamilyScreen.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
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
//           color: Colors.white, // ignored, gradient paints it
//         ),
//       ),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   final FlutterTts flutterTts = FlutterTts();
//   late stt.SpeechToText _speech;
//
//   bool _isListening = false;
//   bool _speechAvailable = false;
//   bool _voiceStarted = false;
//   bool _userNavigated = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     _speech = stt.SpeechToText();
//     _initializeTTSandSTT();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _speech.stop();
//     flutterTts.stop();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (!_voiceStarted && !_userNavigated) {
//           _startVoiceInstructions();
//         }
//       });
//     }
//   }
//
//   Future<void> _initializeTTSandSTT() async {
//     _speechAvailable = await _speech.initialize(
//       onStatus: (val) => print("Speech status: $val"),
//       onError: (val) => print("Speech error: $val"),
//     );
//
//     // Delay to simulate case 3
//     Future.delayed(Duration(milliseconds: 300), () {
//       if (!_userNavigated) {
//         _startVoiceInstructions();
//       }
//     });
//   }
//
//   Future<void> _startVoiceInstructions() async {
//     if (_voiceStarted || _userNavigated) return;
//     _voiceStarted = true;
//
//     await _speak(
//       "Welcome to the home screen. There are three features available. "
//           "Say 'Open Blind Session', 'Open Volunteer Session', or 'Open Family Dashboard'.",
//       onComplete: _startListening,
//     );
//   }
//
//   Future<void> _speak(String text, {VoidCallback? onComplete}) async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setPitch(1.0);
//     await flutterTts.setSpeechRate(0.45);
//
//     flutterTts.setCompletionHandler(() {
//       if (onComplete != null) onComplete();
//     });
//
//     await flutterTts.speak(text);
//   }
//
//   Future<void> _startListening() async {
//     if (_userNavigated) return; // Case 2 & 3
//
//     bool available = await _speech.initialize(
//       onStatus: (status) {
//         if (status == "done" || status == "notListening") {
//           _startListening(); // Restart listening if needed
//         }
//       },
//       onError: (error) {
//         _speak("Speech recognition error. Please try again.");
//       },
//     );
//
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(onResult: (result) {
//         String command = result.recognizedWords.toLowerCase();
//         print("Recognized: $command");
//
//         if (command.contains("blind")) {
//           _speech.stop();
//           _speak("Opening Blind Session", onComplete: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => BlindScreen()),
//             );
//           });
//         } else if (command.contains("volunteer")) {
//           _onFeatureButtonPressed("volunteer");
//         } else if (command.contains("family")) {
//           _onFeatureButtonPressed("family");
//         } else if (command.isNotEmpty) {
//           _speak(
//             "Command not recognized. Please say Blind, Volunteer, or Family.",
//             onComplete: _startListening,
//           );
//         }
//       });
//     } else {
//       _speak("Speech recognition not available.");
//     }
//   }
//
//   void _onFeatureButtonPressed(String feature) async {
//     _userNavigated = true; // Case 2 & 3 handle
//     await flutterTts.stop();
//     _speech.stop();
//
//     if (feature == "blind") {
//       Navigator.push(context, MaterialPageRoute(builder: (_) => BlindScreen()));
//     } else if (feature == "volunteer") {
//       Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerScreen()));
//     } else if (feature == "family") {
//       Navigator.push(context, MaterialPageRoute(builder: (_) => FamilyDashboard()));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "Home Screen"),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: const Color(0xFFF3E5F5),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const GradientText("Welcome to Home Screen!", fontSize: 30),
//               const SizedBox(height: 30),
//               _buildButton(label: "Blind", onPressed: () => _onFeatureButtonPressed("blind")),
//               const SizedBox(height: 10),
//               _buildButton(label: "Volunteer", onPressed: () => _onFeatureButtonPressed("volunteer")),
//               const SizedBox(height: 10),
//               _buildButton(label: "Family", onPressed: () => _onFeatureButtonPressed("family")),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildButton({required String label, required VoidCallback onPressed}) {
//     return SizedBox(
//       width: 220,
//       height: 55,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.purple,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         onPressed: onPressed,
//         child: Text(label, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:project/BlindScreen.dart';
import 'package:project/VolunteerScreen.dart';
import 'package:project/CustomAppBar.dart';
import 'package:project/FamilyDashboard.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project/FamilyScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// 👇 User role tracking
enum Role { blind, volunteer, family }

class UserRole {
  static Role? current; // runtime me user ka role track karega
}

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _voiceStarted = false;
  bool _userNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _speech = stt.SpeechToText();
    _initializeTTSandSTT();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speech.stop();
    flutterTts.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Wapas aane par check
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_voiceStarted &&
            !_userNavigated &&
            UserRole.current == Role.blind) {
          _startVoiceInstructions();
        }
      });
    }
  }

  Future<void> _initializeTTSandSTT() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (val) => print("Speech status: $val"),
      onError: (val) => print("Speech error: $val"),
    );

    // Delay to simulate case 3
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_userNavigated && UserRole.current == Role.blind) {
        _startVoiceInstructions();
      }
    });
  }

  Future<void> _startVoiceInstructions() async {
    if (_voiceStarted || _userNavigated) return;
    _voiceStarted = true;

    await _speak(
      "Welcome to the home screen. There are three features available. "
          "Say 'Open Blind Session', 'Open Volunteer Session', or 'Open Family Dashboard'.",
      onComplete: _startListening,
    );
  }

  Future<void> _speak(String text, {VoidCallback? onComplete}) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.45);

    flutterTts.setCompletionHandler(() {
      if (onComplete != null) onComplete();
    });

    await flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    if (_userNavigated) return; // Case 2 & 3

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          _startListening(); // Restart listening if needed
        }
      },
      onError: (error) {
        _speak("Speech recognition error. Please try again.");
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        String command = result.recognizedWords.toLowerCase();
        print("Recognized: $command");

        if (command.contains("blind")) {
          _speech.stop();
          _speak("Opening Blind Session", onComplete: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BlindScreen()),
            );
          });
        } else if (command.contains("volunteer")) {
          _onFeatureButtonPressed("volunteer");
        } else if (command.contains("family")) {
          _onFeatureButtonPressed("family");
        } else if (command.isNotEmpty) {
          _speak(
            "Command not recognized. Please say Blind, Volunteer, or Family.",
            onComplete: _startListening,
          );
        }
      });
    } else {
      _speak("Speech recognition not available.");
    }
  }

  void _onFeatureButtonPressed(String feature) async {
    _userNavigated = true; // stop any voice
    await flutterTts.stop();
    _speech.stop();

    if (feature == "blind") {
      UserRole.current = Role.blind;
      Navigator.push(context, MaterialPageRoute(builder: (_) => BlindScreen()));
    } else if (feature == "volunteer") {
      UserRole.current = Role.volunteer;
      Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerScreen()));
    } else if (feature == "family") {
      UserRole.current = Role.family;
      Navigator.push(context, MaterialPageRoute(builder: (_) => FamilyDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Home Screen"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3E5F5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GradientText("Welcome to Home Screen!", fontSize: 30),
              const SizedBox(height: 30),
              _buildButton(label: "Blind", onPressed: () => _onFeatureButtonPressed("blind")),
              const SizedBox(height: 10),
              _buildButton(label: "Volunteer", onPressed: () => _onFeatureButtonPressed("volunteer")),
              const SizedBox(height: 10),
              _buildButton(label: "Family", onPressed: () => _onFeatureButtonPressed("family")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 220,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
