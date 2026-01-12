

/*import 'package:flutter/material.dart';
import 'package:project/CustomAppBar.dart';

class EmergencyVideoCallScreen extends StatefulWidget {
  final String contactName;
  final String contactNumber;

  const EmergencyVideoCallScreen({
    super.key,
    this.contactName = "Unknown Contact",
    this.contactNumber = "N/A",
  });

  @override
  State<EmergencyVideoCallScreen> createState() =>
      _EmergencyVideoCallScreenState();
}

class _EmergencyVideoCallScreenState extends State<EmergencyVideoCallScreen> {
  bool isMuted = false;
  bool isFrontCamera = true;
  bool isSpeakerOn = true;

  void toggleMute() => setState(() => isMuted = !isMuted);
  void switchCamera() => setState(() => isFrontCamera = !isFrontCamera);
  void toggleSpeaker() => setState(() => isSpeakerOn = !isSpeakerOn);
  void endCall() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: "Emergency Video Call"),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.lightBlueAccent,
            child: const Center(
              child: Icon(
                Icons.videocam,
                size: 100,
                color: Colors.white70,
              ),
            ),
          ),

          // Contact info
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  widget.contactName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.contactNumber,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          ),

          // Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: IconButton(
                    icon: Icon(isMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.white),
                    onPressed: toggleMute,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: IconButton(
                    icon: const Icon(Icons.cameraswitch, color: Colors.white),
                    onPressed: switchCamera,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: IconButton(
                    icon: Icon(
                        isSpeakerOn ? Icons.volume_up : Icons.hearing,
                        color: Colors.white),
                    onPressed: toggleSpeaker,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.white),
                    onPressed: endCall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'dart:async';

class EmergencyVideoCallScreen extends StatefulWidget {
  final String contactName;
  final String contactNumber;

  const EmergencyVideoCallScreen({
    super.key,
    this.contactName = "Unknown Contact",
    this.contactNumber = "N/A",
  });

  @override
  State<EmergencyVideoCallScreen> createState() =>
      _EmergencyVideoCallScreenState();
}

class _EmergencyVideoCallScreenState extends State<EmergencyVideoCallScreen>
    with SingleTickerProviderStateMixin {
  bool isMuted = false;
  bool isFrontCamera = true;
  bool isSpeakerOn = true;

  late AnimationController _endCallController;
  late Animation<double> _pulseAnimation;

  // Timer
  int _secondsElapsed = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Animation for End Call button pulse
    _endCallController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(_endCallController);

    // Start call timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _endCallController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void toggleMute() => setState(() => isMuted = !isMuted);
  void switchCamera() => setState(() => isFrontCamera = !isFrontCamera);
  void toggleSpeaker() => setState(() => isSpeakerOn = !isSpeakerOn);
  void endCall() => Navigator.pop(context);

  String get formattedDuration {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // ❌ AppBar removed completely → full screen
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.videocam,
                size: 100,
                color: Colors.white70,
              ),
            ),
          ),

          // Contact info with avatar
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[800],
                  child:
                  const Icon(Icons.person, size: 50, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.contactName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.contactNumber,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          // Call duration timer at top-center
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  formattedDuration,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),

          // Small self-camera preview at top-right
          Positioned(
            top: 100,
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

          // Bottom controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isMuted
                      ? Colors.redAccent.withOpacity(0.3)
                      : Colors.grey[800],
                  child: IconButton(
                    icon: Icon(
                      isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: toggleMute,
                  ),
                ),
                // Switch camera
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[800],
                  child: IconButton(
                    icon: const Icon(Icons.cameraswitch,
                        color: Colors.white, size: 28),
                    onPressed: switchCamera,
                  ),
                ),
                // Speaker
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[800],
                  child: IconButton(
                    icon: Icon(
                      isSpeakerOn ? Icons.volume_up : Icons.hearing,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: toggleSpeaker,
                  ),
                ),
                // End call with pulse animation
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.call_end,
                          color: Colors.white, size: 28),
                      onPressed: endCall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
