import 'package:flutter/material.dart';
import 'package:project/BlindScreen.dart';
import 'package:project/VolunteerScreen.dart';
import 'package:project/CustomAppBar.dart';
import 'package:project/FamilyDashboard.dart'; // 👈 Add this import
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project/FamilyScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


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
          color: Colors.white, // ignored, gradient paints it
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeTTSandSTT();
  }

  Future<void> _initializeTTSandSTT() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (val) => print("Speech status: $val"),
      onError: (val) => print("Speech error: $val"),
    );

    if (!_speechAvailable) {
      await _speak("Speech recognition not available on this device.");
      return;
    }

    await _speak(
      "Welcome to the home screen. There are three features available. "
          "Say 'Open Blind Session', 'Open Volunteer Session', or 'Open Family Dashboard'.",
      onComplete: _startListening,
    );
  }

  Future<void> _speak(String text, {VoidCallback? onComplete}) async {
    _isSpeaking = true;
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.45);

    flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      if (onComplete != null) onComplete();
    });

    await flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    if (_isSpeaking) return;

    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Status: $status");
        if (status == "done" || status == "notListening") {
          setState(() => _isListening = false);
          _startListening();
        }
      },
      onError: (error) {
        print("Speech Error: $error");
        _speak("Speech recognition error. Please try again.");
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
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
            _speech.stop();
            _speak("Opening Volunteer Session", onComplete: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VolunteerScreen()),
              );
            });
          } else if (command.contains("family")) {
            _speech.stop();
            _speak("Opening Family Dashboard", onComplete: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FamilyDashboard()),
              );
            });
          } else if (command.isNotEmpty) {
            _speak(
              "Command not recognized. Please say Blind, Volunteer, or Family.",
              onComplete: _startListening,
            );
          }
        },
      );
    } else {
      _speak("Speech recognition not available.");
    }
  }

  @override
  void dispose() {
    _speech.stop();
    flutterTts.stop();
    super.dispose();
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
              // ✅ Gradient Heading
              const GradientText("Welcome to Home Screen!", fontSize: 30),

              const SizedBox(height: 30),

              // Blind Button
              _buildButton(
                label: "Blind",
                onPressed: () {
                  _speech.stop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BlindScreen()),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Volunteer Button
              _buildButton(
                label: "Volunteer",
                onPressed: () {
                  _speech.stop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VolunteerScreen()),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Family Button
              _buildButton(
                label: "Family",
                onPressed: () {
                  _speech.stop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FamilyScreen()),
                  );
                },
              ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
