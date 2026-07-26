//
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'CallScreen.dart';
// import 'EditProfileScreen.dart';
// import 'VolunteerSettingsPage.dart';
// import 'VolunteerHistoryScreen.dart';
// import 'NotificationFeaturesScreen.dart';
//
// enum ThemeOption { Default, Light, Dark }
//
// class VolunteerDashboard extends StatefulWidget {
//   const VolunteerDashboard({Key? key}) : super(key: key);
//
//   @override
//   State<VolunteerDashboard> createState() => _VolunteerDashboardState();
// }
//
// class _VolunteerDashboardState extends State<VolunteerDashboard>
//     with SingleTickerProviderStateMixin {
//
//   String _volunteerName = "Volunteer Name";
//   File? _profileImage;
//
//   late AnimationController _bgController;
//   late Animation<double> _bgFade;
//
//   ThemeOption themeOption = ThemeOption.Default;
//
//   // ================= CURRENT VOLUNTEER ID =================
//   String? get currentVolunteerId =>
//       FirebaseAuth.instance.currentUser?.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfileData();
//
//     _bgController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//
//     _bgFade =
//         CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
//
//     _bgController.forward();
//   }
//
//   Future<void> _loadProfileData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _volunteerName = prefs.getString("name") ?? "Volunteer Name";
//       final imagePath = prefs.getString("profileImage");
//       if (imagePath != null && imagePath.isNotEmpty) {
//         _profileImage = File(imagePath);
//       }
//     });
//   }
//
//   // ================= ACCEPT REQUEST =================
//   Future<void> _acceptRequest(String requestId, String blindUserId) async {
//     if (currentVolunteerId == null) return;
//
//     try {
//       print('🟡 Starting accept request for: $requestId');
//
//       // 1️⃣ Create session FIRST
//       DocumentReference sessionDoc =
//       await FirebaseFirestore.instance.collection('sessions').add({
//         'userId': blindUserId,
//         'volunteerId': currentVolunteerId,
//         'volunteerName': _volunteerName,
//         'status': 'waiting', // Waiting for blind user to send offer
//         'requestId': requestId,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       String sessionId = sessionDoc.id;
//       print('✅ Session created: $sessionId');
//
//       // 2️⃣ Update request with session ID AND accepted status
//       await FirebaseFirestore.instance
//           .collection('requests')
//           .doc(requestId)
//           .update({
//         'status': 'accepted',
//         'volunteerId': currentVolunteerId,
//         'sessionId': sessionId,
//         'acceptedAt': FieldValue.serverTimestamp(),
//       });
//
//       print('✅ Request updated with session: $sessionId');
//
//       // 3️⃣ Store call log
//       await FirebaseFirestore.instance
//           .collection('volunteer')
//           .doc(currentVolunteerId)
//           .collection('call')
//           .add({
//         'sessionId': sessionId,
//         'requestId': requestId,
//         'blindUserId': blindUserId,
//         'status': 'accepted',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       // 4️⃣ Store history log
//       await FirebaseFirestore.instance
//           .collection('volunteer')
//           .doc(currentVolunteerId)
//           .collection('volHistory')
//           .add({
//         'sessionId': sessionId,
//         'requestId': requestId,
//         'action': 'Request Accepted',
//         'blindUserId': blindUserId,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       // 5️⃣ Store notification
//       await FirebaseFirestore.instance
//           .collection('volunteer')
//           .doc(currentVolunteerId)
//           .collection('notifications')
//           .add({
//         'title': 'New Call Connected',
//         'message': 'Call from $blindUserId',
//         'sessionId': sessionId,
//         'type': 'call_accepted',
//         'read': false,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       print('✅ All logs stored');
//
//       // 6️⃣ Navigate to call screen with correct arguments
//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CallScreen(
//               sessionId: sessionId,
//               volunteerId: currentVolunteerId,
//               userType: 'volunteer',
//               contactName: blindUserId,
//             ),
//           ),
//         );
//       }
//
//       print('✅ Navigated to call screen');
//
//     } catch (e) {
//       print("❌ Accept Error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: $e"),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }
//
//   // ================= REJECT REQUEST =================
//   Future<void> _rejectRequest(String requestId) async {
//     try {
//       print('🔴 Rejecting request: $requestId');
//
//       await FirebaseFirestore.instance
//           .collection('requests')
//           .doc(requestId)
//           .update({
//         'status': 'rejected',
//         'rejectedBy': currentVolunteerId,
//         'rejectedAt': FieldValue.serverTimestamp(),
//       });
//
//       print("✅ Request rejected: $requestId");
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Request rejected"),
//             backgroundColor: Colors.orange,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       print("❌ Reject Error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   // ================= SETTINGS =================
//   Future<void> _storeSettings() async {
//     if (currentVolunteerId == null) return;
//
//     final settingsRef = FirebaseFirestore.instance
//         .collection('volunteer')
//         .doc(currentVolunteerId)
//         .collection('settings')
//         .doc('default');
//
//     final doc = await settingsRef.get();
//
//     if (!doc.exists) {
//       await settingsRef.set({
//         'theme': 'dark',
//         'notifications': true,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }
//   }
//
//   // ================= EDIT PROFILE LOG =================
//   Future<void> _storeEditProfile() async {
//     if (currentVolunteerId == null) return;
//
//     await FirebaseFirestore.instance
//         .collection('volunteer')
//         .doc(currentVolunteerId)
//         .collection('editProfile')
//         .add({
//       'action': 'Profile Opened',
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
//
//   @override
//   void dispose() {
//     _bgController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FadeTransition(
//         opacity: _bgFade,
//         child: Container(
//           decoration: const BoxDecoration(
//             // Original Background Purple Gradient Restored
//             gradient: LinearGradient(
//               colors: [
//                 Colors.black,
//                 Color(0xFF2D0A4E),
//                 Color(0xFF5E2B97),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: SafeArea(
//             child: Column(
//               children: [
//
//                 // ================= HEADER =================
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 14),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 26,
//                         backgroundColor: Colors.white24,
//                         backgroundImage:
//                         _profileImage != null ? FileImage(_profileImage!) : null,
//                         child: _profileImage == null
//                             ? const Icon(Icons.person, color: Colors.white)
//                             : null,
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Welcome,",
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                           Text(
//                             _volunteerName,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // ================= BODY =================
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//
//                         // ---------- ORIGINAL COLORFUL GRID ----------
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: GridView.count(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 14,
//                             mainAxisSpacing: 14,
//                             childAspectRatio: 1.1,
//                             children: [
//
//                               AnimatedTile(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Colors.orange.shade800,
//                                     Colors.orange
//                                   ],
//                                 ),
//                                 icon: Icons.call,
//                                 title: "Call",
//                                 subtitle: "Requests",
//                                 delay: 200,
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => const CallScreen(),
//                                     ),
//                                   );
//                                 },
//                               ),
//
//                               AnimatedTile(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Colors.purple.shade800,
//                                     Colors.purple
//                                   ],
//                                 ),
//                                 icon: Icons.history,
//                                 title: "History",
//                                 subtitle: "Logs",
//                                 delay: 300,
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) =>
//                                       const VolunteerHistoryScreen(),
//                                     ),
//                                   );
//                                 },
//                               ),
//
//                               AnimatedTile(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Colors.blue.shade800,
//                                     Colors.blue
//                                   ],
//                                 ),
//                                 icon: Icons.person,
//                                 title: "Edit Profile",
//                                 subtitle: "",
//                                 delay: 500,
//                                 onTap: () async {
//                                   await _storeEditProfile();
//
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) =>
//                                       const EditProfileScreen(),
//                                     ),
//                                   );
//                                 },
//                               ),
//
//                               AnimatedTile(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Colors.amber.shade800,
//                                     Colors.amber
//                                   ],
//                                 ),
//                                 icon: Icons.notifications,
//                                 title: "Notifications",
//                                 subtitle: "",
//                                 delay: 600,
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) =>
//                                       const NotificationFeaturesScreen(),
//                                     ),
//                                   );
//                                 },
//                               ),
//
//                               AnimatedTile(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Colors.deepPurple.shade800,
//                                     Colors.deepPurple
//                                   ],
//                                 ),
//                                 icon: Icons.settings,
//                                 title: "Settings",
//                                 subtitle: "",
//                                 delay: 700,
//                                 onTap: () async {
//                                   await _storeSettings();
//
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => VolunteerSettingsPage(
//                                         themeOption: themeOption,
//                                         onThemeChanged: (ThemeOption value) {
//                                           setState(() {
//                                             themeOption = value;
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 20),
//
//                         // ---------- LIVE REQUESTS (Restored Glass Container Layout) ----------
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           child: Text(
//                             "Pending Requests",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//
//                         StreamBuilder<QuerySnapshot>(
//                           stream: FirebaseFirestore.instance
//                               .collection('requests')
//                               .snapshots(),
//                           builder: (context, snapshot) {
//                             if (snapshot.hasError) {
//                               return const Center(
//                                 child: Padding(
//                                   padding: EdgeInsets.all(16.0),
//                                   child: Text("Error loading requests", style: TextStyle(color: Colors.redAccent)),
//                                 ),
//                               );
//                             }
//
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return const Center(
//                                 child: Padding(
//                                   padding: EdgeInsets.all(24.0),
//                                   child: CircularProgressIndicator(color: Colors.white),
//                                 ),
//                               );
//                             }
//
//                             var allDocs = snapshot.data?.docs ?? [];
//
//                             var docs = allDocs.where((doc) {
//                               var data = doc.data() as Map<String, dynamic>?;
//                               String status = data?['status']?.toString().toLowerCase().trim() ?? '';
//                               return status == 'pending' || status == '';
//                             }).toList();
//
//                             if (docs.isEmpty) {
//                               return Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                                 child: Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.all(24),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.08),
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   child: const Column(
//                                     children: [
//                                       Icon(Icons.inbox, size: 44, color: Colors.white38),
//                                       SizedBox(height: 8),
//                                       Text(
//                                         "No Pending Requests",
//                                         style: TextStyle(color: Colors.white70, fontSize: 15),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }
//
//                             return ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: docs.length,
//                               itemBuilder: (context, index) {
//                                 Map<String, dynamic> requestData =
//                                 docs[index].data() as Map<String, dynamic>;
//
//                                 String requestId = docs[index].id;
//                                 String blindUserId = requestData['userId']?.toString() ?? "Blind User";
//                                 String priority = requestData['priority']?.toString() ?? 'normal';
//
//                                 return Card(
//                                   color: Colors.white.withOpacity(0.12),
//                                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                                   child: ListTile(
//                                     leading: CircleAvatar(
//                                       backgroundColor: priority == 'high' ? Colors.redAccent : Colors.orangeAccent,
//                                       child: const Icon(Icons.person, color: Colors.white),
//                                     ),
//                                     title: Text(
//                                       blindUserId,
//                                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                     ),
//                                     subtitle: Text(
//                                       "Status: ${requestData['status'] ?? 'pending'}",
//                                       style: const TextStyle(color: Colors.white70),
//                                     ),
//                                     trailing: ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.green,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                       ),
//                                       onPressed: () => _acceptRequest(requestId, blindUserId),
//                                       child: const Text("Accept", style: TextStyle(color: Colors.white)),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 24),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ================= ORIGINAL ANIMATED TILE WIDGET =================
// class AnimatedTile extends StatefulWidget {
//   final LinearGradient gradient;
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;
//   final int delay;
//
//   const AnimatedTile({
//     Key? key,
//     required this.gradient,
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//     required this.delay,
//   }) : super(key: key);
//
//   @override
//   State<AnimatedTile> createState() => _AnimatedTileState();
// }
//
// class _AnimatedTileState extends State<AnimatedTile> {
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: widget.onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: widget.gradient,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             )
//           ],
//         ),
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(widget.icon, size: 36, color: Colors.white),
//             const SizedBox(height: 8),
//             Text(
//               widget.title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15,
//               ),
//             ),
//             if (widget.subtitle.isNotEmpty)
//               Text(
//                 widget.subtitle,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CallScreen.dart';
import 'EditProfileScreen.dart';
import 'VolunteerSettingsPage.dart';
import 'VolunteerHistoryScreen.dart';
import 'NotificationFeaturesScreen.dart';

enum ThemeOption { Default, Light, Dark }

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({Key? key}) : super(key: key);

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard>
    with SingleTickerProviderStateMixin {
  String _volunteerName = "Volunteer Name";
  File? _profileImage;
  bool _isOnline = true;

  late AnimationController _bgController;
  late Animation<double> _bgFade;

  // ================= CURRENT VOLUNTEER ID =================
  String? get currentVolunteerId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadProfileData();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bgFade = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
    _bgController.forward();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _volunteerName = prefs.getString("name") ?? "Volunteer Name";
      final imagePath = prefs.getString("profileImage");
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
    });
  }

  // ================= ACCEPT REQUEST =================
  Future<void> _acceptRequest(String requestId, String blindUserId) async {
    if (currentVolunteerId == null) return;

    try {
      debugPrint('🟡 Starting accept request for: $requestId');

      DocumentReference sessionDoc =
      await FirebaseFirestore.instance.collection('sessions').add({
        'userId': blindUserId,
        'volunteerId': currentVolunteerId,
        'volunteerName': _volunteerName,
        'status': 'waiting',
        'requestId': requestId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      String sessionId = sessionDoc.id;

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'volunteerId': currentVolunteerId,
        'sessionId': sessionId,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('volunteer')
          .doc(currentVolunteerId)
          .collection('call')
          .add({
        'sessionId': sessionId,
        'requestId': requestId,
        'blindUserId': blindUserId,
        'status': 'accepted',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('volunteer')
          .doc(currentVolunteerId)
          .collection('volHistory')
          .add({
        'sessionId': sessionId,
        'requestId': requestId,
        'action': 'Request Accepted',
        'blindUserId': blindUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('volunteer')
          .doc(currentVolunteerId)
          .collection('notifications')
          .add({
        'title': 'New Call Connected',
        'message': 'Call connected with $blindUserId',
        'sessionId': sessionId,
        'type': 'call_accepted',
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CallScreen(
              sessionId: sessionId,
              volunteerId: currentVolunteerId,
              userType: 'volunteer',
              contactName: blindUserId,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Accept Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ================= REJECT REQUEST =================
  Future<void> _rejectRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'rejected',
        'rejectedBy': currentVolunteerId,
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request declined"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Reject Error: $e");
    }
  }

  // ================= SETTINGS & PROFILE =================
  Future<void> _storeSettings() async {
    if (currentVolunteerId == null) return;
    final settingsRef = FirebaseFirestore.instance
        .collection('volunteer')
        .doc(currentVolunteerId)
        .collection('settings')
        .doc('default');

    final doc = await settingsRef.get();
    if (!doc.exists) {
      await settingsRef.set({
        'notifications': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _storeEditProfile() async {
    if (currentVolunteerId == null) return;
    await FirebaseFirestore.instance
        .collection('volunteer')
        .doc(currentVolunteerId)
        .collection('editProfile')
        .add({
      'action': 'Profile Opened',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  // ================= UI WIDGET BUILDERS =================

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.purpleAccent, width: 2),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white24,
              backgroundImage:
              _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome back 👋",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                Text(
                  _volunteerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Online / Offline Switch Toggle
          InkWell(
            onTap: () => setState(() => _isOnline = !_isOnline),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isOnline
                    ? Colors.tealAccent.withOpacity(0.15)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isOnline ? Colors.tealAccent : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: _isOnline ? Colors.tealAccent : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isOnline ? "ONLINE" : "OFFLINE",
                    style: TextStyle(
                      color: _isOnline ? Colors.tealAccent : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= LIVE STATS STREAM =================
  Widget buildQuickStatsRow() {
    if (currentVolunteerId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      // Live stream from Firestore history logs
      stream: FirebaseFirestore.instance
          .collection('volunteer')
          .doc(currentVolunteerId)
          .collection('volHistory')
          .snapshots(),
      builder: (context, snapshot) {
        int totalCalls = 0;

        if (snapshot.hasData) {
          totalCalls = snapshot.data!.docs.length;
        }

        // Dynamic Badge Logic based on real completed calls
        String badgeTitle = "Beginner";
        Color badgeColor = Colors.orangeAccent;

        if (totalCalls >= 20) {
          badgeTitle = "Pro Helper";
          badgeColor = Colors.purpleAccent;
        } else if (totalCalls >= 5) {
          badgeTitle = "Active Helper";
          badgeColor = Colors.tealAccent;
        }

        return Row(
          children: [
            Expanded(
              child: buildStatBox(
                icon: Icons.video_call_rounded,
                title: "Assisted",
                value: "$totalCalls Calls", // LIVE COUNT
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildStatBox(
                icon: Icons.star_rounded,
                title: "Rating",
                value: "5.0 ★",
                color: Colors.amberAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildStatBox(
                icon: Icons.shield_rounded,
                title: "Badge",
                value: badgeTitle, // DYNAMIC BADGE
                color: badgeColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildStatBox({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _bgFade,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F051D),
                Color(0xFF23083B),
                Color(0xFF43166B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ================= HEADER =================
                  buildHeader(),

                  const SizedBox(height: 14),

                  // ================= LIVE STATS ROW =================
                  buildQuickStatsRow(),

                  const SizedBox(height: 18),

                  // ================= BODY =================
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------- PENDING REQUESTS SECTION ----------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Live Incoming Requests",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.live_tv,
                                        size: 12, color: Colors.redAccent),
                                    SizedBox(width: 4),
                                    Text(
                                      "LIVE",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 10),

                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('requests')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Center(
                                  child: Text("Error loading requests",
                                      style: TextStyle(color: Colors.redAccent)),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(
                                        color: Colors.purpleAccent),
                                  ),
                                );
                              }

                              var allDocs = snapshot.data?.docs ?? [];
                              var docs = allDocs.where((doc) {
                                var data = doc.data() as Map<String, dynamic>?;
                                String status = data?['status']
                                    ?.toString()
                                    .toLowerCase()
                                    .trim() ??
                                    '';
                                return status == 'pending' || status == '';
                              }).toList();

                              if (docs.isEmpty) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.08)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded,
                                          color: Colors.tealAccent, size: 22),
                                      SizedBox(width: 10),
                                      Text(
                                        "No pending requests right now",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> requestData =
                                  docs[index].data() as Map<String, dynamic>;

                                  String requestId = docs[index].id;
                                  String blindUserId =
                                      requestData['userId']?.toString() ??
                                          "Blind User";

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple.shade900.withOpacity(0.6),
                                          Colors.deepPurple.shade800
                                              .withOpacity(0.4),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: Colors.purpleAccent
                                              .withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.orangeAccent,
                                          radius: 20,
                                          child: const Icon(Icons.person,
                                              color: Colors.white, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                blindUserId,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                "Requesting live visual guidance",
                                                style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close_rounded,
                                              color: Colors.redAccent, size: 22),
                                          onPressed: () =>
                                              _rejectRequest(requestId),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            elevation: 0,
                                          ),
                                          onPressed: () => _acceptRequest(
                                              requestId, blindUserId),
                                          child: const Text("Accept",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // ---------- ACTION TILES GRID ----------
                          const Text(
                            "Dashboard Menu",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.15,
                            children: [
                              AnimatedTile(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8008), Color(0xFFFFC837)],
                                ),
                                icon: Icons.video_call_rounded,
                                title: "Call Screen",
                                subtitle: "Active Session",
                                delay: 200,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CallScreen(),
                                    ),
                                  );
                                },
                              ),
                              AnimatedTile(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                ),
                                icon: Icons.history_rounded,
                                title: "History",
                                subtitle: "Support Logs",
                                delay: 300,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const VolunteerHistoryScreen(),
                                    ),
                                  );
                                },
                              ),
                              AnimatedTile(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                                ),
                                icon: Icons.person_rounded,
                                title: "Edit Profile",
                                subtitle: "Update Info",
                                delay: 500,
                                onTap: () async {
                                  await _storeEditProfile();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const EditProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                              AnimatedTile(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF857A6), Color(0xFFFF5858)],
                                ),
                                icon: Icons.notifications_active_rounded,
                                title: "Notifications",
                                subtitle: "Alerts",
                                delay: 600,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const NotificationFeaturesScreen(),
                                    ),
                                  );
                                },
                              ),
                              AnimatedTile(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                                ),
                                icon: Icons.settings_rounded,
                                title: "Settings",
                                subtitle: "Preferences",
                                delay: 700,
                                onTap: () async {
                                  await _storeSettings();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const VolunteerSettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= ANIMATED TILE WIDGET =================
class AnimatedTile extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int delay;

  const AnimatedTile({
    Key? key,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.delay,
  }) : super(key: key);

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, size: 24, color: Colors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}