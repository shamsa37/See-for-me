//
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:project/CustomAppBar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'BlindLocationEngine.dart';
// import 'package:project/services/firestore_service.dart';
// import 'CallVolunteerScreen.dart';
//
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
//   final FirestoreService _firestoreService = FirestoreService();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Background location tracking activation
//     BlindLocationEngine().startLocationTracking();
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
//   // ================= VOICE LOGIC =================
//
//   Future<void> _startDashboardVoiceGuide() async {
//     await flutterTts.stop();
//     _speech.stop();
//
//     await _speak(
//       "Dashboard opened. Say Call Volunteer, Scene Description, SOS, or Edit Profile.",
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
//     } else if (command.contains("scene")) {
//       await _speak("Opening scene description");
//       await _firestoreAI();
//       _navigate('/scene');
//     } else if (command.contains("sos")) {
//       await _speak("SOS activated");
//       await _firestoreSOS();
//       _navigate('/sos');
//     } else if (command.contains("edit profile")) {
//       await _speak("Opening edit profile");
//       await _firestoreEditProfile();
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
//   // ================= FIRESTORE LOGS =================
//
//   Future<void> _firestoreCall() async {
//     if (currentUid == null) return;
//
//     try {
//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CallVolunteerScreen(),
//           ),
//         ).then((_) => _startDashboardVoiceGuide());
//       }
//     } catch (e) {
//       debugPrint('Firestore Error: $e');
//       await _speak("Failed to initiate call. Please try again.");
//     }
//   }
//
//   Future<void> _firestoreSOS() async {
//     if (currentUid == null) return;
//     try {
//       await FirebaseFirestore.instance.collection('blind').doc(currentUid).collection('sos').add({
//         'action': 'SOS Triggered',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) { debugPrint("$e"); }
//   }
//
//   Future<void> _firestoreAI() async {
//     if (currentUid == null) return;
//     try {
//       await FirebaseFirestore.instance.collection('blind').doc(currentUid).collection('ai_scene').add({
//         'action': 'Scene Scan Started',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) { debugPrint("$e"); }
//   }
//
//   Future<void> _firestoreEditProfile() async {
//     if (currentUid == null) return;
//     try {
//       await FirebaseFirestore.instance.collection('blind').doc(currentUid).collection('profile_edits').add({
//         'action': 'Profile Edit Accessed',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) { debugPrint("$e"); }
//   }
//
//   // ================= PROFESSIONAL UI COMPONENTS =================
//
//   Widget buildHeaderBanner() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Welcome Back 👋",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.greenAccent.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.greenAccent),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.circle, color: Colors.greenAccent, size: 8),
//                     SizedBox(width: 6),
//                     Text(
//                       "Live Assistant",
//                       style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Tap any feature below or speak a command directly.",
//             style: TextStyle(color: Colors.white70, fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildVoiceStatusCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.purple.shade100),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: isListening ? Colors.redAccent.shade100 : Colors.purple.shade100,
//             radius: 22,
//             child: Icon(
//               isListening ? Icons.mic : Icons.mic_none,
//               color: isListening ? Colors.red.shade800 : Colors.purple.shade800, // FIXED HERE
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isListening ? "Listening for commands..." : "Voice Assistant Active",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: Color(0xFF2A0845),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   isListening ? "Speak clearly into your mic" : "Say 'Call Volunteer', 'SOS', etc.",
//                   style: const TextStyle(color: Colors.black54, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.volume_up_rounded, color: Colors.purple),
//             onPressed: () => _startDashboardVoiceGuide(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildButton({
//     required String label,
//     required IconData icon,
//     required List<Color> colors,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: colors.last.withOpacity(0.35),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(22),
//           onTap: onPressed,
//           child: Ink(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: colors,
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(22),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(icon, size: 36, color: Colors.white),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     label,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(title: "Blind Dashboard"),
//       backgroundColor: const Color(0xFFF6F4F9),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.all(18),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top Banner
//               buildHeaderBanner(),
//
//               const SizedBox(height: 20),
//
//               // Grid Section
//               const Text(
//                 "Quick Actions",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF330066),
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1.15,
//                 children: [
//                   buildButton(
//                     label: "Call Volunteer",
//                     icon: Icons.videocam_rounded,
//                     colors: [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
//                     onPressed: () async {
//                       await _firestoreCall();
//                     },
//                   ),
//                   buildButton(
//                     label: "Scene AI",
//                     icon: Icons.remove_red_eye_rounded,
//                     colors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
//                     onPressed: () async {
//                       await _firestoreAI();
//                       _navigate('/scene');
//                     },
//                   ),
//                   buildButton(
//                     label: "SOS Alert",
//                     icon: Icons.warning_amber_rounded,
//                     colors: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
//                     onPressed: () async {
//                       await _firestoreSOS();
//                       _navigate('/sos');
//                     },
//                   ),
//                   buildButton(
//                     label: "Edit Profile",
//                     icon: Icons.person_rounded,
//                     colors: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
//                     onPressed: () async {
//                       await _firestoreEditProfile();
//                       _navigate('/editprofile');
//                     },
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 24),
//
//               // Bottom Voice Status Indicator (Fills bottom white space)
//               buildVoiceStatusCard(),
//
//               const SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:project/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'BlindLocationEngine.dart';
import 'family_live_map_engine.dart';
import 'package:project/services/firestore_service.dart';
import 'CallVolunteerScreen.dart';

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
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    // Background location tracking activation
    BlindLocationEngine().startLocationTracking();
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();

    // Live Firebase User Document Sync & Sub-collections Setup
    _ensureBlindDocumentExistsAndInitializeSubcollections();

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

  User? get currentUser => FirebaseAuth.instance.currentUser;
  String? get currentUid => currentUser?.uid;

  // ================= LIVE FIREBASE DOC & SUB-COLLECTIONS SETUP =================
  /// Ensures parent 'blind' document exists AND initializes sub-collections in Firestore
  Future<void> _ensureBlindDocumentExistsAndInitializeSubcollections() async {
    if (currentUser == null) return;

    try {
      final docRef = FirebaseFirestore.instance.collection('blind').doc(currentUser!.uid);

      // 1. Parent 'blind' Document create/merge with user details
      await docRef.set({
        'email': currentUser!.email?.trim().toLowerCase() ?? '',
        'name': currentUser!.displayName ?? 'Blind User',
        'lastActive': FieldValue.serverTimestamp(),
        'role': 'blind',
      }, SetOptions(merge: true));

      // 2. Initialize required Sub-collections automatically if not present
      // --- 'ai_scene' sub-collection ---
      final aiRef = docRef.collection('ai_scene').doc('init_log');
      final aiDoc = await aiRef.get();
      if (!aiDoc.exists) {
        await aiRef.set({
          'action': 'Initialization',
          'description': 'AI Scene sub-collection initialized',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // --- 'call' sub-collection ---
      final callRef = docRef.collection('call').doc('init_log');
      final callDoc = await callRef.get();
      if (!callDoc.exists) {
        await callRef.set({
          'action': 'Initialization',
          'status': 'ready',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // --- 'sos' sub-collection ---
      final sosRef = docRef.collection('sos').doc('init_log');
      final sosDoc = await sosRef.get();
      if (!sosDoc.exists) {
        await sosRef.set({
          'action': 'Initialization',
          'status': 'inactive',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      debugPrint("Live Firebase: Parent doc and sub-collections synced successfully!");
    } catch (e) {
      debugPrint("Live Firebase Sync Error: $e");
    }
  }

  // ================= VOICE LOGIC =================

  Future<void> _startDashboardVoiceGuide() async {
    await flutterTts.stop();
    _speech.stop();

    await _speak(
      "Dashboard opened. Say Call Volunteer, Scene Description, SOS, or Edit Profile.",
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
    } else if (command.contains("scene")) {
      await _speak("Opening scene description");
      await _firestoreAI();
      _navigate('/scene');
    } else if (command.contains("sos")) {
      await _speak("SOS activated");
      await _firestoreSOS();
      _navigate('/sos');
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

  // ================= FIRESTORE SUB-COLLECTIONS LOGS =================

  Future<void> _firestoreCall() async {
    if (currentUid == null) return;

    try {
      await _ensureBlindDocumentExistsAndInitializeSubcollections();

      // Save entry to 'call' sub-collection
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid)
          .collection('call')
          .add({
        'action': 'Volunteer Call Initiated',
        'type': 'video_call',
        'status': 'calling',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CallVolunteerScreen(),
          ),
        ).then((_) => _startDashboardVoiceGuide());
      }
    } catch (e) {
      debugPrint('Firestore Error: $e');
      await _speak("Failed to initiate call. Please try again.");
    }
  }

  Future<void> _firestoreSOS() async {
    if (currentUid == null) return;
    try {
      await _ensureBlindDocumentExistsAndInitializeSubcollections();

      // Save entry to 'sos' sub-collection
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid)
          .collection('sos')
          .add({
        'action': 'SOS Triggered',
        'status': 'active',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firestore SOS Error: $e");
    }
  }

  Future<void> _firestoreAI() async {
    if (currentUid == null) return;
    try {
      await _ensureBlindDocumentExistsAndInitializeSubcollections();

      // Save entry to 'ai_scene' sub-collection
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid)
          .collection('ai_scene')
          .add({
        'action': 'Scene Scan Started',
        'status': 'processing',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firestore AI Error: $e");
    }
  }

  Future<void> _firestoreEditProfile() async {
    if (currentUid == null) return;
    try {
      await _ensureBlindDocumentExistsAndInitializeSubcollections();

      // Save entry to 'profile_edits' sub-collection
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid)
          .collection('profile_edits')
          .add({
        'action': 'Profile Edit Accessed',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firestore Edit Profile Error: $e");
    }
  }

  // ================= PROFESSIONAL UI COMPONENTS =================

  Widget buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                    SizedBox(width: 6),
                    Text(
                      "Live Assistant",
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap any feature below or speak a command directly.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget buildVoiceStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isListening ? Colors.redAccent.shade100 : Colors.purple.shade100,
            radius: 22,
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: isListening ? Colors.red.shade800 : Colors.purple.shade800,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isListening ? "Listening for commands..." : "Voice Assistant Active",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2A0845),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isListening ? "Speak clearly into your mic" : "Say 'Call Volunteer', 'SOS', etc.",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Colors.purple),
            onPressed: () => _startDashboardVoiceGuide(),
          ),
        ],
      ),
    );
  }

  Widget buildButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Blind Dashboard"),
      backgroundColor: const Color(0xFFF6F4F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner
              buildHeaderBanner(),

              const SizedBox(height: 20),

              // Grid Section
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF330066),
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,
                children: [
                  buildButton(
                    label: "Call Volunteer",
                    icon: Icons.videocam_rounded,
                    colors: [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
                    onPressed: () async {
                      await _firestoreCall();
                    },
                  ),
                  buildButton(
                    label: "Scene AI",
                    icon: Icons.remove_red_eye_rounded,
                    colors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                    onPressed: () async {
                      await _firestoreAI();
                      _navigate('/scene');
                    },
                  ),
                  buildButton(
                    label: "SOS Alert",
                    icon: Icons.warning_amber_rounded,
                    colors: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
                    onPressed: () async {
                      await _firestoreSOS();
                      _navigate('/sos');
                    },
                  ),
                  buildButton(
                    label: "Edit Profile",
                    icon: Icons.person_rounded,
                    colors: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
                    onPressed: () async {
                      await _firestoreEditProfile();
                      _navigate('/editprofile');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bottom Voice Status Indicator
              buildVoiceStatusCard(),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}