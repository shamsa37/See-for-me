import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool showName = true;
  bool highContrast = true;
  bool voiceOver = true;

  late FlutterTts flutterTts;
  late stt.SpeechToText speech;

  bool isListening = false;
  String spokenText = "";

  @override
  void initState() {
    super.initState();
    loadSettings();
    initVoice();
  }

  // 🔊 INIT VOICE
  void initVoice() {
    flutterTts = FlutterTts();
    speech = stt.SpeechToText();

    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.45);
    flutterTts.setPitch(1.0);
  }

  // 🔊 SPEAK
  Future<void> speak(String text) async {
    if (!voiceOver) return;
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  // 🎙 LISTEN
  Future<void> listen() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      speak("Microphone permission denied");
      return;
    }

    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speak("Listening");

      speech.listen(
        onResult: (val) {
          if (val.finalResult) {
            spokenText = val.recognizedWords;
            stopListening();
            handleVoiceCommand(spokenText);
          }
        },
      );
    } else {
      speak("Speech recognition not available");
    }
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  // 🧠 VOICE COMMAND HANDLER
  void handleVoiceCommand(String command) async {
    command = command.toLowerCase();

    if (command.contains("open camera")) {
      await requestPermission(Permission.camera, "Camera");
      speak("Camera opened");

    } else if (command.contains("open microphone")) {
      await requestPermission(Permission.microphone, "Microphone");
      speak("Microphone opened");

    } else if (command.contains("enable voice")) {
      setState(() => voiceOver = true);
      saveSetting('voiceOver', true);
      speak("Voice over enabled");

    } else if (command.contains("disable voice")) {
      setState(() => voiceOver = false);
      saveSetting('voiceOver', false);

    } else if (command.contains("high contrast")) {
      setState(() => highContrast = true);
      saveSetting('highContrast', true);
      speak("High contrast enabled");

    } else if (command.contains("logout")) {
      speak("Logging out");
      logoutDialog(context);

    } else {
      speak("Command not recognized");
    }
  }

  // 💾 SETTINGS
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showName = prefs.getBool('showName') ?? true;
      highContrast = prefs.getBool('highContrast') ?? true;
      voiceOver = prefs.getBool('voiceOver') ?? true;
    });
  }

  Future<void> saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // 🔐 PERMISSIONS
  Future<void> requestPermission(
      Permission permission, String name) async {
    final status = await permission.request();

    if (status.isGranted) {
      showMsg("$name permission granted", Colors.green);
    } else if (status.isDenied) {
      showMsg("$name permission denied", Colors.red);
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      speak("$name permission permanently denied");
    }
  }

  void showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          section("Accessibility"),
          SwitchListTile(
            value: voiceOver,
            onChanged: (v) {
              setState(() => voiceOver = v);
              saveSetting('voiceOver', v);
              if (v) speak("Voice over enabled");
            },
            title: whiteText("Enable Voice Over"),
          ),

          divider(),
          section("Voice Control"),
          ListTile(
            title: whiteText(
                isListening ? "Listening..." : "Voice Command"),
            subtitle: spokenText.isNotEmpty
                ? Text(spokenText,
                style: const TextStyle(color: Colors.grey))
                : null,
            trailing: Icon(
              isListening ? Icons.mic_off : Icons.mic,
              color: Colors.white,
            ),
            onTap: () =>
            isListening ? stopListening() : listen(),
          ),

          divider(),
          section("Permissions"),
          ListTile(
            title: whiteText("Camera Access"),
            trailing: const Icon(Icons.camera_alt, color: Colors.white),
            onTap: () => requestPermission(Permission.camera, "Camera"),
          ),
          ListTile(
            title: whiteText("Microphone Access"),
            trailing: const Icon(Icons.mic, color: Colors.white),
            onTap: () => requestPermission(Permission.microphone, "Microphone"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: Text(
              "Open App Settings",
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
            onTap: () async {
              await openAppSettings();
              await flutterTts.speak("Opening app settings");
            },
          ),

          divider(),
          ListTile(
            title: const Text("Log Out",
                style: TextStyle(color: Colors.red)),
            onTap: () => logoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget section(String t) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      t,
      style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  Widget whiteText(String t) =>
      Text(t, style: const TextStyle(color: Colors.white));

  Widget divider() => const Divider(color: Colors.grey);

  void logoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Log Out")),
        ],
      ),
    );
  }
}
