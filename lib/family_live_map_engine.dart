import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

// ============================================================================
// 1. BLIND LOCATION ENGINE (Gps Location Tracker)
// ============================================================================
class BlindLocationEngine {
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<DocumentSnapshot>? _settingsSubscription;

  /// 🎯 Start Background & Live Location Tracking
  Future<void> startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check GPS Service Status
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ GPS Service is disabled.');
      return;
    }

    // 2. Request & Handle Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('❌ Location permissions are denied.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Location permissions are permanently denied.');
      return;
    }

    String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      debugPrint('❌ No logged in user found.');
      return;
    }

    // 3. Find connected Family Member
    try {
      final connectionSnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('blindUserId', isEqualTo: currentUid)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      if (connectionSnapshot.docs.isNotEmpty) {
        String familyMemberId = connectionSnapshot.docs.first['familyMemberId'];

        // 4. Real-time Listener for Family App Settings
        _settingsSubscription = FirebaseFirestore.instance
            .collection('family')
            .doc(familyMemberId)
            .collection('settings')
            .doc('app_settings')
            .snapshots()
            .listen((settingsSnapshot) {
          int intervalSeconds = 15; // Default

          if (settingsSnapshot.exists && settingsSnapshot.data() != null) {
            String frequencyString =
                settingsSnapshot.data()!['updateFrequency'] ?? "Every 15 sec";

            if (frequencyString.contains("5 sec")) {
              intervalSeconds = 5;
            } else if (frequencyString.contains("15 sec")) {
              intervalSeconds = 15;
            } else if (frequencyString.contains("30 sec")) {
              intervalSeconds = 30;
            } else if (frequencyString.contains("1 min")) {
              intervalSeconds = 60;
            }
          }

          debugPrint("⏱️ Sync interval updated to: $intervalSeconds seconds");
          _restartPositionStream(currentUid, intervalSeconds);
        });
      } else {
        _restartPositionStream(currentUid, 15);
      }
    } catch (e) {
      debugPrint("Error initializing dynamic location engine: $e");
      _restartPositionStream(currentUid, 15);
    }
  }

  /// 🔄 Restart GPS Stream with Filters
  void _restartPositionStream(String uid, int seconds) {
    _positionStreamSubscription?.cancel();

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // Update when user moves at least 3 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      debugPrint("📍 Location Fetched: ${position.latitude}, ${position.longitude}");

      try {
        // Safe update using set with merge: true
        await FirebaseFirestore.instance
            .collection('blind')
            .doc(uid)
            .set({
          'live_location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'last_updated': FieldValue.serverTimestamp(),
          }
        }, SetOptions(merge: true));

        debugPrint("✅ Firestore live_location synced successfully!");
      } catch (e) {
        debugPrint("❌ Failed to push dynamic location: $e");
      }
    });
  }

  /// Stop Tracking Stream
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _settingsSubscription?.cancel();
  }
}

// ============================================================================
// 2. FAMILY LIVE MAP SCREEN (OpenStreetMap View)
// ============================================================================
class FamilyLiveMapScreen extends StatefulWidget {
  const FamilyLiveMapScreen({Key? key}) : super(key: key);

  @override
  State<FamilyLiveMapScreen> createState() => _FamilyLiveMapScreenState();
}

class _FamilyLiveMapScreenState extends State<FamilyLiveMapScreen> {
  final MapController _mapController = MapController();

  String? get currentFamilyUid => FirebaseAuth.instance.currentUser?.uid;
  String? blindUserId;

  LatLng? _currentBlindPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _findConnectedBlindUser();
  }

  /// Find connected Blind User ID
  Future<void> _findConnectedBlindUser() async {
    if (currentFamilyUid == null) {
      debugPrint("❌ Family UID Null hai! User login nahi hai.");
      setState(() => _isLoading = false);
      return;
    }

    debugPrint("🔍 Current Family UID: $currentFamilyUid");

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('familyMemberId', isEqualTo: currentFamilyUid)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          blindUserId = querySnapshot.docs.first['blindUserId'];
          _isLoading = false;
        });
        debugPrint("✅ Linked Blind User Found ID: $blindUserId");
      } else {
        debugPrint("❌ Connections collection mein 'accepted' connection nahi mila!");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Error finding blind user: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking (OpenStreetMap)'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : blindUserId == null
          ? const Center(
        child: Text(
          'No connected blind user found.\nPlease accept a connection request first.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blind')
            .doc(blindUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint("❌ Stream Error: ${snapshot.error}");
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              _currentBlindPosition == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>?;
            debugPrint("📄 Blind User Firestore Data: $data");

            if (data != null &&
                data.containsKey('live_location') &&
                data['live_location'] != null) {
              var loc = data['live_location'];

              if (loc['latitude'] != null && loc['longitude'] != null) {
                double lat = (loc['latitude'] as num).toDouble();
                double lng = (loc['longitude'] as num).toDouble();

                debugPrint("📍 Fetched Coordinates: Lat $lat, Lng $lng");

                if (lat != 0.0 && lng != 0.0) {
                  _currentBlindPosition = LatLng(lat, lng);

                  // Camera movement on location update
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    try {
                      _mapController.move(_currentBlindPosition!, 16.5);
                    } catch (_) {}
                  });
                }
              }
            } else {
              debugPrint("⚠️ 'live_location' key missing in Firestore document!");
            }
          }

          // Fallback when coordinates are null or 0.0
          if (_currentBlindPosition == null ||
              (_currentBlindPosition!.latitude == 0.0 &&
                  _currentBlindPosition!.longitude == 0.0)) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 60, color: Colors.amber),
                    SizedBox(height: 15),
                    Text(
                      "Waiting for Blind User's GPS Location...\nMake sure Blind App is open & GPS is ON.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentBlindPosition!,
                  initialZoom: 16.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.project',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentBlindPosition!,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.purple,
                          size: 45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Live Status Badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 12),
                      SizedBox(width: 8),
                      Text(
                        "Live Updates Active",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}