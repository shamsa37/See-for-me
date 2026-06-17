// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:image_picker/image_picker.dart';
//
//
// class ScenedescriptionScreen extends StatefulWidget {
//   const ScenedescriptionScreen({super.key});
//
//   @override
//   State<ScenedescriptionScreen> createState() =>
//       _ScenedescriptionScreenState();
// }
//
// class _ScenedescriptionScreenState extends State<ScenedescriptionScreen> {
//   final FlutterTts _tts = FlutterTts();
//   String _description = "No scene captured yet.";
//   Future<String> detectSceneFromAPI(File image) async {
//
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('http://192.168.10.9:8000/detect/'), // ✔ apna real PC IP
//     );
//
//     request.files.add(
//       await http.MultipartFile.fromPath('file', image.path),
//     );
//
//     var response = await request.send();
//
//     return await response.stream.bytesToString();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _initTts();
//   }
//
//   Future<void> _initTts() async {
//     await _tts.setLanguage("en-US");
//     await _tts.setSpeechRate(0.5);
//     await _tts.setPitch(1.0);
//     await _tts.awaitSpeakCompletion(true);
//
//     _speak(
//       "Scene description screen. Press the capture scene button to hear the description.",
//     );
//   }
//
//   Future<void> _speak(String text) async {
//     await _tts.stop();
//     await _tts.speak(text);
//   }
//
//   void _captureScene() async {
//
//     final picked = await ImagePicker().pickImage(source: ImageSource.camera);
//
//     if (picked == null) return;
//
//     File image = File(picked.path);
//
//     String result = await detectSceneFromAPI(image);
//
//     setState(() {
//       _description = result;
//     });
//
//     _speak(result);
//   }
//
//   @override
//   void dispose() {
//     _tts.stop();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // ✅ AppBar added (No settings icon)
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: const Text(
//           "Scene Description",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         automaticallyImplyLeading: true, // back button if navigated
//         // ❌ NO actions → settings icon removed
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: const Color(0xFFF3E5F5),
//         child: Column(
//           children: [
//             Expanded(
//               child: Container(
//                 color: Colors.black12,
//                 child: const Center(
//                   child: Text(
//                     "📷 Camera Preview\n(Disabled in Web Demo)",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Text(
//                     _description,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: 200,
//                     height: 50,
//                     child: OutlinedButton(
//                       onPressed: _captureScene,
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(
//                           color: Colors.purple,
//                           width: 2,
//                         ),
//                         foregroundColor: Colors.purple,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       child: const Text(
//                         "Capture Scene",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//


import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class ScenedescriptionScreen extends StatefulWidget {
  const ScenedescriptionScreen({super.key});

  @override
  State<ScenedescriptionScreen> createState() => _ScenedescriptionScreenState();
}

class _ScenedescriptionScreenState extends State<ScenedescriptionScreen> {
  final FlutterTts _tts = FlutterTts();
  final ApiService api = ApiService();
  CameraController? _controller;
  List<CameraDescription>? cameras;
  String _description = "No scene detected yet.";
  bool isDetecting = false;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initTts();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras![0], ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.speak("Scene description started");
  }

  Future<void> _speak(String text) async {
    if (!mounted) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _logDetection(String detectedText) async {
    if (currentUid == null || detectedText == "Nothing detected") return;
    try {
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid)
          .collection('scene_logs')
          .add({
        'description': detectedText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firestore Error: $e");
    }
  }

  Future<void> _startDetection() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await _initCamera();
    }

    setState(() {
      isDetecting = true;
      _description = "Starting detection...";
    });

    while (isDetecting) {
      try {
        // 1. ZAROORI CHECK: Kya controller dispose toh nahi ho gaya?
        if (!mounted || _controller == null || !_controller!.value.isInitialized) {
          print("Stopping: Camera not ready or disposed");
          break;
        }

        // 2. SAFETY LOCK: Agar camera pehle se picture le raha hai toh wait karein
        if (_controller!.value.isTakingPicture) {
          print("Camera busy, skipping this cycle...");
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        print("📸 Taking Picture...");
        final image = await _controller!.takePicture();
        File file = File(image.path);

        if (!mounted) break;
        setState(() => _description = "Processing.....");

        // API Call
        print("🌐 Sending to API...");
        String result = await api.detectImage(file).timeout(
          const Duration(seconds: 60),
          onTimeout: () => '{"error": "timeout", "objects": ["Connection Timeout"]}',
        );

        print("📡 RAW API Response: $result");
        var data = jsonDecode(result);
        List objects = data["objects"] ?? [];
        String sentence = objects.isNotEmpty ? objects.join(", ") : "Nothing detected";

        if (mounted && isDetecting) {
          setState(() => _description = sentence);
          await _logDetection(sentence);
          await _speak(sentence);
        }

        // File delete karein taake storage full na ho
        if (await file.exists()) await file.delete();

        // Agli picture se pehle 5 second ka gap
        await Future.delayed(const Duration(seconds: 5));

      } catch (e) {
        print("❌ Loop Error: $e");
        // Agar "disposed" ka error aaye toh loop ko foran stop kar dein
        if (e.toString().contains("disposed")) {
          setState(() => isDetecting = false);
          break;
        }
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }

  void _stopDetection() {
    setState(() => isDetecting = false);
    _tts.stop();
  }

  @override
  void dispose() {
    isDetecting = false;
    _controller?.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Scene Description", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _controller != null && _controller!.value.isInitialized
                ? CameraPreview(_controller!)
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: isDetecting ? null : _startDetection,
                      child: const Text("Start", style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: !isDetecting ? null : _stopDetection,
                      child: const Text("Stop", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}