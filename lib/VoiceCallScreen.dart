import 'package:flutter/material.dart';
import 'VideoCallScreen.dart';

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool isMuted = false;
  bool isOnHold = false;
  bool isSpeakerOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text("Voice Call"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: const [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, size: 70, color: Colors.white),
                ),
                SizedBox(height: 15),
                Text(
                  "Blind User",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text("Voice call in progress...", style: TextStyle(fontSize: 16)),
              ],
            ),
            // --- Call control buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: isMuted ? Icons.mic_off : Icons.mic,
                  label: "Mute",
                  color: isMuted ? Colors.redAccent : Colors.deepPurple,
                  onPressed: () {
                    setState(() => isMuted = !isMuted);
                  },
                ),
                _buildControlButton(
                  icon: isOnHold ? Icons.pause : Icons.play_arrow,
                  label: "Hold",
                  color: isOnHold ? Colors.redAccent : Colors.deepPurple,
                  onPressed: () {
                    setState(() => isOnHold = !isOnHold);
                  },
                ),
                _buildControlButton(
                  icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                  label: "Speaker",
                  color: isSpeakerOn ? Colors.green : Colors.deepPurple,
                  onPressed: () {
                    setState(() => isSpeakerOn = !isSpeakerOn);
                  },
                ),
              ],
            ),
            // --- Bottom action buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.call_end),
                  label: const Text("End Call"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Switch to video call
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const VideoCallScreen()),
                    );
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text("Video Call"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.15),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}