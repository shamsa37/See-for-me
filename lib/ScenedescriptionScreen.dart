
/*import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:project/CustomAppBar.dart';

class ScenedescriptionScreen extends StatefulWidget {
  const ScenedescriptionScreen({super.key});

  @override
  _ScenedescriptionScreenState createState() => _ScenedescriptionScreenState();
}

class _ScenedescriptionScreenState extends State<ScenedescriptionScreen> {
  String _description = "No scene captured yet.";
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTTS().then((_) => _startListening()); // Start STT automatically
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.awaitSpeakCompletion(true);
    _speak("This is Scene Description screen. Say 'Capture Scene' to describe the scene.");
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop(); // stop previous speech if any
    await _flutterTts.speak(text);
  }

  void _captureScene() {
    String description = "A chair and a table are in front of you.";
    setState(() {
      _description = description;
    });
    _speak(description);
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          String command = val.recognizedWords.toLowerCase();
          if (command.contains("capture scene")) {
            _captureScene();
          }
        },
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      _speak("Speech recognition not available.");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Scene Description"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF3E5F5),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: Text("📷 Camera Preview Here"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _description,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 180,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.purple, width: 2),
                        foregroundColor: Colors.purple,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _captureScene,
                      child: const Text("Capture Scene"),
                    ),
                  ),
                  Container(height: 30),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ScenedescriptionScreen extends StatefulWidget {
  const ScenedescriptionScreen({super.key});

  @override
  State<ScenedescriptionScreen> createState() =>
      _ScenedescriptionScreenState();
}

class _ScenedescriptionScreenState extends State<ScenedescriptionScreen> {
  final FlutterTts _tts = FlutterTts();
  String _description = "No scene captured yet.";

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    _speak(
      "Scene description screen. Press the capture scene button to hear the description.",
    );
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _captureScene() {
    // 🔹 Dummy scene description (Web + Demo purpose)
    String fakeDescription =
        "I can see a table, a chair, and a window in front of you.";

    setState(() {
      _description = fakeDescription;
    });

    _speak(fakeDescription);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ AppBar added (No settings icon)
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          "Scene Description",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true, // back button if navigated
        // ❌ NO actions → settings icon removed
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3E5F5),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: Text(
                    "📷 Camera Preview\n(Disabled in Web Demo)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _captureScene,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.purple,
                          width: 2,
                        ),
                        foregroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Capture Scene",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



