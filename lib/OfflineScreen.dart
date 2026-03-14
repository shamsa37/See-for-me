
// import 'package:flutter/material.dart';
// import 'package:project/CallBlind.dart';
// import 'package:project/LocationShareScreen.dart';
//
// class OfflineScreen extends StatelessWidget {
//   const OfflineScreen({super.key});
//
//   Widget buildContactCard(
//       BuildContext context, String name, String number, String type) {
//     return Card(
//       elevation: 6,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: ListTile(
//           contentPadding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           title: Text(
//             name,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.purple,
//             ),
//           ),
//           subtitle: Padding(
//             padding: const EdgeInsets.only(top: 6),
//             child: Text(
//               number,
//               style: const TextStyle(
//                 fontSize: 17,
//                 color: Colors.black, // ✅ black for subtitle
//               ),
//             ),
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   iconSize: 30,
//                   icon: const Icon(Icons.call, color: Colors.green),
//                   onPressed: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CallBlind(
//                         contactName: name,
//                         contactNumber: number,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   iconSize: 30,
//                   icon: const Icon(Icons.location_on, color: Colors.red),
//                   onPressed: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => LocationShareScreen(
//                         contactName: name,
//                         contactNumber: number,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // ✅ AppBar with white title
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         elevation: 0,
//         automaticallyImplyLeading: true,
//         title: const Text(
//           "Offline Emergency",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white, // ✅ white text
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: const Color(0xFFF3E5F5),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Icon(
//               Icons.wifi_off,
//               size: 90,
//               color: Colors.red,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               "You are Offline",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black, // ✅ black text
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               "Only Voice Call and Location Share are available.",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.black, // ✅ black text
//               ),
//             ),
//             const SizedBox(height: 25),
//             const Text(
//               "--- Emergency Contacts ---",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: Colors.black, // ✅ black text
//               ),
//             ),
//             const SizedBox(height: 12),
//             Expanded(
//               child: ListView(
//                 children: [
//                   buildContactCard(context, "Police", "15", "service"),
//                   buildContactCard(context, "Edhi Ambulance", "115", "service"),
//                   buildContactCard(context, "Rescue 1122", "1122", "service"),
//                   buildContactCard(context, "Fire Brigade", "16", "service"),
//                   buildContactCard(
//                       context, "Traffic Police", "1915", "service"),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/CallBlind.dart';
import 'package:project/LocationShareScreen.dart';
import 'package:project/BlindDashboardScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _voicePrompt = "Say a contact name or 'back' to go dashboard";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.awaitSpeakCompletion(true);

    // Initial prompt
    await _speak(_voicePrompt);

    // Announce available contacts for blind user
    String contactsAnnouncement =
        "Available contacts are Police, Edhi Ambulance, Rescue 1122, Fire Brigade, and Traffic Police. Who do you want to call?";
    await _speak(contactsAnnouncement);

    Future.delayed(const Duration(milliseconds: 500), () => _startListening());
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
    await _tts.awaitSpeakCompletion(true);
  }

  void _startListening() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == "done") _stopListening();
      },
      onError: (val) => _stopListening(),
    );

    if (!_speechAvailable) {
      await _speak(
          "Speech recognition is not available. Please try again later.");
      return;
    }

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      await _speak("Microphone permission denied");
      return;
    }

    setState(() => _isListening = true);

    _speech.listen(
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (result.finalResult) {
          _stopListening();
          String input = result.recognizedWords.toLowerCase().trim();
          if (input.isEmpty) {
            _speak("Sorry, I did not recognize that. Please say again.")
                .then((_) => _startListening());
          } else {
            _processVoiceCommand(input);
          }
        }
      },
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _callContact(String name, String number) async {
    try {
      await _speak("Opening $name contact");

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallBlind(
            contactName: name,
            contactNumber: number,
            onCallEnded: () async {
              await _speak("Call ended");
            },
          ),
        ),
      );
    } catch (e) {
      await _speak("Call to $name could not be completed");
    } finally {
      if (mounted) {
        // Restart TTS/STT after call
        Future.delayed(const Duration(milliseconds: 500), () async {
          await _speak(_voicePrompt);
          _startListening();
        });
      }
    }
  }

  void _shareLocation(String name, String number) async {
    try {
      await _speak("Sharing your location with $name");
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LocationShareScreen(
            contactName: name,
            contactNumber: number,
          ),
        ),
      );
    } catch (e) {
      await _speak("Unable to share location with $name. Please try again.");
    } finally {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          await _speak(_voicePrompt);
          _startListening();
        });
      }
    }
  }

  void _handleIncomingCall(String name, String number) async {
    await _speak("$name call incoming. Say accept or decline.");

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("$name Incoming Call"),
        content: const Text("Accept or decline the call?"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _speak("Call accepted");
              _callContact(name, number);
            },
            child: const Text("Accept"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _speak("Call declined");
            },
            child: const Text("Decline"),
          ),
        ],
      ),
    );
  }

  void _processVoiceCommand(String input) {
    input = input.toLowerCase().trim();
    input = input.replaceAll(RegExp(r'[^\w\s]'), ''); // remove punctuation
    bool recognized = true;

    if (input.contains("back") || input.contains("dashboard")) {
      _speak("Going back to dashboard").then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BlindDashboardScreen()),
        );
      });
      return;
    }

    // Location share commands
    if (input.contains("location")) {
      if (input.contains("police")) _shareLocation("Police", "15");
      else if (input.contains("edhi")) _shareLocation("Edhi Ambulance", "115");
      else if (input.contains("rescue")) _shareLocation("Rescue 1122", "1122");
      else if (input.contains("fire")) _shareLocation("Fire Brigade", "16");
      else if (input.contains("traffic")) _shareLocation("Traffic Police", "1915");
      else {
        recognized = false;
        _speak("Contact not recognized for location sharing")
            .then((_) => _startListening());
      }
    } else {
      // Outgoing call commands
      if (input.contains("police")) _callContact("Police", "15");
      else if (input.contains("edhi")) _callContact("Edhi Ambulance", "115");
      else if (input.contains("rescue")) _callContact("Rescue 1122", "1122");
      else if (input.contains("fire")) _callContact("Fire Brigade", "16");
      else if (input.contains("traffic")) _callContact("Traffic Police", "1915");
      else {
        recognized = false;
        _speak("Sorry, I did not recognize that. Please say again.")
            .then((_) => _startListening());
      }
    }

    if (recognized && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () => _startListening());
    }
  }

  Widget buildContactCard(
      BuildContext context, String name, String number, String type) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              number,
              style: const TextStyle(fontSize: 17, color: Colors.black),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _callContact(name, number),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.location_on, color: Colors.red),
                  onPressed: () => _shareLocation(name, number),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: const Text(
          "Offline Emergency",
          style:
          TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3E5F5),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.wifi_off, size: 90, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "You are Offline",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              "Only Voice Call and Location Share are available.",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                _voicePrompt,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "--- Emergency Contacts ---",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  buildContactCard(context, "Police", "15", "service"),
                  buildContactCard(context, "Edhi Ambulance", "115", "service"),
                  buildContactCard(context, "Rescue 1122", "1122", "service"),
                  buildContactCard(context, "Fire Brigade", "16", "service"),
                  buildContactCard(context, "Traffic Police", "1915", "service"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}