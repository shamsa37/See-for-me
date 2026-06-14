//
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// // Note: CustomAppBar aur Dashboard class ka naam aapki file ke mutabiq hai
// class BlindDashboardScreen extends StatefulWidget {
//   const BlindDashboardScreen({Key? key}) : super(key: key);
//
//   @override
//   State<BlindDashboardScreen> createState() => _BlindDashboardScreenState();
// }
//
// class _BlindDashboardScreenState extends State<BlindDashboardScreen>
//     with WidgetsBindingObserver {
//   final FlutterTts flutterTts = FlutterTts();
//   late stt.SpeechToText _speech;
//   bool isListening = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _speech = stt.SpeechToText();
//
//     Future.delayed(const Duration(milliseconds: 500), () {
//       _startDashboardVoiceGuide();
//     });
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
//   String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
//
//   Future<void> _startDashboardVoiceGuide() async {
//     await flutterTts.stop();
//     _speech.stop();
//
//     await _speak(
//       "Dashboard opened. Say Call Volunteer, Scene Description, SOS, Offline Help, or Edit Profile.",
//       onComplete: _startListening,
//     );
//   }
//
//   Future<void> _speak(String text, {VoidCallback? onComplete}) async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setSpeechRate(0.4);
//     await flutterTts.awaitSpeakCompletion(true);
//
//     flutterTts.setCompletionHandler(() {
//       if (onComplete != null) onComplete();
//     });
//
//     await flutterTts.speak(text);
//   }
//
//   void _startListening() async {
//     if (isListening) return;
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => isListening = true);
//       _speech.listen(
//         listenFor: const Duration(seconds: 10),
//         onResult: (result) {
//           if (result.finalResult) {
//             setState(() => isListening = false);
//             _speech.stop();
//             _processVoiceCommand(result.recognizedWords.toLowerCase());
//           }
//         },
//       );
//     }
//   }
//
//   void _processVoiceCommand(String command) async {
//     if (command.contains("call volunteer")) {
//       await _speak("Calling volunteer");
//       await _firestoreCall();
//       _navigate('/callVolunteer');
//     } else if (command.contains("scene")) {
//       await _speak("Opening scene description");
//       await _firestoreAI();
//       _navigate('/scene');
//     } else if (command.contains("sos")) {
//       await _speak("SOS activated");
//       await _firestoreSOS();
//       _navigate('/sos');
//     } else if (command.contains("offline")) {
//       await _speak("Opening offline help");
//       await _firestoreOffline();
//       _navigate('/offline');
//     } else if (command.contains("edit profile")) {
//       await _speak("Opening edit profile");
//       await _firestoreEditProfile(); // Sub-collection for profile edit
//       _navigate('/editprofile');
//     } else {
//       _speak("Sorry, I didn't understand.", onComplete: _startListening);
//     }
//   }
//
//   void _navigate(String route) {
//     if (mounted) {
//       Navigator.pushNamed(context, route).then((_) => _startDashboardVoiceGuide());
//     }
//   }
//
//   // ================= FIRESTORE SUB-COLLECTIONS =================
//
//   Future<void> _firestoreCall() async {
//     if (currentUid == null) return;
//     try {
//       final ref = FirebaseFirestore.instance.collection('blind').doc(currentUid);
//       await ref.collection('call').add({
//         'type': 'Voice Command Call',
//         'status': 'pending',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) { print("Error: $e"); }
//   }
//
//   Future<void> _firestoreSOS() async {
//     if (currentUid == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection('blind').doc(currentUid)
//           .collection('sos').add({
//         'action': 'SOS Triggered',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) { print("Error: $e"); }
//   }
//
//   Future<void> _firestoreAI() async {
//     if (currentUid == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection('blind').doc(currentUid)
//           .collection('ai_scene').add({
//         'action': 'Scene Scan Started',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) { print("Error: $e"); }
//   }
//
//   Future<void> _firestoreOffline() async {
//     if (currentUid == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection('blind').doc(currentUid)
//           .collection('offline_help').add({
//         'action': 'Accessed Offline Support',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) { print("Error: $e"); }
//   }
//
//   Future<void> _firestoreEditProfile() async {
//     if (currentUid == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection('blind').doc(currentUid)
//           .collection('profile_edits').add({
//         'action': 'Profile Edit Accessed',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) { print("Error: $e"); }
//   }
//
//   // ================= UI BUTTONS =================
//
//   Widget buildButton({
//     required String label,
//     required IconData icon,
//     required List<Color> colors,
//     required VoidCallback onPressed,
//   }) {
//     return InkWell(
//       onTap: onPressed,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(colors: colors),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.white),
//             const SizedBox(height: 10),
//             Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3E5F5),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.count(
//           crossAxisCount: 2,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           children: [
//             buildButton(
//               label: "Call Volunteer",
//               icon: Icons.videocam,
//               colors: [Colors.lightBlueAccent, Colors.blue],
//               onPressed: () async { await _firestoreCall(); _navigate('/callVolunteer'); },
//             ),
//             buildButton(
//               label: "Scene Description",
//               icon: Icons.remove_red_eye_outlined,
//               colors: [Colors.cyanAccent, Colors.teal],
//               onPressed: () async { await _firestoreAI(); _navigate('/scene'); },
//             ),
//             buildButton(
//               label: "SOS",
//               icon: Icons.notification_important_outlined,
//               colors: [Colors.redAccent, Colors.deepOrange],
//               onPressed: () async { await _firestoreSOS(); _navigate('/sos'); },
//             ),
//             buildButton(
//               label: "Offline Help",
//               icon: Icons.help_outline,
//               colors: [Colors.indigoAccent, Colors.blue],
//               onPressed: () async { await _firestoreOffline(); _navigate('/offline'); },
//             ),
//             buildButton(
//               label: "Edit Profile",
//               icon: Icons.person_outline,
//               colors: [Colors.deepPurpleAccent, Colors.purple],
//               onPressed: () async { await _firestoreEditProfile(); _navigate('/editprofile'); },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:project/CustomAppBar.dart'; // Aapki original bar
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class BlindDashboardScreen extends StatefulWidget {
  const BlindDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BlindDashboardScreen> createState() => _BlindDashboardScreenState();
}

