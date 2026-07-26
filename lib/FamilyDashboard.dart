//
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geocoding/geocoding.dart';
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
//   String blindUserNumber = "";
//   String blindUserId = "";
//   String lastSeen = "Fetching...";
//   String currentAddress = "Waiting for blind user's location...";
//   double? latitude;
//   double? longitude;
//   bool isLoading = true;
//
//   int _selectedIndex = 0;
//   StreamSubscription? _blindUserSubscription;
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
//   }
//
//   @override
//   void dispose() {
//     _blindUserSubscription?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _fetchLinkedBlindUser() async {
//     if (currentUid == null) return;
//     try {
//       final connectionSnapshot = await FirebaseFirestore.instance
//           .collection('connections')
//           .where('familyMemberId', isEqualTo: currentUid)
//           .where('status', isEqualTo: 'accepted')
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
//         // ✅ FIXED: Changed collection path from 'users' to 'blind'
//         final userDoc = await FirebaseFirestore.instance
//             .collection('blind')
//             .doc(targetBlindId)
//             .get();
//
//         if (userDoc.exists) {
//           setState(() {
//             blindUserName = userDoc.data()?['name'] ?? "Unknown Blind User";
//             blindUserNumber = userDoc.data()?['phone'] ?? "";
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
//   void _startLiveTrackingStream(String blindId) {
//     // ✅ FIXED: Changed collection stream from 'users' to 'blind'
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
//           });
//
//           await _convertCoordinatesToAddress(lat, lng);
//         } else {
//           // ✅ FIXED: If 'live_location' is missing, clear the loading loop
//           setState(() {
//             latitude = 0.0;
//             longitude = 0.0;
//             currentAddress = "Location updates not started yet";
//             lastSeen = "Offline";
//           });
//         }
//       } else {
//         setState(() {
//           latitude = 0.0;
//           longitude = 0.0;
//           currentAddress = "Blind profile reference error";
//           lastSeen = "Offline";
//         });
//       }
//       setState(() => isLoading = false);
//     }, onError: (error) {
//       debugPrint("Stream error: $error");
//       setState(() => isLoading = false);
//     });
//   }
//
//   Future<void> _convertCoordinatesToAddress(double lat, double lng) async {
//     if (lat == 0.0 && lng == 0.0) {
//       setState(() => currentAddress = "Location updates not started yet");
//       return;
//     }
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
//       if (placemarks.isNotEmpty) {
//         String address = "${placemarks[0].subLocality ?? ''}, ${placemarks[0].locality ?? ''}";
//         setState(() {
//           currentAddress = address.trim().isNotEmpty ? address : "Current Location";
//         });
//       }
//     } catch (e) {
//       setState(() => currentAddress = "Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}");
//     }
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
//         title: const Text("Family Dashboard", style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white, size: 28),
//             onPressed: () async {
//               bool? refresh = await Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const FamilyAddContactScreen()),
//               );
//
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
//             colors: [Color(0xFF0B0211), Color(0xFF2E0249), Color(0xFF570A57), Color(0xFF0B0211)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: SafeArea(
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator(color: Colors.white))
//               : Column(
//             children: [
//               Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 30,
//                     backgroundImage: AssetImage('assets/profile_placeholder.png'),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         blindUserName,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//                       ),
//                       Text("Last seen: $lastSeen", style: const TextStyle(color: Colors.white70)),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: Colors.white.withOpacity(0.1)),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         size: 60,
//                         // ✅ FIXED: Gray icon will show if location data is actual 0.0/null
//                         color: (latitude == null || latitude == 0.0) ? Colors.grey : Colors.redAccent,
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         "$blindUserName's Live Location",
//                         style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       // ✅ FIXED: Stops endless loading indicator loop if coordinates are uninitialized
//                       if (latitude == null && currentAddress == "Waiting for blind user's location...")
//                         const CircularProgressIndicator(color: Colors.white)
//                       else
//                         Text(
//                           currentAddress,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(color: Colors.white70, fontSize: 16),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: _buildGlassButton(
//                       color: Colors.red,
//                       icon: Icons.sos,
//                       label: "Emergency",
//                       screen: EmergencyVideoCallScreen(
//                         contactName: blindUserName,
//                         contactNumber: blindUserNumber,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _buildGlassButton(
//                       color: Colors.blue,
//                       icon: Icons.call,
//                       label: "Call",
//                       screen: CallBlind(
//                         contactName: blindUserName,
//                         contactNumber: blindUserNumber,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(colors: [Colors.black, Color(0xFF4A148C)]),
//           boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, -2))],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             BottomBarButton(
//               icon: Icons.history,
//               label: "History",
//               isSelected: _selectedIndex == 0,
//               onTap: () => _onNavItemTapped(0),
//               vsync: this,
//             ),
//             BottomBarButton(
//               icon: Icons.notifications,
//               label: "Notifications",
//               isSelected: _selectedIndex == 1,
//               onTap: () => _onNavItemTapped(1),
//               vsync: this,
//             ),
//             BottomBarButton(
//               icon: Icons.settings,
//               label: "Settings",
//               isSelected: _selectedIndex == 2,
//               onTap: () => _onNavItemTapped(2),
//               vsync: this,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGlassButton({
//     required Color color,
//     required IconData icon,
//     required String label,
//     required Widget screen,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         if (blindUserNumber.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Contact number not available")),
//           );
//           return;
//         }
//         Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
//       },
//       child: Container(
//         height: 60,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: LinearGradient(colors: [color.withOpacity(0.4), color.withOpacity(0.2)]),
//           border: Border.all(color: color.withOpacity(0.5), width: 1.5),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: Colors.white, size: 26),
//             const SizedBox(height: 2),
//             Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
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
  String blindUserNumber = "";
  String blindUserId = "";
  String lastSeen = "Fetching...";
  String currentAddress = "Waiting for blind user's location...";

  double? latitude;
  double? longitude;
  bool isLoading = true;

  int _selectedIndex = 0;
  StreamSubscription? _blindUserSubscription;

  // Google Map
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
  }

  @override
  void dispose() {
    _blindUserSubscription?.cancel();
    super.dispose();
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
            blindUserNumber = userDoc.data()?['phone'] ?? "";
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

          // Animate Camera
          if (_mapController.isCompleted) {
            final controller = await _mapController.future;
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(lat, lng), zoom: 15.0),
              ),
            );
          }

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
          currentAddress = address.trim().isNotEmpty ? address : "Current Location";
        });
      }
    } catch (e) {
      setState(() => currentAddress = "Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}");
    }
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
        title: const Text("Family Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
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
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0211), Color(0xFF2E0249), Color(0xFF570A57), Color(0xFF0B0211)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blindUserName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text("Last seen: $lastSeen", style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (latitude == null || latitude == 0.0)
                      ? Container(
                    color: Colors.white.withOpacity(0.05),
                    child: const Center(
                      child: Text(
                        "Awaiting Live Location Coordinates...",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                      : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude!, longitude!),
                      zoom: 15.0,
                    ),
                    markers: _markers,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  currentAddress,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildGlassButton(
                      color: Colors.red,
                      icon: Icons.sos,
                      label: "Emergency",
                      screen: EmergencyVideoCallScreen(
                        contactName: blindUserName,
                        contactNumber: blindUserNumber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildGlassButton(
                      color: Colors.blue,
                      icon: Icons.call,
                      label: "Call",
                      screen: CallBlind(
                        contactName: blindUserName,
                        contactNumber: blindUserNumber,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.black, Color(0xFF4A148C)]),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomBarButton(icon: Icons.history, label: "History", isSelected: _selectedIndex == 0, onTap: () => _onNavItemTapped(0), vsync: this),
            BottomBarButton(icon: Icons.notifications, label: "Notifications", isSelected: _selectedIndex == 1, onTap: () => _onNavItemTapped(1), vsync: this),
            BottomBarButton(icon: Icons.settings, label: "Settings", isSelected: _selectedIndex == 2, onTap: () => _onNavItemTapped(2), vsync: this),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required Color color,
    required IconData icon,
    required String label,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        if (blindUserNumber.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contact number not available")),
          );
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: [color.withOpacity(0.4), color.withOpacity(0.2)]),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
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
    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
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
    final color = widget.isSelected ? Colors.purpleAccent : Colors.white70;
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}