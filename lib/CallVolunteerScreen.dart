/*import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/VolunteerCallLogsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
//import 'VolunteerCallLogsScreen.dart';

const String appId = "YOUR_AGORA_APP_ID";
const String channelName = "seeforme_channel";
const String tempToken = "YOUR_TEMP_TOKEN";

class CallVolunteerScreen extends StatefulWidget {
  @override
  _CallVolunteerScreenState createState() => _CallVolunteerScreenState();
}

class _CallVolunteerScreenState extends State<CallVolunteerScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  RtcEngine? _engine;

  bool _micMuted = false;
  bool _cameraOff = false;

  Position? _currentPosition;
  GoogleMapController? _mapController;

  DateTime? _callStartTime;
  bool _callConnected = false;

  @override
  void initState() {
    super.initState();
    initAgora();
    _getCurrentLocation();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    final engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(appId: appId));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() {
            _localUserJoined = true;
            _callStartTime = DateTime.now();
          });
          _saveCallLog("Outgoing");
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            _remoteUid = remoteUid;
            _callConnected = true;
          });
          _saveCallLog("Incoming");
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUid = null;
          });
          _saveCallLog("Missed");
        },
      ),
    );

    await engine.enableVideo();
    await engine.startPreview();
    await engine.joinChannel(
      token: tempToken,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    setState(() {
      _engine = engine;
    });
  }

  Future<void> _saveCallLog(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('volunteer_call_logs') ?? [];

    final endTime = DateTime.now();
    final duration = _callStartTime != null
        ? endTime.difference(_callStartTime!).inSeconds
        : 0;

    final log = {
      'type': type,
      'datetime': endTime.toString(),
      'duration': '${(duration ~/ 60)}m ${(duration % 60)}s'
    };

    logs.add(jsonEncode(log));
    await prefs.setStringList('volunteer_call_logs', logs);
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  void _toggleMic() {
    if (_engine != null) {
      setState(() => _micMuted = !_micMuted);
      _engine!.muteLocalAudioStream(_micMuted);
    }
  }

  void _toggleCamera() {
    if (_engine != null) {
      setState(() => _cameraOff = !_cameraOff);
      _engine!.muteLocalVideoStream(_cameraOff);
    }
  }

  void _endCall() {
    _saveCallLog(_callConnected ? "Ended" : "Missed");
    _engine?.leaveChannel();
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _switchCamera() {
    _engine?.switchCamera();
  }

  void _openCallLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VolunteerCallLogsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer Call"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: "View Call Logs",
            onPressed: _openCallLogs,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: (_engine != null && _remoteUid != null)
                ? AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: channelName),
              ),
            )
                : Center(child: Text("Waiting for volunteer to join...")),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (_engine != null)
                    ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
                    : Container(color: Colors.black),
              ),
            ),
          ),
          if (_currentPosition != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("blind_location"),
                        position: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        infoWindow: InfoWindow(title: "Blind User Location"),
                      ),
                    },
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "mic",
                  backgroundColor: Colors.blue,
                  onPressed: _toggleMic,
                  child: Icon(
                    _micMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  heroTag: "end",
                  backgroundColor: Colors.red,
                  onPressed: _endCall,
                  child: Icon(Icons.call_end, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: "camera",
                  backgroundColor: Colors.blue,
                  onPressed: _toggleCamera,
                  child: Icon(
                    _cameraOff ? Icons.videocam_off : Icons.videocam,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  heroTag: "switch",
                  backgroundColor: Colors.green,
                  onPressed: _switchCamera,
                  child: Icon(Icons.cameraswitch, color: Colors.white),
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

class CallVolunteerScreen extends StatelessWidget {
  const CallVolunteerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connecting to Volunteer'),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// 🔄 Animation Icon
            const CircularProgressIndicator(
              color: Colors.deepPurple,
              strokeWidth: 6,
            ),

            const SizedBox(height: 30),

            const Text(
              'Calling available volunteers...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            const Text(
              'You will be connected as soon as a volunteer answers.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            /// ❌ Cancel Call
            ElevatedButton.icon(
              icon: const Icon(Icons.call_end),
              label: const Text('Cancel Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}