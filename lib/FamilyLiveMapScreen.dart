import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // 1. Find connected Blind User ID
  Future<void> _findConnectedBlindUser() async {
    if (currentFamilyUid == null) return;

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
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error finding blind user: $e");
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
      // 2. Real-time Stream from Blind User's live_location
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blind')
            .doc(blindUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _currentBlindPosition == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;

            if (data.containsKey('live_location')) {
              double lat = data['live_location']['latitude'];
              double lng = data['live_location']['longitude'];

              _currentBlindPosition = LatLng(lat, lng);

              // Move map camera smoothly to new location
              try {
                _mapController.move(_currentBlindPosition!, 16.5);
              } catch (_) {}
            }
          }

          if (_currentBlindPosition == null) {
            return const Center(
              child: Text("Waiting for blind user's location..."),
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
                  // Free OpenStreetMap Tile Layer (No API Key needed)
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 12),
                      SizedBox(width: 8),
                      Text("Live Updates Active", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
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