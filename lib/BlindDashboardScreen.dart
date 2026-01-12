
/*import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project/CustomAppBar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class BlindDashboardScreen extends StatefulWidget {
  @override
  State<BlindDashboardScreen> createState() => _BlindDashboardScreenState();
}

class _BlindDashboardScreenState extends State<BlindDashboardScreen> with WidgetsBindingObserver {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    speech = stt.SpeechToText();
    _startDashboardVoice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopListening();
    super.dispose();
  }

  // Detect when app comes back to foreground / user back to this screen
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startDashboardVoice();
    }
  }

  Future<void> _startDashboardVoice() async {
    await _speak(
      "Dashboard opened. You can say: Call Volunteer, Scene Description, SOS, Offline Help, or Edit Profile.",
    );
    startListening();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(text);
  }

  void startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          Future.delayed(Duration(milliseconds: 200), () {
            if (!isListening) startListening();
          });
        }
      },
      onError: (error) {
        print("Speech error: $error");
      },
    );

    if (available) {
      setState(() => isListening = true);

      speech.listen(
        onResult: (result) async {
          String command = result.recognizedWords.toLowerCase();
          if (command.isNotEmpty) await _handleCommand(command);
        },
        partialResults: false,
        listenMode: stt.ListenMode.dictation,
        cancelOnError: false,
      );
    } else {
      await _speak("Speech recognition not available.");
    }
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  Future<void> _handleCommand(String command) async {
    stopListening();

    String? navigateTo;
    String speakText;

    if (command.contains("call volunteer")) {
      navigateTo = '/callvolunteer';
      speakText = "Call Volunteer screen opened.";
    } else if (command.contains("scene") || command.contains("description")) {
      navigateTo = '/scene';
      speakText = "Scene Description screen opened.";
    } else if (command.contains("sos")) {
      navigateTo = '/sos';
      speakText = "SOS screen opened.";
    } else if (command.contains("offline help")) {
      navigateTo = '/offline';
      speakText = "Offline Help screen opened.";
    } else if (command.contains("edit profile")) {
      navigateTo = '/editprofile';
      speakText = "Edit Profile screen opened.";
    } else {
      speakText = "Sorry, I did not understand. Please try again.";
    }

    await _speak(speakText);

    if (navigateTo != null && mounted) {
      Navigator.pushNamed(context, navigateTo).then((_) {
        // When user comes back, resume TTS & listening
        _startDashboardVoice();
      });
    }
  }

  Widget buildButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Blind Dashboard"),
      backgroundColor: const Color(0xFFF3E5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              buildButton(
                label: "Call Volunteer",
                icon: Icons.phone_outlined,
                colors: [Colors.lightBlueAccent, Colors.blue],
                onPressed: () async {
                  stopListening();
                  await _speak("Call Volunteer screen opened.");
                  Navigator.pushNamed(context, '/callvolunteer').then((_) => _startDashboardVoice());
                },
              ),
              buildButton(
                label: "Scene Description",
                icon: Icons.remove_red_eye_outlined,
                colors: [Colors.cyanAccent, Colors.teal],
                onPressed: () async {
                  stopListening();
                  await _speak("Scene Description screen opened.");
                  Navigator.pushNamed(context, '/scene').then((_) => _startDashboardVoice());
                },
              ),
              buildButton(
                label: "SOS",
                icon: Icons.notification_important_outlined,
                colors: [Colors.redAccent, Colors.deepOrange],
                onPressed: () async {
                  stopListening();
                  await _speak("SOS screen opened.");
                  Navigator.pushNamed(context, '/sos').then((_) => _startDashboardVoice());
                },
              ),
              buildButton(
                label: "Offline Help",
                icon: Icons.help_outline,
                colors: [Colors.indigoAccent, Colors.blue],
                onPressed: () async {
                  stopListening();
                  await _speak("Offline Help screen opened.");
                  Navigator.pushNamed(context, '/offline').then((_) => _startDashboardVoice());
                },
              ),
              buildButton(
                label: "Edit Profile",
                icon: Icons.person_outline,
                colors: [Colors.deepPurpleAccent, Colors.purple],
                onPressed: () async {
                  stopListening();
                  await _speak("Edit Profile screen opened.");
                  Navigator.pushNamed(context, '/editprofile').then((_) => _startDashboardVoice());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project/CustomAppBar.dart';

class BlindDashboardScreen extends StatefulWidget {
  const BlindDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BlindDashboardScreen> createState() => _BlindDashboardScreenState();
}

class _BlindDashboardScreenState extends State<BlindDashboardScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speak(
      "Dashboard opened. Options are: Call Volunteer, Scene Description, "
          "SOS, Offline Help, and Edit Profile.",
    );
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.speak(text);
  }

  Widget buildButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Blind Dashboard"),
      backgroundColor: const Color(0xFFF3E5F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // 📞 CALL VOLUNTEER
            buildButton(
              label: "Call Volunteer",
              icon: Icons.videocam,
              colors: [Colors.lightBlueAccent, Colors.blue],
              onPressed: () {
                _speak("Calling volunteer.");
                Navigator.pushNamed(context, '/callVolunteer');
              },
            ),

            // 👁 SCENE DESCRIPTION
            buildButton(
              label: "Scene Description",
              icon: Icons.remove_red_eye_outlined,
              colors: [Colors.cyanAccent, Colors.teal],
              onPressed: () {
                _speak("Opening scene description.");
                Navigator.pushNamed(context, '/scene');
              },
            ),

            // 🚨 SOS
            buildButton(
              label: "SOS",
              icon: Icons.notification_important_outlined,
              colors: [Colors.redAccent, Colors.deepOrange],
              onPressed: () {
                _speak("SOS activated.");
                Navigator.pushNamed(context, '/sos');
              },
            ),

            // 📶 OFFLINE HELP
            buildButton(
              label: "Offline Help",
              icon: Icons.help_outline,
              colors: [Colors.indigoAccent, Colors.blue],
              onPressed: () {
                _speak("Opening offline help.");
                Navigator.pushNamed(context, '/offline');
              },
            ),

            // 👤 EDIT PROFILE
            buildButton(
              label: "Edit Profile",
              icon: Icons.person_outline,
              colors: [Colors.deepPurpleAccent, Colors.purple],
              onPressed: () {
                _speak("Opening edit profile.");
                Navigator.pushNamed(context, '/editprofile');
              },
            ),
          ],
        ),
      ),
    );
  }
}