class _BlindDashboardScreenState extends State<BlindDashboardScreen>
    with WidgetsBindingObserver {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();

    Future.delayed(const Duration(milliseconds: 500), () {
      _startDashboardVoiceGuide();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speech.stop();
    flutterTts.stop();
    super.dispose();
  }

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // ================= VOICE LOGIC =================

  Future<void> _startDashboardVoiceGuide() async {
    await flutterTts.stop();
    _speech.stop();

    await _speak(
      "Dashboard opened. Say Call Volunteer, Scene Description, SOS, Offline Help, or Edit Profile.",
      onComplete: _startListening,
    );
  }

  Future<void> _speak(String text, {VoidCallback? onComplete}) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.awaitSpeakCompletion(true);

    flutterTts.setCompletionHandler(() {
      if (onComplete != null) onComplete();
    });

    await flutterTts.speak(text);
  }

  void _startListening() async {
    if (isListening) return;
    bool available = await _speech.initialize();
    if (available) {
      setState(() => isListening = true);
      _speech.listen(
        listenFor: const Duration(seconds: 10),
        onResult: (result) {
          if (result.finalResult) {
            setState(() => isListening = false);
            _speech.stop();
            _processVoiceCommand(result.recognizedWords.toLowerCase());
          }
        },
      );
    }
  }

  void _processVoiceCommand(String command) async {
    if (command.contains("call volunteer")) {
      await _speak("Calling volunteer");
      await _firestoreCall();
      _navigate('/callVolunteer');
    } else if (command.contains("scene")) {
      await _speak("Opening scene description");
      await _firestoreAI();
      _navigate('/scene');
    } else if (command.contains("sos")) {
      await _speak("SOS activated");
      await _firestoreSOS();
      _navigate('/sos');
    } else if (command.contains("offline")) {
      await _speak("Opening offline help");
      await _firestoreOffline();
      _navigate('/offline');
    } else if (command.contains("edit profile")) {
      await _speak("Opening edit profile");
      await _firestoreEditProfile();
      _navigate('/editprofile');
    } else {
      _speak("Sorry, I didn't understand.", onComplete: _startListening);
    }
  }

  void _navigate(String route) {
    if (mounted) {
      Navigator.pushNamed(context, route).then((_) => _startDashboardVoiceGuide());
    }
  }

  // ================= FIRESTORE SUB-COLLECTIONS =================

  // Future<void> _firestoreCall() async {
  //   if (currentUid == null) return;
  //   try {
  //     await FirebaseFirestore.instance.collection('blind').doc(currentUid).collection('call').add({
  //       'action': 'Voice Command Call',
  //       'status': 'pending',
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) { print(e); }
  // }
  Future<void> _firestoreCall() async {
    if (currentUid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid)
          .collection('call')
          .add({
        'action': 'Voice Command Call',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print(e);
    }
  }

  Future<void> _firestoreSOS() async {
    if (currentUid == null) return;
    try {
      await FirebaseFirestore.instance.collection('blind').doc(currentUid).collection('sos').add({
        'action': 'SOS Triggered',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) { print(e); }
  }

  Future<void> _firestoreAI() async {
    if (currentUid == null) return;
    try {
      await FirebaseFirestore.instance.collection('blind').doc(currentUid).collection('ai_scene').add({
        'action': 'Scene Scan Started',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) { print(e); }
  }

  Future<void> _firestoreOffline() async {
    if (currentUid == null) return;
    try {
      await FirebaseFirestore.instance.collection('blind').doc(currentUid).collection('offline_emergency_logs').add({
        'action': 'Accessed Offline Support',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) { print(e); }
  }

  Future<void> _firestoreEditProfile() async {
    if (currentUid == null) return;
    try {
      await FirebaseFirestore.instance.collection('blind').doc(currentUid).collection('profile_edits').add({
        'action': 'Profile Edit Accessed',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) { print(e); }
  }

  // ================= UI COMPONENTS (UNCHANGED) =================

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
      appBar: const CustomAppBar(title: "Blind Dashboard"), // Top Bar Wapas Add Kar Di
      backgroundColor: const Color(0xFFF3E5F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            buildButton(
              label: "Call Volunteer",
              icon: Icons.videocam,
              colors: [Colors.lightBlueAccent, Colors.blue],
              onPressed: () async {
                await _firestoreCall();
                _navigate('/callVolunteer');
              },
            ),
            buildButton(
              label: "Scene Description",
              icon: Icons.remove_red_eye_outlined,
              colors: [Colors.cyanAccent, Colors.teal],
              onPressed: () async {
                await _firestoreAI();
                _navigate('/scene');
              },
            ),
            buildButton(
              label: "SOS",
              icon: Icons.notification_important_outlined,
              colors: [Colors.redAccent, Colors.deepOrange],
              onPressed: () async {
                await _firestoreSOS();
                _navigate('/sos');
              },
            ),
            buildButton(
              label: "Offline Help",
              icon: Icons.help_outline,
              colors: [Colors.indigoAccent, Colors.blue],
              onPressed: () async {
                await _firestoreOffline();
                _navigate('/offline');
              },
            ),
            buildButton(
              label: "Edit Profile",
              icon: Icons.person_outline,
              colors: [Colors.deepPurpleAccent, Colors.purple],
              onPressed: () async {
                await _firestoreEditProfile();
                _navigate('/editprofile');
              },
            ),
          ],
        ),
      ),
    );
  }
}