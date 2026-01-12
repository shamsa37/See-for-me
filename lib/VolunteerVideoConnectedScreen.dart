import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class VolunteerVideoConnectedScreen extends StatefulWidget {
  final String blindName;
  final String volunteerName;

  const VolunteerVideoConnectedScreen({
    super.key,
    required this.blindName,
    required this.volunteerName,
  });

  @override
  State<VolunteerVideoConnectedScreen> createState() =>
      _VolunteerVideoConnectedScreenState();
}

class _VolunteerVideoConnectedScreenState
    extends State<VolunteerVideoConnectedScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isMicOn = true;
  bool _isVideoOn = true;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController =
          CameraController(_cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Call with ${widget.blindName}"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          // 🔹 Remote video placeholder
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: const Center(
                child: Text(
                  "Remote Video",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),

          // 🔹 Local camera preview (small overlay)
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned(
              top: 40,
              right: 20,
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CameraPreview(_cameraController!),
              ),
            ),

          // 🔹 Bottom controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circleBtn(
                  icon: _isMicOn ? Icons.mic : Icons.mic_off,
                  onTap: () => setState(() => _isMicOn = !_isMicOn),
                ),
                _circleBtn(
                  icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
                  onTap: () => setState(() => _isVideoOn = !_isVideoOn),
                ),
                _circleBtn(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black54,
  }) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 28,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}