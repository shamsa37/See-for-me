import 'package:flutter/material.dart';
import 'RegistrationScreen.dart';
import 'LoginScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'speech_service.dart';
import 'package:project/CustomAppBar.dart';

// ✅ GradientText widget
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

class BlindScreen extends StatefulWidget {
  @override
  State<BlindScreen> createState() => _BlindScreenState();
}

class _BlindScreenState extends State<BlindScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String commandText = ""; // Speech text

  @override
  void initState() {
    super.initState();

    // Step 1: Set callback for speech results
    SpeechService().init((words) {
      setState(() {
        commandText = words.toLowerCase();
        print("Heard: $commandText");

        // Automatic navigation
        if (commandText.contains("login")) {
          SpeechService().stopListening();
          _speak("Navigating to Login Screen");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else if (commandText.contains("registration") ||
            commandText.contains("register")) {
          SpeechService().stopListening();
          _speak("Navigating to Registration Screen");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistrationScreen()),
          );
        }
      });
    });

    // Step 2: Welcome message then auto start speech
    _speak(
      "Welcome to the Blind Home Screen. "
          "You can say 'Go to Login Screen' or 'Go to Registration Screen'.",
      onComplete: () => SpeechService().startListening(),
    );
  }

  // TTS Function
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
    SpeechService().stopListening(); // Stop mic when leaving screen
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
              // ✅ Gradient Text Heading
              const GradientText("Welcome to Blind Screen!", fontSize: 30),

              const SizedBox(height: 40), // spacing

              // Registration Button
              SizedBox(
                width: 220,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
                    );
                  },
                  child: const Text(
                    "Registration",
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Login Button
              SizedBox(
                width: 220,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _speak("Navigating to Login Screen");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
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
