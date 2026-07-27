// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'CallScreen.dart';
// import 'EditProfileScreen.dart';
// import 'EmergencyVolunteerScreen.dart';
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
//   String _volunteerName = "Volunteer Name";
//   File? _profileImage;
//
//   late AnimationController _bgController;
//   late Animation<double> _bgFade;
//
//   ThemeOption themeOption = ThemeOption.Default;
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
//     _bgFade =
//         CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
//     _bgController.forward();
//   }
//
//   @override
//   void dispose() {
//     _bgController.dispose();
//     super.dispose();
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FadeTransition(
//         opacity: _bgFade,
//         child: Container(
//           decoration: const BoxDecoration(
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
//                 // ---------- HEADER ----------
//                 Padding(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 26,
//                         backgroundImage: _profileImage != null
//                             ? FileImage(_profileImage!)
//                             : const NetworkImage(
//                             "https://via.placeholder.com/150")
//                         as ImageProvider,
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
//                 // ---------- GRID (2 x 3) ----------
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: GridView.count(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 14,
//                       mainAxisSpacing: 14,
//                       children: [
//                         AnimatedTile(
//                           gradient: LinearGradient(
//                             colors: [Colors.orange.shade800, Colors.orange],
//                           ),
//                           icon: Icons.call,
//                           title: "Call",
//                           subtitle: "Requests",
//                           delay: 200,
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const CallScreen()),
//                           ),
//                         ),
//                         AnimatedTile(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.purple.shade800,
//                               Colors.purple
//                             ],
//                           ),
//                           icon: Icons.history,
//                           title: "History",
//                           subtitle: "Call Logs",
//                           delay: 300,
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) =>
//                                 const VolunteerHistoryScreen()),
//                           ),
//                         ),
//                         AnimatedTile(
//                           gradient: LinearGradient(
//                             colors: [Colors.red.shade800, Colors.red],
//                           ),
//                           icon: Icons.warning_amber,
//                           title: "Emergency",
//                           subtitle: "",
//                           delay: 400,
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) =>
//                                 const EmergencyVolunteerScreen()),
//                           ),
//                         ),
//                         AnimatedTile(
//                           gradient: LinearGradient(
//                             colors: [Colors.blue.shade800, Colors.blue],
//                           ),
//                           icon: Icons.person,
//                           title: "Edit Profile",
//                           subtitle: "",
//                           delay: 500,
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) =>
//                                 const EditProfileScreen()),
//                           ).then((_) => _loadProfileData()),
//                         ),
//                         AnimatedTile(
//                           gradient: LinearGradient(
//                             colors: [Colors.amber.shade800, Colors.amber],
//                           ),
//                           icon: Icons.notifications,
//                           title: "Notifications",
//                           subtitle: "",
//                           delay: 600,
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) =>
//                                 const NotificationFeaturesScreen()),
//                           ),
//                         ),
//                         AnimatedTile(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.deepPurple.shade800,
//                               Colors.deepPurple
//                             ],
//                           ),
//                           icon: Icons.settings,
//                           title: "Settings",
//                           subtitle: "",
//                           delay: 700,
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => VolunteerSettingsPage(
//                                 themeOption: themeOption,
//                                 onThemeChanged: (_) {},
//                               ),
//                             ),
//                           ),
//                         ),
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
// // ---------------- TILE (BlindDashboard style) ----------------
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
// class _AnimatedTileState extends State<AnimatedTile>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fade;
//   late Animation<double> _scale;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
//
//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//     _scale = Tween<double>(begin: 0.9, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
//     );
//
//     Future.delayed(Duration(milliseconds: widget.delay), () {
//       if (mounted) _controller.forward();
//     });
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
//     return FadeTransition(
//       opacity: _fade,
//       child: ScaleTransition(
//         scale: _scale,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(20),
//           onTap: widget.onTap,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: widget.gradient,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: widget.gradient.colors.last.withOpacity(0.4),
//                   blurRadius: 8,
//                   offset: const Offset(4, 6),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(18),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(widget.icon, size: 36, color: Colors.white),
//                   const Spacer(),
//                   Text(
//                     widget.title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   if (widget.subtitle.isNotEmpty)
//                     Text(
//                       widget.subtitle,
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                 ],
//               ),
//             ),
//           ),
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

  late AnimationController _bgController;
  late Animation<double> _bgFade;

  ThemeOption themeOption = ThemeOption.Default;

  // ================= CURRENT VOLUNTEER ID =================
  String? get currentVolunteerId =>
      FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadProfileData();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bgFade =
        CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

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


  // ================= CALL LOG =================
  Future<void> _storeCallRequest(String sessionId) async {
    if (currentVolunteerId == null) return;

    await FirebaseFirestore.instance
        .collection('volunteer')
        .doc(currentVolunteerId)
        .collection('call')
        .add({
      'sessionId': sessionId,
      'status': 'accepted',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ================= HISTORY LOG =================
  Future<void> _storeHistory(String sessionId) async {
    if (currentVolunteerId == null) return;

    await FirebaseFirestore.instance
        .collection('volunteer')
        .doc(currentVolunteerId)
        .collection('volHistory')
        .add({
      'sessionId': sessionId,
      'action': 'Volunteer Accepted Call',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ================= NOTIFICATION LOG =================
  Future<void> _storeNotification(String sessionId) async {
    if (currentVolunteerId == null) return;

    await FirebaseFirestore.instance
        .collection('volunteer')
        .doc(currentVolunteerId)
        .collection('notifications')
        .add({
      'title': 'New Blind Call Connected',
      'sessionId': sessionId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
// ================= ACCEPT REQUEST =================
  Future<void> _acceptRequest(String requestId, String blindUserId) async {
    if (currentVolunteerId == null) return;

    try {
      // 1️⃣ Update request status
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'volunteerId': currentVolunteerId,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      print("✅ Request accepted: $requestId");

      // 2️⃣ Create session (Blind user ka CallVolunteerScreen banayega)
      DocumentReference sessionDoc =
      await FirebaseFirestore.instance.collection('sessions').add({
        'userId': blindUserId,
        'volunteerId': currentVolunteerId,
        'status': 'waiting',
        'requestId': requestId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      String sessionId = sessionDoc.id;
      print("✅ Session created: $sessionId");

      // 3️⃣ Store call log
      await _storeCallRequest(sessionId);
      await _storeHistory(sessionId);
      await _storeNotification(sessionId);

      // 4️⃣ Go to call screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CallScreen(
              sessionId: sessionId,
              contactName: blindUserId,
            ),
          ),
        );
      }
    } catch (e) {
      print("❌ Accept Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      print("✅ Request rejected: $requestId");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request rejected"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("❌ Reject Error: $e");
    }
  }
  // ================= SETTINGS =================
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
        'theme': 'dark',
        'notifications': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ================= EDIT PROFILE LOG =================
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _bgFade,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Color(0xFF2D0A4E),
                Color(0xFF5E2B97),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          child: SafeArea(
            child: Column(
              children: [

                // ================= HEADER =================
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const NetworkImage(
                            "https://via.placeholder.com/150"),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome,",
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            _volunteerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ================= BODY =================
                Expanded(
                  child: Column(
                    children: [

                      // ---------- GRID ----------
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            children: [

                              AnimatedTile(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade800,
                                    Colors.orange
                                  ],
                                ),
                                icon: Icons.call,
                                title: "Call",
                                subtitle: "Requests",
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
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade800,
                                    Colors.purple
                                  ],
                                ),
                                icon: Icons.history,
                                title: "History",
                                subtitle: "Logs",
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
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade800,
                                    Colors.blue
                                  ],
                                ),
                                icon: Icons.person,
                                title: "Edit Profile",
                                subtitle: "",
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
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade800,
                                    Colors.amber
                                  ],
                                ),
                                icon: Icons.notifications,
                                title: "Notifications",
                                subtitle: "",
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
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade800,
                                    Colors.deepPurple
                                  ],
                                ),
                                icon: Icons.settings,
                                title: "Settings",
                                subtitle: "",
                                delay: 700,
                                onTap: () async {

                                  await _storeSettings();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VolunteerSettingsPage(
                                        themeOption: themeOption,
                                        onThemeChanged: (ThemeOption value) {
                                          setState(() {
                                            themeOption = value;
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ---------- LIVE REQUESTS ----------
                      Expanded(
                        flex: 2,
                        child: StreamBuilder(
                          // ✅ REQUESTS se pending requests show karo
                          // ✅ REQUEST LAYER - Listen for pending requests
                            stream: FirebaseFirestore.instance
                                .collection('requests')
                                .where('status', isEqualTo: 'pending')
                                .snapshots(),

                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                );
                              }

                              var docs = snapshot.data!.docs;

                              if (docs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No Pending Requests..",
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  var requestData = docs[index];
                                  String requestId = docs[index].id;
                                  String blindUserId = requestData['userId'] ?? "User";

                                  return Card(
                                    color: Colors.white.withOpacity(0.1),
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        child: Icon(Icons.person, color: Colors.white),
                                      ),
                                      title: Text(
                                        blindUserId,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: const Text(
                                        "🔴 Requesting Help",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // ================= ACCEPT BUTTON =================
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.call),
                                            label: const Text("Accept"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            onPressed: () async {
                                              await _acceptRequest(
                                                requestId,
                                                blindUserId,
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          // ================= REJECT BUTTON =================
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.close),
                                            label: const Text("Reject"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () async {
                                              await _rejectRequest(requestId);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class _AnimatedTileState extends State<AnimatedTile>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scale = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 35),

                  const SizedBox(height: 10),

                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (widget.subtitle.isNotEmpty)
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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