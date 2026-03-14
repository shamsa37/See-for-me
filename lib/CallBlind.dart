// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class CallBlind extends StatefulWidget {
//   final String contactName;
//   final String contactNumber;
//
//   const CallBlind({
//     super.key,
//     required this.contactName,
//     required this.contactNumber,
//   });
//
//   @override
//   State<CallBlind> createState() => _CallBlindState();
// }
//
// class _CallBlindState extends State<CallBlind> {
//   bool _callStarted = false;
//   bool isMuted = false;
//   bool isSpeakerOn = true;
//
//   // Function to make a phone call
//   Future<void> _makePhoneCall(String number) async {
//     final Uri launchUri = Uri(scheme: 'tel', path: number);
//     if (await canLaunchUrl(launchUri)) {
//       await launchUrl(launchUri);
//       setState(() {
//         _callStarted = true;
//       });
//     } else {
//       throw "Could not launch $number";
//     }
//   }
//
//   void toggleMute() => setState(() => isMuted = !isMuted);
//   void toggleSpeaker() => setState(() => isSpeakerOn = !isSpeakerOn);
//   void endCall() => Navigator.pop(context);
//
//   @override
//   void initState() {
//     super.initState();
//     _makePhoneCall(widget.contactNumber);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.account_circle, size: 120, color: Colors.white),
//             const SizedBox(height: 20),
//             Text(
//               widget.contactName,
//               style: const TextStyle(
//                   fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.contactNumber,
//               style: const TextStyle(fontSize: 20, color: Colors.white70),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 50),
//             Text(
//               _callStarted ? "Calling..." : "Connecting...",
//               style: const TextStyle(fontSize: 18, color: Colors.white60),
//             ),
//             const SizedBox(height: 80),
//
//             // Call controls row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // Mute button
//                 CircleAvatar(
//                   backgroundColor: Colors.grey[800],
//                   child: IconButton(
//                     icon: Icon(isMuted ? Icons.mic_off : Icons.mic,
//                         color: Colors.white),
//                     onPressed: toggleMute,
//                   ),
//                 ),
//
//                 // Speaker toggle
//                 CircleAvatar(
//                   backgroundColor: Colors.grey[800],
//                   child: IconButton(
//                     icon: Icon(
//                         isSpeakerOn ? Icons.volume_up : Icons.hearing,
//                         color: Colors.white),
//                     onPressed: toggleSpeaker,
//                   ),
//                 ),
//
//                 // End Call (red)
//                 CircleAvatar(
//                   backgroundColor: Colors.red,
//                   child: IconButton(
//                     icon: const Icon(Icons.call_end, color: Colors.white),
//                     onPressed: endCall,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallBlind extends StatefulWidget {
  final String contactName;
  final String contactNumber;
  final VoidCallback? onCallEnded; // <-- added

  const CallBlind({
    super.key,
    required this.contactName,
    required this.contactNumber,
    this.onCallEnded, // <-- optional callback
  });

  @override
  State<CallBlind> createState() => _CallBlindState();
}

class _CallBlindState extends State<CallBlind> {
  bool _callStarted = false;
  bool isMuted = false;
  bool isSpeakerOn = true;

  // Function to make a phone call
  Future<void> _makePhoneCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
      setState(() {
        _callStarted = true;
      });
    } else {
      throw "Could not launch $number";
    }
  }

  void toggleMute() => setState(() => isMuted = !isMuted);
  void toggleSpeaker() => setState(() => isSpeakerOn = !isSpeakerOn);

  void endCall() {
    widget.onCallEnded?.call(); // <-- trigger TTS callback
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _makePhoneCall(widget.contactNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 120, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              widget.contactName,
              style: const TextStyle(
                  fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.contactNumber,
              style: const TextStyle(fontSize: 20, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            Text(
              _callStarted ? "Calling..." : "Connecting...",
              style: const TextStyle(fontSize: 18, color: Colors.white60),
            ),
            const SizedBox(height: 80),

            // Call controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: IconButton(
                    icon: Icon(isMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.white),
                    onPressed: toggleMute,
                  ),
                ),

                // Speaker toggle
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: IconButton(
                    icon: Icon(
                        isSpeakerOn ? Icons.volume_up : Icons.hearing,
                        color: Colors.white),
                    onPressed: toggleSpeaker,
                  ),
                ),

                // End Call (red)
                CircleAvatar(
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.white),
                    onPressed: endCall, // <-- triggers TTS
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}