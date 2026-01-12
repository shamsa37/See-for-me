import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ManagePermissionsScreen extends StatefulWidget {
  const ManagePermissionsScreen({super.key});

  @override
  State<ManagePermissionsScreen> createState() =>
      _ManagePermissionsScreenState();
}

class _ManagePermissionsScreenState extends State<ManagePermissionsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  Map<String, bool> permissionStatus = {
    'Camera': false,
    'Microphone': false,
    'Location': false,
    'SMS': false,
  };

  bool highContrast = false; // You can link this with shared preferences later

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
    flutterTts.speak("Manage permissions screen opened");
  }

  Color getBackgroundColor() {
    return highContrast ? Colors.black : const Color(0xFFF5F5F5);
  }

  Color getTextColor() {
    return highContrast ? Colors.yellow : Colors.black;
  }

  Future<void> _checkAllPermissions() async {
    Map<String, bool> updated = {
      'Camera': await Permission.camera.isGranted,
      'Microphone': await Permission.microphone.isGranted,
      'Location': await Permission.location.isGranted,
      'SMS': await Permission.sms.isGranted,
    };
    setState(() {
      permissionStatus = updated;
    });
  }

  Future<void> _requestPermission(Permission permission, String name) async {
    var status = await permission.request();
    if (status.isGranted) {
      await flutterTts.speak("$name permission granted");
    } else if (status.isDenied) {
      await flutterTts.speak("$name permission denied");
    } else if (status.isPermanentlyDenied) {
      await flutterTts.speak("$name permission permanently denied");
    }
    _checkAllPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Permissions"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: getBackgroundColor(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const SizedBox(height: 10),
            Text(
              "App Permissions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: getTextColor(),
              ),
            ),
            const SizedBox(height: 10),

            _buildPermissionTile(
              icon: Icons.camera_alt,
              title: "Camera Access",
              isGranted: permissionStatus['Camera'] ?? false,
              onTap: () => _requestPermission(Permission.camera, "Camera"),
            ),

            _buildPermissionTile(
              icon: Icons.mic,
              title: "Microphone Access",
              isGranted: permissionStatus['Microphone'] ?? false,
              onTap: () => _requestPermission(Permission.microphone, "Microphone"),
            ),

            _buildPermissionTile(
              icon: Icons.location_on,
              title: "Location Access",
              isGranted: permissionStatus['Location'] ?? false,
              onTap: () => _requestPermission(Permission.location, "Location"),
            ),

            _buildPermissionTile(
              icon: Icons.sms,
              title: "SMS Access",
              isGranted: permissionStatus['SMS'] ?? false,
              onTap: () => _requestPermission(Permission.sms, "SMS"),
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text("Open App Settings",
                  style: TextStyle(color: getTextColor())),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await openAppSettings();
                await flutterTts.speak("Opening app settings");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return Card(
      color: highContrast ? Colors.grey[900] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: isGranted ? Colors.green : Colors.red),
        title: Text(
          title,
          style: TextStyle(
              color: getTextColor(), fontWeight: FontWeight.w500, fontSize: 16),
        ),
        subtitle: Text(
          isGranted ? "Granted" : "Not Granted",
          style: TextStyle(
              color: isGranted ? Colors.green : Colors.red, fontSize: 14),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isGranted ? Colors.green : Colors.deepPurple,
            foregroundColor:
            isGranted ? Colors.black : Colors.white, // ✅ Text color change
          ),
          onPressed: onTap,
          child: Text(isGranted ? "Recheck" : "Allow"),
        ),
      ),
    );
  }
}