/*import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMuted = false;
  bool isCameraOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Live Video Call"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // background video (placeholder)
          Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(Icons.videocam, color: Colors.white54, size: 100),
            ),
          ),
          // small preview
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white70, size: 50),
              ),
            ),
          ),
          // bottom controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.black.withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: isMuted ? Icons.mic_off : Icons.mic,
                    label: "Mute",
                    color: isMuted ? Colors.redAccent : Colors.white,
                    onPressed: () {
                      setState(() => isMuted = !isMuted);
                    },
                  ),
                  _buildControlButton(
                    icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                    label: "Camera",
                    color: isCameraOn ? Colors.white : Colors.redAccent,
                    onPressed: () {
                      setState(() => isCameraOn = !isCameraOn);
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: "End",
                    color: Colors.redAccent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white12,
          child: IconButton(
            icon: Icon(icon, color: color, size: 30),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String callerImage; // Asset path or network URL

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.callerImage,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Animation setup for pulsing caller avatar
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);

    // Play ringtone in loop
    _playRingtone();
  }

  void _playRingtone() async {
    // Make sure to add ringtone file in assets folder and pubspec.yaml
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('ringtone.mp3'));
  }

  void _stopRingtone() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stopRingtone();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade800, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Caller info with pulse animation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(widget.callerImage),
                    // For network image use: NetworkImage(widget.callerImage)
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.callerName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Incoming Video Call...",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          ),

          // Accept / Decline buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(
                    icon: Icons.call,
                    label: "Accept",
                    color: Colors.green,
                    onPressed: () {
                      _stopRingtone();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VideoCallScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCallButton(
                    icon: Icons.call_end,
                    label: "Decline",
                    color: Colors.red,
                    onPressed: () {
                      _stopRingtone();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: IconButton(
            icon: Icon(icon, color: color, size: 30),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

// Example ongoing call screen (from your original code)
class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMuted = false;
  bool isCameraOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Live Video Call"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(Icons.videocam, color: Colors.white54, size: 100),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white70, size: 50),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.black.withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: isMuted ? Icons.mic_off : Icons.mic,
                    label: "Mute",
                    color: isMuted ? Colors.redAccent : Colors.white,
                    onPressed: () {
                      setState(() => isMuted = !isMuted);
                    },
                  ),
                  _buildControlButton(
                    icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                    label: "Camera",
                    color: isCameraOn ? Colors.white : Colors.redAccent,
                    onPressed: () {
                      setState(() => isCameraOn = !isCameraOn);
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: "End",
                    color: Colors.redAccent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white12,
          child: IconButton(
            icon: Icon(icon, color: color, size: 30),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
