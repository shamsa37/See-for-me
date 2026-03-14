//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
//
// class SettingScreen extends StatefulWidget {
//   @override
//   State<SettingScreen> createState() => _SettingScreenState();
// }
//
// class _SettingScreenState extends State<SettingScreen> {
//   bool showName = true;
//   bool highContrast = true;
//   bool voiceOver = true;
//   bool darkMode = false; // ✅ Dark mode toggle
//
//   late FlutterTts flutterTts;
//   late stt.SpeechToText speech;
//
//   bool isListening = false;
//   String spokenText = "";
//
//   @override
//   void initState() {
//     super.initState();
//     loadSettings();
//     initVoice();
//   }
//
//   // 🔊 INIT VOICE
//   void initVoice() {
//     flutterTts = FlutterTts();
//     speech = stt.SpeechToText();
//
//     flutterTts.setLanguage("en-US");
//     flutterTts.setSpeechRate(0.45);
//     flutterTts.setPitch(1.0);
//   }
//
//   // 🔊 SPEAK
//   Future<void> speak(String text) async {
//     if (!voiceOver) return;
//     await flutterTts.stop();
//     await flutterTts.speak(text);
//   }
//
//   // 🎙 LISTEN
//   Future<void> listen() async {
//     final mic = await Permission.microphone.request();
//     if (!mic.isGranted) {
//       speak("Microphone permission denied");
//       return;
//     }
//
//     bool available = await speech.initialize();
//     if (available) {
//       setState(() => isListening = true);
//       speak("Listening");
//
//       speech.listen(
//         onResult: (val) {
//           if (val.finalResult) {
//             spokenText = val.recognizedWords;
//             stopListening();
//             handleVoiceCommand(spokenText);
//           }
//         },
//       );
//     } else {
//       speak("Speech recognition not available");
//     }
//   }
//
//   void stopListening() {
//     speech.stop();
//     setState(() => isListening = false);
//   }
//
//   // 🧠 VOICE COMMAND HANDLER
//   void handleVoiceCommand(String command) async {
//     command = command.toLowerCase();
//
//     if (command.contains("enable dark mode")) {
//       setState(() => darkMode = true);
//       saveSetting('darkMode', true);
//       speak("Dark mode enabled");
//
//     } else if (command.contains("disable dark mode")) {
//       setState(() => darkMode = false);
//       saveSetting('darkMode', false);
//       speak("Light mode enabled");
//
//     } else if (command.contains("enable voice")) {
//       setState(() => voiceOver = true);
//       saveSetting('voiceOver', true);
//       speak("Voice over enabled");
//
//     } else if (command.contains("disable voice")) {
//       setState(() => voiceOver = false);
//       saveSetting('voiceOver', false);
//
//     } else {
//       speak("Command not recognized. Please say again.");
//       Future.delayed(const Duration(seconds: 1), () => listen());
//     }
//   }
//
//   // 💾 SETTINGS
//   Future<void> loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       showName = prefs.getBool('showName') ?? true;
//       highContrast = prefs.getBool('highContrast') ?? true;
//       voiceOver = prefs.getBool('voiceOver') ?? true;
//       darkMode = prefs.getBool('darkMode') ?? false;
//     });
//   }
//
//   Future<void> saveSetting(String key, bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(key, value);
//   }
//
//   // 🔐 PERMISSIONS
//   Future<void> requestPermission(Permission permission, String name) async {
//     final status = await permission.request();
//
//     if (status.isGranted) {
//       showMsg("$name permission granted", Colors.green);
//     } else if (status.isDenied) {
//       showMsg("$name permission denied", Colors.red);
//     } else if (status.isPermanentlyDenied) {
//       openAppSettings();
//       speak("$name permission permanently denied");
//     }
//   }
//
//   void showMsg(String msg, Color color) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ Theme colors based on darkMode
//     final bgColor = darkMode ? Colors.black : Colors.white;
//     final textColor = darkMode ? Colors.white : Colors.black;
//     final subTextColor = darkMode ? Colors.grey[300] : Colors.grey[700];
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         title: Text("Settings", style: TextStyle(color: Colors.white)),
//         backgroundColor: darkMode ? Colors.deepPurple : Colors.purple,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: ListView(
//         children: [
//           section("Appearance", textColor),
//           SwitchListTile(
//             value: darkMode,
//             onChanged: (v) {
//               setState(() => darkMode = v);
//               saveSetting('darkMode', v);
//               speak(v ? "Dark mode enabled" : "Light mode enabled");
//             },
//             title: Text("Enable Dark Mode", style: TextStyle(color: textColor)),
//           ),
//           divider(),
//
//           section("Accessibility", textColor),
//           SwitchListTile(
//             value: voiceOver,
//             onChanged: (v) {
//               setState(() => voiceOver = v);
//               saveSetting('voiceOver', v);
//               if (v) speak("Voice over enabled");
//             },
//             title: Text("Enable Voice Over", style: TextStyle(color: textColor)),
//           ),
//           divider(),
//
//           section("Voice Control", textColor),
//           ListTile(
//             title: Text(isListening ? "Listening..." : "Voice Command",
//                 style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
//             subtitle: spokenText.isNotEmpty
//                 ? Text(spokenText, style: TextStyle(color: subTextColor))
//                 : null,
//             trailing: Icon(
//               isListening ? Icons.mic_off : Icons.mic,
//               color: textColor,
//             ),
//             onTap: () => isListening ? stopListening() : listen(),
//           ),
//           divider(),
//
//           section("Permissions", textColor),
//           ListTile(
//             title: Text("Camera Access", style: TextStyle(color: textColor)),
//             trailing: Icon(Icons.camera_alt, color: textColor),
//             onTap: () => requestPermission(Permission.camera, "Camera"),
//           ),
//           ListTile(
//             title: Text("Microphone Access", style: TextStyle(color: textColor)),
//             trailing: Icon(Icons.mic, color: textColor),
//             onTap: () => requestPermission(Permission.microphone, "Microphone"),
//           ),
//           divider(),
//
//           ListTile(
//             leading: Icon(Icons.settings, color: textColor),
//             title: Text("Open App Settings", style: TextStyle(color: textColor)),
//             trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
//             onTap: () async {
//               await openAppSettings();
//               await flutterTts.speak("Opening app settings");
//             },
//           ),
//           divider(),
//
//           ListTile(
//             title: Text("Log Out", style: TextStyle(color: Colors.red)),
//             onTap: () => logoutDialog(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget section(String t, Color color) => Padding(
//     padding: const EdgeInsets.all(12),
//     child: Text(
//       t,
//       style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
//     ),
//   );
//
//   Widget divider() => const Divider(color: Colors.grey);
//
//   void logoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Log Out"),
//         content: const Text("Are you sure you want to log out?"),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Log Out")),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
//


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
  bool darkMode = false;

  late FlutterTts flutterTts;
  late stt.SpeechToText speech;

  bool isListening = false;
  bool speechAvailable = false;
  String spokenText = "";

  @override
  void initState() {
    super.initState();
    loadSettings();
    initVoice();
  }

  void initVoice() async {
    flutterTts = FlutterTts();
    speech = stt.SpeechToText();

    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setPitch(1.0);

    speechAvailable = await speech.initialize(
      onStatus: (status) {
        if (status == "done") stopListening();
      },
      onError: (val) {
        stopListening();
      },
    );

    // Start with greeting and auto-listen
    if (voiceOver) {
      await speak(
        "Settings screen loaded. Available options: Appearance, Accessibility, Permissions, Log Out. You can say the option you want.",
      );
      Future.delayed(const Duration(milliseconds: 500), () => listen());
    }
  }

  Future<void> speak(String text) async {
    if (!voiceOver) return;
    await flutterTts.stop();
    await flutterTts.speak(text);
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> listen() async {
    if (!speechAvailable) {
      await speak("Speech recognition not available");
      return;
    }

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      await speak("Microphone permission denied");
      return;
    }

    setState(() => isListening = true);
    await Future.delayed(const Duration(milliseconds: 300));

    speech.listen(
      onResult: (val) {
        if (val.finalResult) {
          spokenText = val.recognizedWords;
          stopListening();
          handleVoiceCommand(spokenText);
        }
      },
      listenMode: stt.ListenMode.dictation,
    );
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  void handleVoiceCommand(String command) async {
    command = command.toLowerCase().trim();
    await flutterTts.stop();

    bool recognized = true;

    if (command.contains("enable dark")) {
      setState(() => darkMode = true);
      saveSetting('darkMode', true);
      await speak("Dark mode enabled");

    } else if (command.contains("disable dark")) {
      setState(() => darkMode = false);
      saveSetting('darkMode', false);
      await speak("Light mode enabled");

    } else if (command.contains("enable voice")) {
      setState(() => voiceOver = true);
      saveSetting('voiceOver', true);
      await speak("Voice over enabled");

    } else if (command.contains("disable voice")) {
      setState(() => voiceOver = false);
      saveSetting('voiceOver', false);

    } else if (command.contains("camera")) {
      await requestPermission(Permission.camera, "Camera");

    } else if (command.contains("microphone")) {
      await requestPermission(Permission.microphone, "Microphone");

    } else if (command.contains("log out")) {
      await speak("Logging out");
      logoutDialog(context);

    } else if (command.contains("back")) {
      stopListening();
      await flutterTts.stop();
      Navigator.of(context).popUntil((route) => route.isFirst);
      await speak("Returned to home screen");
      return;

    } else if (command.contains("help") || command.contains("options")) {
      await speak(
        "Available options: Enable or Disable Dark Mode, Enable or Disable Voice Over, Camera Access, Microphone Access, Log Out, Back to Home Screen.",
      );

    } else {
      recognized = false;
      await speak("Sorry, I did not understand. Please say again.");
    }

    // Continue listening only if screen still mounted
    if (mounted && recognized) {
      await Future.delayed(const Duration(milliseconds: 500));
      listen();
    } else if (mounted && !recognized) {
      // Wait before re-listening for unrecognized commands
      await Future.delayed(const Duration(milliseconds: 500));
      listen();
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showName = prefs.getBool('showName') ?? true;
      highContrast = prefs.getBool('highContrast') ?? true;
      voiceOver = prefs.getBool('voiceOver') ?? true;
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> requestPermission(Permission permission, String name) async {
    final status = await permission.request();

    if (status.isGranted) {
      await speak("$name permission granted");
    } else if (status.isDenied) {
      await speak("$name permission denied");
    } else if (status.isPermanentlyDenied) {
      await speak("$name permission permanently denied. Please enable it from app settings.");
      openAppSettings();
    }
  }

  void logoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              speak("Cancelled logout");
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              speak("Logged out successfully");
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = darkMode ? Colors.black : Colors.white;
    final textColor = darkMode ? Colors.white : Colors.black;
    final subTextColor = darkMode ? Colors.grey[300] : Colors.grey[700];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: darkMode ? Colors.deepPurple : Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          section("Appearance", textColor),
          SwitchListTile(
            value: darkMode,
            onChanged: (v) {
              setState(() => darkMode = v);
              saveSetting('darkMode', v);
              speak(v ? "Dark mode enabled" : "Light mode enabled");
            },
            title: Text("Enable Dark Mode", style: TextStyle(color: textColor)),
          ),
          divider(),
          section("Accessibility", textColor),
          SwitchListTile(
            value: voiceOver,
            onChanged: (v) {
              setState(() => voiceOver = v);
              saveSetting('voiceOver', v);
              if (v) speak("Voice over enabled");
            },
            title: Text("Enable Voice Over", style: TextStyle(color: textColor)),
          ),
          divider(),
          section("Permissions", textColor),
          ListTile(
            title: Text("Camera Access", style: TextStyle(color: textColor)),
            trailing: Icon(Icons.camera_alt, color: textColor),
            onTap: () => requestPermission(Permission.camera, "Camera"),
          ),
          ListTile(
            title: Text("Microphone Access", style: TextStyle(color: textColor)),
            trailing: Icon(Icons.mic, color: textColor),
            onTap: () => requestPermission(Permission.microphone, "Microphone"),
          ),
          divider(),
          ListTile(
            leading: Icon(Icons.settings, color: textColor),
            title: Text("Open App Settings", style: TextStyle(color: textColor)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
            onTap: () async {
              await openAppSettings();
              await flutterTts.speak("Opening app settings");
            },
          ),
          divider(),
          ListTile(
            title: Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () => logoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget section(String t, Color color) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      t,
      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  Widget divider() => const Divider(color: Colors.grey);
}