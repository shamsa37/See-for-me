import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class BlindLocationEngine {
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<DocumentSnapshot>? _settingsSubscription;

  // 🎯 Background Location Tracking Start Function
  Future<void> startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. GPS status check
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ GPS Service is disabled.');
      return;
    }

    // 2. Permission handling
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
    if (currentUid == null) return;

    // 3. Find linked Family Member
    try {
      final connectionSnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('blindUserId', isEqualTo: currentUid)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      if (connectionSnapshot.docs.isNotEmpty) {
        String familyMemberId = connectionSnapshot.docs.first['familyMemberId'];

        // 4. Listen to Family Settings in REAL-TIME
        _settingsSubscription = FirebaseFirestore.instance
            .collection('family')
            .doc(familyMemberId)
            .collection('settings')
            .doc('app_settings')
            .snapshots()
            .listen((settingsSnapshot) {
          int intervalSeconds = 15; // Default

          if (settingsSnapshot.exists && settingsSnapshot.data() != null) {
            String frequencyString = settingsSnapshot.data()!['updateFrequency'] ?? "Every 15 sec";

            if (frequencyString.contains("5 sec")) intervalSeconds = 5;
            else if (frequencyString.contains("15 sec")) intervalSeconds = 15;
            else if (frequencyString.contains("30 sec")) intervalSeconds = 30;
            else if (frequencyString.contains("1 min")) intervalSeconds = 60;
          }

          debugPrint("⏱️ Location Engine updated! Sync interval set to: $intervalSeconds seconds");

          _restartPositionStream(currentUid!, intervalSeconds);
        });
      } else {
        _restartPositionStream(currentUid, 15);
      }
    } catch (e) {
      debugPrint("Error initializing dynamic location engine: $e");
      _restartPositionStream(currentUid!, 15);
    }
  }

  // 🔄 Restarts GPS updates
  void _restartPositionStream(String uid, int seconds) {
    _positionStreamSubscription?.cancel();

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      debugPrint("📍 Location Fetched: ${position.latitude}, ${position.longitude}");

      try {
        await FirebaseFirestore.instance
            .collection('blind')
            .doc(uid)
            .update({
          'live_location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'last_updated': FieldValue.serverTimestamp(),
          }
        });
        debugPrint("✅ Firestore live_location synced successfully!");
      } catch (e) {
        debugPrint("❌ Failed to push dynamic location: $e");
      }
    });
  }

  // Stop Tracking
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _settingsSubscription?.cancel();
  }
}