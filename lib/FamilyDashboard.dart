//
// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// import 'FamilyAddContactScreen.dart';
// import 'CallBlind.dart';
// import 'EmergencyVideoCallScreen.dart';
// import 'HistoryScreen.dart';
// import 'NotificationScreen.dart';
// import 'FamilySettingScreen.dart';
//
// class FamilyDashboard extends StatefulWidget {
//   const FamilyDashboard({super.key});
//
//   @override
//   State<FamilyDashboard> createState() => _FamilyDashboardState();
// }
//
// class _FamilyDashboardState extends State<FamilyDashboard>
//     with TickerProviderStateMixin {
//
//   String blindUserName = "Fetching...";
//   String blindUserEmail = "";
//   String blindUserId = "";
//   String lastSeen = "Fetching...";
//   String currentAddress = "Tap below to view location";
//
//   double? latitude;
//   double? longitude;
//   bool isLoading = true;
//
//   int _selectedIndex = 0;
//   StreamSubscription? _blindUserSubscription;
//   StreamSubscription? _incomingCallSubscription;
//
//   // Google Map Controller
//   Completer<GoogleMapController> _mapController = Completer();
//   Set<Marker> _markers = {};
//
//   final List<Widget> _screens = const [
//     HistoryScreen(),
//     NotificationScreen(),
//     FamilySettingScreen(),
//   ];
//
//   String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchLinkedBlindUser();
//     _listenForIncomingCallsFromBlind();
//   }
//
//   @override
//   void dispose() {
//     _blindUserSubscription?.cancel();
//     _incomingCallSubscription?.cancel();
//     super.dispose();
//   }
//
//   // ================= FIRESTORE SUB-COLLECTIONS LOGGING FUNCTION =================
//   Future<void> _logFamilyAction({
//     required String actionType, // 'emergency_sos', 'call', 'view_location'
//     required String details,
//   }) async {
//     if (currentUid == null || blindUserId.isEmpty) return;
//
//     final timestamp = FieldValue.serverTimestamp();
//
//     try {
//       // 1. Sub-collection inside Family user document: family/{familyUid}/history/{docId}
//       await FirebaseFirestore.instance
//           .collection('family')
//           .doc(currentUid)
//           .collection('history')
//           .add({
//         'actionType': actionType,
//         'blindUserId': blindUserId,
//         'blindUserName': blindUserName,
//         'details': details,
//         'timestamp': timestamp,
//       });
//
//       // 2. Sub-collection inside Blind user document: blind/{blindUid}/alerts/{docId}
//       await FirebaseFirestore.instance
//           .collection('blind')
//           .doc(blindUserId)
//           .collection('alerts')
//           .add({
//         'triggeredBy': 'family',
//         'familyMemberId': currentUid,
//         'type': actionType,
//         'message': details,
//         'timestamp': timestamp,
//         'status': 'unread',
//       });
//
//       debugPrint("✅ Sub-collections updated for $actionType");
//     } catch (e) {
//       debugPrint("❌ Error logging to sub-collections: $e");
//     }
//   }
//
//   Future<void> _fetchLinkedBlindUser() async {
//     if (currentUid == null) return;
//     try {
//       final connectionSnapshot = await FirebaseFirestore.instance
//           .collection('connections')
//           .where('familyMemberId', isEqualTo: currentUid)
//           .get();
//
//       String targetBlindId = "";
//       for (var doc in connectionSnapshot.docs) {
//         if (doc.data()['status'] == 'accepted') {
//           targetBlindId = doc['blindUserId'].toString();
//           break;
//         }
//       }
//
//       if (targetBlindId.isNotEmpty) {
//         setState(() => blindUserId = targetBlindId);
//
//         final userDoc = await FirebaseFirestore.instance
//             .collection('blind')
//             .doc(targetBlindId)
//             .get();
//
//         if (userDoc.exists) {
//           setState(() {
//             blindUserName = userDoc.data()?['name'] ?? "Unknown Blind User";
//             blindUserEmail = userDoc.data()?['email'] ?? "";
//           });
//         }
//         _startLiveTrackingStream(targetBlindId);
//       } else {
//         setState(() {
//           blindUserName = "No Linked User";
//           currentAddress = "Please link with a blind user first.";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching family dashboard data: $e");
//       setState(() => isLoading = false);
//     }
//   }
//
//   // ================= LISTEN FOR INCOMING CALLS ONLY FROM BLIND USER =================
//   void _listenForIncomingCallsFromBlind() {
//     if (currentUid == null) return;
//
//     _incomingCallSubscription = FirebaseFirestore.instance
//         .collection('sessions')
//         .where('familyMemberId', isEqualTo: currentUid)
//         .where('sender', isEqualTo: 'blind')
//         .where('status', isEqualTo: 'ringing')
//         .snapshots()
//         .listen((snapshot) {
//       for (var change in snapshot.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final sessionId = change.doc.id;
//           _showIncomingCallDialog(sessionId);
//         }
//       }
//     });
//   }
//
//   // ================= SHOW INCOMING CALL ALERT DIALOG =================
//   void _showIncomingCallDialog(String sessionId) {
//     if (!mounted) return;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2E0249),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Row(
//             children: [
//               Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
//               SizedBox(width: 8),
//               Text(
//                 "Emergency Call",
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: Text(
//             "$blindUserName is calling you for assistance!",
//             style: const TextStyle(color: Colors.white70),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 await FirebaseFirestore.instance
//                     .collection('sessions')
//                     .doc(sessionId)
//                     .update({'status': 'rejected'});
//                 Navigator.of(dialogContext).pop();
//               },
//               child: const Text("Reject", style: TextStyle(color: Colors.redAccent)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               onPressed: () async {
//                 await FirebaseFirestore.instance
//                     .collection('sessions')
//                     .doc(sessionId)
//                     .update({'status': 'active'});
//
//                 Navigator.of(dialogContext).pop();
//
//                 if (mounted) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => EmergencyVideoCallScreen(
//                         contactName: blindUserName,
//                         contactNumber: blindUserEmail,
//                       ),
//                     ),
//                   );
//                 }
//               },
//               child: const Text("Accept", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // ================= TRIGGER OUTGOING CALL/SESSION TO BLIND =================
//   Future<void> _triggerFamilyCall(bool isEmergency) async {
//     if (blindUserId.isEmpty || currentUid == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No linked blind user found")),
//       );
//       return;
//     }
//
//     try {
//       await FirebaseFirestore.instance.collection('sessions').add({
//         'familyMemberId': currentUid,
//         'blindUserId': blindUserId,
//         'sender': 'family',
//         'status': 'ringing',
//         'type': isEmergency ? 'emergency' : 'call',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       // 📌 Log to Sub-collections
//       await _logFamilyAction(
//         actionType: isEmergency ? 'emergency_sos' : 'call',
//         details: isEmergency
//             ? 'Emergency SOS call initiated by Family'
//             : 'Normal Call initiated by Family',
//       );
//
//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => isEmergency
//                 ? EmergencyVideoCallScreen(
//               contactName: blindUserName,
//               contactNumber: blindUserEmail,
//             )
//                 : CallBlind(
//               contactName: blindUserName,
//               contactNumber: blindUserEmail,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error triggering call session: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to start call: $e")),
//         );
//       }
//     }
//   }
//
//   void _startLiveTrackingStream(String blindId) {
//     _blindUserSubscription = FirebaseFirestore.instance
//         .collection('blind')
//         .doc(blindId)
//         .snapshots()
//         .listen((snapshot) async {
//       if (snapshot.exists && snapshot.data() != null) {
//         final data = snapshot.data()!;
//         if (data.containsKey('live_location') && data['live_location'] != null) {
//           var locationData = data['live_location'];
//           double lat = (locationData['latitude'] as num).toDouble();
//           double lng = (locationData['longitude'] as num).toDouble();
//           Timestamp? ts = locationData['last_updated'];
//
//           setState(() {
//             latitude = lat;
//             longitude = lng;
//             if (ts != null) {
//               DateTime dt = ts.toDate();
//               lastSeen = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
//             } else {
//               lastSeen = "Just now";
//             }
//
//             _markers = {
//               Marker(
//                 markerId: MarkerId(blindId),
//                 position: LatLng(lat, lng),
//                 infoWindow: InfoWindow(title: blindUserName, snippet: currentAddress),
//                 icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//               )
//             };
//           });
//
//           await _convertCoordinatesToAddress(lat, lng);
//         } else {
//           setState(() {
//             currentAddress = "Location updates not started yet";
//             lastSeen = "Offline";
//           });
//         }
//       }
//       setState(() => isLoading = false);
//     });
//   }
//
//   Future<void> _convertCoordinatesToAddress(double lat, double lng) async {
//     if (lat == 0.0 && lng == 0.0) return;
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
//       if (placemarks.isNotEmpty) {
//         String address = "${placemarks[0].subLocality ?? ''}, ${placemarks[0].locality ?? ''}";
//         setState(() {
//           currentAddress = address.trim().isNotEmpty ? address : "Current Location Available";
//         });
//       }
//     } catch (e) {
//       setState(() => currentAddress = "Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}");
//     }
//   }
//
//   // ================= GOOGLE MAP MODAL SHEET =================
//   void _openLiveMapModal() {
//     if (latitude == null || longitude == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Live location coordinates not available yet")),
//       );
//       return;
//     }
//
//     _mapController = Completer();
//
//     // 📌 Log Location View to Sub-collections
//     _logFamilyAction(
//       actionType: 'view_location',
//       details: 'Family viewed live location ($currentAddress)',
//     );
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.80,
//           decoration: const BoxDecoration(
//             color: Color(0xFF190628),
//             borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//           ),
//           child: Column(
//             children: [
//               const SizedBox(height: 12),
//               Container(
//                 width: 45,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.white38,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "$blindUserName's Location",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           currentAddress,
//                           style: const TextStyle(color: Colors.white60, fontSize: 12),
//                         ),
//                       ],
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close_rounded, color: Colors.white70),
//                       onPressed: () => Navigator.pop(context),
//                     )
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                   child: GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: LatLng(latitude!, longitude!),
//                       zoom: 16.0,
//                     ),
//                     markers: _markers,
//                     mapType: MapType.normal,
//                     myLocationEnabled: false,
//                     zoomControlsEnabled: true,
//                     onMapCreated: (GoogleMapController controller) {
//                       if (!_mapController.isCompleted) {
//                         _mapController.complete(controller);
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _onNavItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//     Navigator.push(context, MaterialPageRoute(builder: (context) => _screens[index]));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text("Family Dashboard",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 26),
//             onPressed: () async {
//               bool? refresh = await Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const FamilyAddContactScreen()),
//               );
//               if (refresh == true) {
//                 _fetchLinkedBlindUser();
//               }
//             },
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF0B0211), Color(0xFF2E0249), Color(0xFF4A0E4E), Color(0xFF0B0211)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 18.0),
//         child: SafeArea(
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
//               : Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 12),
//
//               // Enhanced Linked User Profile Card
//               Container(
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.white.withOpacity(0.12),
//                       Colors.white.withOpacity(0.04)
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(24),
//                   border: Border.all(color: Colors.white.withOpacity(0.18)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.25),
//                       blurRadius: 15,
//                       spreadRadius: 2,
//                     )
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         CircleAvatar(
//                           radius: 32,
//                           backgroundColor: Colors.purpleAccent.withOpacity(0.3),
//                           child: const Icon(Icons.person, color: Colors.white, size: 36),
//                         ),
//                         Positioned(
//                           right: 2,
//                           bottom: 2,
//                           child: Container(
//                             width: 14,
//                             height: 14,
//                             decoration: BoxDecoration(
//                               color: Colors.greenAccent,
//                               shape: BoxShape.circle,
//                               border: Border.all(color: const Color(0xFF2E0249), width: 2),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             blindUserName,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 19,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               const Icon(Icons.access_time_filled,
//                                   color: Colors.greenAccent, size: 14),
//                               const SizedBox(width: 6),
//                               Text(
//                                 "Last Active: $lastSeen",
//                                 style: const TextStyle(
//                                     color: Colors.white70, fontSize: 13),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 28),
//               const Text(
//                 "Quick Actions",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5),
//               ),
//               const SizedBox(height: 14),
//
//               // Action 1: View Live Location
//               _buildActionTile(
//                 icon: Icons.map_rounded,
//                 iconColor: Colors.lightBlueAccent,
//                 title: "View Live Location",
//                 subtitle: currentAddress,
//                 onTap: _openLiveMapModal,
//               ),
//
//               const SizedBox(height: 14),
//
//               // Action 2: Call Blind User
//               _buildActionTile(
//                 icon: Icons.call_rounded,
//                 iconColor: Colors.greenAccent,
//                 title: "Call $blindUserName",
//                 subtitle: "Start Audio/Video assistance session",
//                 onTap: () => _triggerFamilyCall(false),
//               ),
//
//               const SizedBox(height: 14),
//
//               // Action 3: Emergency SOS Call
//               _buildActionTile(
//                 icon: Icons.warning_rounded,
//                 iconColor: Colors.redAccent,
//                 title: "Trigger Emergency SOS",
//                 subtitle: "High-priority emergency ring",
//                 onTap: () => _triggerFamilyCall(true),
//               ),
//
//               const Spacer(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(colors: [Colors.black, Color(0xFF38004D)]),
//           boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, -2))],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             BottomBarButton(icon: Icons.history, label: "History", isSelected: _selectedIndex == 0, onTap: () => _onNavItemTapped(0), vsync: this),
//             BottomBarButton(icon: Icons.notifications, label: "Notifications", isSelected: _selectedIndex == 1, onTap: () => _onNavItemTapped(1), vsync: this),
//             BottomBarButton(icon: Icons.settings, label: "Settings", isSelected: _selectedIndex == 2, onTap: () => _onNavItemTapped(2), vsync: this),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionTile({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.07),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.12)),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(20),
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: iconColor.withOpacity(0.2),
//                   child: Icon(icon, color: iconColor, size: 24),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         subtitle,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(color: Colors.white60, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // BottomBarButton Class
// class BottomBarButton extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final TickerProvider vsync;
//
//   const BottomBarButton({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//     required this.vsync,
//   });
//
//   @override
//   State<BottomBarButton> createState() => _BottomBarButtonState();
// }
//
// class _BottomBarButtonState extends State<BottomBarButton> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scale;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: widget.vsync, duration: const Duration(milliseconds: 250));
//     _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//     if (widget.isSelected) _controller.forward();
//   }
//
//   @override
//   void didUpdateWidget(covariant BottomBarButton oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isSelected) {
//       _controller.forward();
//     } else {
//       _controller.reverse();
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final color = widget.isSelected ? Colors.purpleAccent : Colors.white70;
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: ScaleTransition(
//         scale: _scale,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(widget.icon, color: color, size: 28),
//             const SizedBox(height: 4),
//             Text(
//               widget.label,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 12,
//                 fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'FamilyAddContactScreen.dart';
import 'CallBlind.dart';
import 'EmergencyVideoCallScreen.dart';
import 'HistoryScreen.dart';
import 'NotificationScreen.dart';
import 'FamilySettingScreen.dart';

class FamilyDashboard extends StatefulWidget {
  const FamilyDashboard({super.key});

  @override
  State<FamilyDashboard> createState() => _FamilyDashboardState();
}

class _FamilyDashboardState extends State<FamilyDashboard>
    with TickerProviderStateMixin {

  String blindUserName = "Fetching...";
  String blindUserEmail = "";
  String blindUserId = "";
  String lastSeen = "Fetching...";
  String currentAddress = "Tap below to view location";

  double? latitude;
  double? longitude;
  bool isLoading = true;

  int _selectedIndex = 0;
  StreamSubscription? _blindUserSubscription;
  StreamSubscription? _incomingCallSubscription;

  // Google Map Controller
  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};

  final List<Widget> _screens = const [
    HistoryScreen(),
    NotificationScreen(),
    FamilySettingScreen(),
  ];

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchLinkedBlindUser();
    _listenForIncomingCallsFromBlind();
  }

  @override
  void dispose() {
    _blindUserSubscription?.cancel();
    _incomingCallSubscription?.cancel();
    super.dispose();
  }

  // ================= FIRESTORE SUB-COLLECTIONS LOGGING FUNCTION =================
  Future<void> _logFamilyAction({
    required String actionType, // 'emergency_sos', 'call', 'view_location'
    required String details,
  }) async {
    if (currentUid == null || blindUserId.isEmpty) return;

    final timestamp = FieldValue.serverTimestamp();

    try {
      // 1. Sub-collection inside Family user document: family/{familyUid}/history/{docId}
      await FirebaseFirestore.instance
          .collection('family')
          .doc(currentUid)
          .collection('history')
          .add({
        'actionType': actionType,
        'blindUserId': blindUserId,
        'blindUserName': blindUserName,
        'details': details,
        'timestamp': timestamp,
      });

      // 2. Sub-collection inside Blind user document: blind/{blindUid}/alerts/{docId}
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(blindUserId)
          .collection('alerts')
          .add({
        'triggeredBy': 'family',
        'familyMemberId': currentUid,
        'type': actionType,
        'message': details,
        'timestamp': timestamp,
        'status': 'unread',
      });

      debugPrint("✅ Sub-collections updated for $actionType");
    } catch (e) {
      debugPrint("❌ Error logging to sub-collections: $e");
    }
  }

  Future<void> _fetchLinkedBlindUser() async {
    if (currentUid == null) return;
    try {
      final connectionSnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('familyMemberId', isEqualTo: currentUid)
          .get();

      String targetBlindId = "";
      for (var doc in connectionSnapshot.docs) {
        if (doc.data()['status'] == 'accepted') {
          targetBlindId = doc['blindUserId'].toString();
          break;
        }
      }

      if (targetBlindId.isNotEmpty) {
        setState(() => blindUserId = targetBlindId);

        final userDoc = await FirebaseFirestore.instance
            .collection('blind')
            .doc(targetBlindId)
            .get();

        if (userDoc.exists) {
          setState(() {
            blindUserName = userDoc.data()?['name'] ?? "Unknown Blind User";
            blindUserEmail = userDoc.data()?['email'] ?? "";
          });
        }
        _startLiveTrackingStream(targetBlindId);
      } else {
        setState(() {
          blindUserName = "No Linked User";
          currentAddress = "Please link with a blind user first.";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching family dashboard data: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= LISTEN FOR INCOMING CALLS ONLY FROM BLIND USER =================
  void _listenForIncomingCallsFromBlind() {
    if (currentUid == null) return;

    _incomingCallSubscription = FirebaseFirestore.instance
        .collection('sessions')
        .where('familyMemberId', isEqualTo: currentUid)
        .where('sender', isEqualTo: 'blind')
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final sessionId = change.doc.id;
          _showIncomingCallDialog(sessionId);
        }
      }
    });
  }

  // ================= SHOW INCOMING CALL ALERT DIALOG =================
  void _showIncomingCallDialog(String sessionId) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E0A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.4), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videocam_rounded, color: Colors.redAccent, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "Emergency Call",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            "$blindUserName is requesting a live video call for assistance!",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('sessions')
                    .doc(sessionId)
                    .update({'status': 'rejected'});
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Reject", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.call, color: Colors.white, size: 18),
              label: const Text("Accept", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('sessions')
                    .doc(sessionId)
                    .update({'status': 'active'});

                Navigator.of(dialogContext).pop();

                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmergencyVideoCallScreen(
                        contactName: blindUserName,
                        contactNumber: blindUserEmail,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ================= TRIGGER OUTGOING CALL/SESSION TO BLIND =================
  Future<void> _triggerFamilyCall(bool isEmergency) async {
    if (blindUserId.isEmpty || currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No linked blind user found")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('sessions').add({
        'familyMemberId': currentUid,
        'blindUserId': blindUserId,
        'sender': 'family',
        'status': 'ringing',
        'type': isEmergency ? 'emergency' : 'call',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 📌 Log to Sub-collections
      await _logFamilyAction(
        actionType: isEmergency ? 'emergency_sos' : 'call',
        details: isEmergency
            ? 'Emergency SOS call initiated by Family'
            : 'Video Call initiated by Family',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isEmergency
                ? EmergencyVideoCallScreen(
              contactName: blindUserName,
              contactNumber: blindUserEmail,
            )
                : CallBlind(
              contactName: blindUserName,
              contactNumber: blindUserEmail,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error triggering call session: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to start call: $e")),
        );
      }
    }
  }

  void _startLiveTrackingStream(String blindId) {
    _blindUserSubscription = FirebaseFirestore.instance
        .collection('blind')
        .doc(blindId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (data.containsKey('live_location') && data['live_location'] != null) {
          var locationData = data['live_location'];
          double lat = (locationData['latitude'] as num).toDouble();
          double lng = (locationData['longitude'] as num).toDouble();
          Timestamp? ts = locationData['last_updated'];

          setState(() {
            latitude = lat;
            longitude = lng;
            if (ts != null) {
              DateTime dt = ts.toDate();
              lastSeen = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
            } else {
              lastSeen = "Just now";
            }

            _markers = {
              Marker(
                markerId: MarkerId(blindId),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(title: blindUserName, snippet: currentAddress),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              )
            };
          });

          await _convertCoordinatesToAddress(lat, lng);
        } else {
          setState(() {
            currentAddress = "Location updates not started yet";
            lastSeen = "Offline";
          });
        }
      }
      setState(() => isLoading = false);
    });
  }

  Future<void> _convertCoordinatesToAddress(double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        String address = "${placemarks[0].subLocality ?? ''}, ${placemarks[0].locality ?? ''}";
        setState(() {
          currentAddress = address.trim().isNotEmpty ? address : "Current Location Available";
        });
      }
    } catch (e) {
      setState(() => currentAddress = "Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}");
    }
  }

  // ================= GOOGLE MAP MODAL SHEET =================
  void _openLiveMapModal() {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Live location coordinates not available yet")),
      );
      return;
    }

    _mapController = Completer();

    // 📌 Log Location View to Sub-collections
    _logFamilyAction(
      actionType: 'view_location',
      details: 'Family viewed live location ($currentAddress)',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: const BoxDecoration(
            color: Color(0xFF150222),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$blindUserName's Live Location",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude!, longitude!),
                      zoom: 16.0,
                    ),
                    markers: _markers,
                    mapType: MapType.normal,
                    myLocationEnabled: false,
                    zoomControlsEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.push(context, MaterialPageRoute(builder: (context) => _screens[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Family Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 22),
              onPressed: () async {
                bool? refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FamilyAddContactScreen()),
                );
                if (refresh == true) {
                  _fetchLinkedBlindUser();
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0213), Color(0xFF26023C), Color(0xFF3F0B47), Color(0xFF0D0213)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Enhanced Glassmorphic Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.14),
                      Colors.white.withOpacity(0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: -2,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.purpleAccent.withOpacity(0.6), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.purple.shade900.withOpacity(0.5),
                            child: const Icon(Icons.person, color: Colors.white, size: 36),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF26023C), width: 2.5),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blindUserName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_filled_rounded,
                                    color: Colors.greenAccent.shade400, size: 13),
                                const SizedBox(width: 6),
                                Text(
                                  "Last Active: $lastSeen",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(Icons.flash_on_rounded, color: Colors.purpleAccent, size: 20),
                ],
              ),
              const SizedBox(height: 16),

              // Action 1: View Live Location
              _buildActionTile(
                icon: Icons.map_rounded,
                iconColor: Colors.lightBlueAccent,
                title: "View Live Location",
                subtitle: currentAddress,
                onTap: _openLiveMapModal,
              ),

              const SizedBox(height: 14),

              // Action 2: Video Call Blind User (Updated for Video Call)
              _buildActionTile(
                icon: Icons.videocam_rounded,
                iconColor: Colors.tealAccent.shade400,
                title: "Start Video Call",
                subtitle: "Connect via video for visual assistance",
                onTap: () => _triggerFamilyCall(false),
              ),

              const SizedBox(height: 14),

              // Action 3: Emergency SOS Call (Highlighted for Emergency)
              _buildActionTile(
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.redAccent,
                title: "Trigger Emergency SOS",
                subtitle: "High-priority emergency video ring",
                isEmergency: true,
                onTap: () => _triggerFamilyCall(true),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0118),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomBarButton(icon: Icons.history_rounded, label: "History", isSelected: _selectedIndex == 0, onTap: () => _onNavItemTapped(0), vsync: this),
            BottomBarButton(icon: Icons.notifications_rounded, label: "Notifications", isSelected: _selectedIndex == 1, onTap: () => _onNavItemTapped(1), vsync: this),
            BottomBarButton(icon: Icons.settings_rounded, label: "Settings", isSelected: _selectedIndex == 2, onTap: () => _onNavItemTapped(2), vsync: this),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isEmergency = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEmergency
            ? Colors.redAccent.withOpacity(0.08)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isEmergency
              ? Colors.redAccent.withOpacity(0.35)
              : Colors.white.withOpacity(0.12),
          width: isEmergency ? 1.5 : 1.0,
        ),
        boxShadow: isEmergency
            ? [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isEmergency ? Colors.redAccent.shade100 : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isEmergency ? Colors.redAccent.withOpacity(0.6) : Colors.white30,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// BottomBarButton Class
class BottomBarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final TickerProvider vsync;

  const BottomBarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.vsync,
  });

  @override
  State<BottomBarButton> createState() => _BottomBarButtonState();
}

class _BottomBarButtonState extends State<BottomBarButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: widget.vsync, duration: const Duration(milliseconds: 250));
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    if (widget.isSelected) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BottomBarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? Colors.purpleAccent : Colors.white54;
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}