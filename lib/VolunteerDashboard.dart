

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  String _volunteerName = "Volunteer Name";
  File? _profileImage;
  String? _profileImageUrl;
  bool _isOnline = true;

  // Stats Counters
  int _callsAssisted = 0;
  double _rating = 5.0;
  String _badge = "Beginner..";

  ThemeOption themeOption = ThemeOption.Default;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Load local cache & connect Live Firestore Stream
  /// Load local cache & connect Live Firestore Stream
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Initial Cache Load
    if (mounted) {
      setState(() {
        _volunteerName = prefs.getString("name") ?? "Volunteer";
        final imagePath = prefs.getString("profileImage");
        if (imagePath != null && imagePath.isNotEmpty) {
          _profileImage = File(imagePath);
        }
      });
    }

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null && uid.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('volunteer')
          .doc(uid)
          .snapshots()
          .listen((doc) {
        if (!mounted || !doc.exists) return;
        final data = doc.data();
        if (data == null) return;

        // Fetch dynamic name from Firestore fields or Firebase Auth profile
        final String registeredName = data['userName'] ??
            data['name'] ??
            data['fullName'] ??
            user?.displayName ??
            'Volunteer';

        setState(() {
          _volunteerName = registeredName;
          _profileImageUrl = data['profileImage'] ?? data['imageUrl'] ?? user?.photoURL;
          _isOnline = data['isOnline'] ?? true;
          _callsAssisted = data['callsAssisted'] ?? data['totalCalls'] ?? 0;
          _rating = (data['rating'] is num) ? (data['rating'] as num).toDouble() : 5.0;
          _badge = data['badge'] ?? "Beginner";
        });

        // Sync fetched registered name locally
        prefs.setString("name", registeredName);
      });
    }
  }

  ImageProvider _getAvatarImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    } else {
      return const NetworkImage("https://via.placeholder.com/150");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF130924), // Dark purple theme background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- TOP USER CARD ----------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1333),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    // Profile Avatar with Neon Ring
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.purpleAccent, Colors.deepPurple],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: _getAvatarImage(),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name and Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back 👋",
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _volunteerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // ONLINE Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? Colors.teal.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isOnline ? Colors.tealAccent : Colors.redAccent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: _isOnline ? Colors.tealAccent : Colors.redAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isOnline ? "ONLINE" : "OFFLINE",
                            style: TextStyle(
                              color: _isOnline ? Colors.tealAccent : Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ---------------- STATS ROW (3 CARDS) ----------------
              Row(
                children: [
                  _buildStatCard(
                    icon: Icons.videocam_outlined,
                    iconColor: Colors.cyanAccent,
                    value: '$_callsAssisted Calls',
                    label: 'Assisted',
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amberAccent,
                    value: '$_rating ★',
                    label: 'Rating',
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    icon: Icons.security_rounded,
                    iconColor: Colors.orangeAccent,
                    value: _badge,
                    label: 'Badge',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ---------------- SECTION HEADING ----------------
              const Text(
                "Dashboard Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- MENU TILES GRID ----------------
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.92,
                children: [
                  // 1. Call Screen
                  _buildMenuTile(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9900), Color(0xFFFF5500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.videocam,
                    title: "Call Screen",
                    subtitle: "Active Session",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CallScreen()),
                    ),
                  ),

                  // 2. History
                  _buildMenuTile(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.history,
                    title: "History",
                    subtitle: "Support Logs",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VolunteerHistoryScreen()),
                    ),
                  ),

                  // 3. Edit Profile
                  _buildMenuTile(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.person,
                    title: "Edit Profile",
                    subtitle: "Update Info",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ).then((_) => _loadProfileData()),
                  ),

                  // 4. Notifications
                  _buildMenuTile(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.notifications,
                    title: "Notifications",
                    subtitle: "Alerts",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationFeaturesScreen(userId: currentUid),
                      ),
                    ),
                  ),

                  // 5. Settings
                  _buildMenuTile(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.settings,
                    title: "Settings",
                    subtitle: "Preferences",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VolunteerSettingsPage(
                          themeOption: themeOption,
                          onThemeChanged: (_) {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Stat Box Widget
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1333),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  /// Dashboard Custom Menu Card Widget
  Widget _buildMenuTile({
    required LinearGradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circular Frosted Icon Holder
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
//
//   // ================= CALL LOG =================
//   Future<void> _storeCallRequest(String sessionId) async {
//     if (currentVolunteerId == null) return;
//
//     await FirebaseFirestore.instance
//         .collection('volunteer')
//         .doc(currentVolunteerId)
//         .collection('call')
//         .add({
//       'sessionId': sessionId,
//       'status': 'accepted',
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
//
//   // ================= HISTORY LOG =================
//   Future<void> _storeHistory(String sessionId) async {
//     if (currentVolunteerId == null) return;
//
//     await FirebaseFirestore.instance
//         .collection('volunteer')
//         .doc(currentVolunteerId)
//         .collection('volHistory')
//         .add({
//       'sessionId': sessionId,
//       'action': 'Volunteer Accepted Call',
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
//
//   // ================= NOTIFICATION LOG =================
//   Future<void> _storeNotification(String sessionId) async {
//     if (currentVolunteerId == null) return;
//
//     await FirebaseFirestore.instance
//         .collection('volunteer')
//         .doc(currentVolunteerId)
//         .collection('notifications')
//         .add({
//       'title': 'New Blind Call Connected',
//       'sessionId': sessionId,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
// // ================= ACCEPT REQUEST =================
//   Future<void> _acceptRequest(String requestId, String blindUserId) async {
//     if (currentVolunteerId == null) return;
//
//     try {
//       // 1️⃣ Update request status
//       await FirebaseFirestore.instance
//           .collection('requests')
//           .doc(requestId)
//           .update({
//         'status': 'accepted',
//         'volunteerId': currentVolunteerId,
//         'acceptedAt': FieldValue.serverTimestamp(),
//       });
//
//       print("✅ Request accepted: $requestId");
//
//       // 2️⃣ Create session (Blind user ka CallVolunteerScreen banayega)
//       DocumentReference sessionDoc =
//       await FirebaseFirestore.instance.collection('sessions').add({
//         'userId': blindUserId,
//         'volunteerId': currentVolunteerId,
//         'status': 'waiting',
//         'requestId': requestId,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       String sessionId = sessionDoc.id;
//       print("✅ Session created: $sessionId");
//
//       // 3️⃣ Store call log
//       await _storeCallRequest(sessionId);
//       await _storeHistory(sessionId);
//       await _storeNotification(sessionId);
//
//       // 4️⃣ Go to call screen
//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CallScreen(
//               sessionId: sessionId,
//               contactName: blindUserId,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       print("❌ Accept Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
// // ================= REJECT REQUEST =================
//   Future<void> _rejectRequest(String requestId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('requests')
//           .doc(requestId)
//           .update({
//         'status': 'rejected',
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
//           ),
//         );
//       }
//     } catch (e) {
//       print("❌ Reject Error: $e");
//     }
//   }
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
//
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
//                         backgroundImage: _profileImage != null
//                             ? FileImage(_profileImage!)
//                             : const NetworkImage(
//                             "https://via.placeholder.com/150"),
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
//                   child: Column(
//                     children: [
//
//                       // ---------- GRID ----------
//                       Expanded(
//                         flex: 2,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: GridView.count(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 14,
//                             mainAxisSpacing: 14,
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
//
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
//                                        NotificationFeaturesScreen(
//                                         userId: FirebaseAuth.instance.currentUser?.uid ?? '',
//                                       ),
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
//
//                                   await _storeSettings();
//
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => VolunteerSettingsPage(
//                                         themeOption: themeOption,
//                                         onThemeChanged: (value) {
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
//                       ),
//
//                       // ---------- LIVE REQUESTS ----------
//                       Expanded(
//                         flex: 2,
//                         child: StreamBuilder(
//                           // ✅ REQUESTS se pending requests show karo
//                           // ✅ REQUEST LAYER - Listen for pending requests
//                             stream: FirebaseFirestore.instance
//                                 .collection('requests')
//                                 .where('status', isEqualTo: 'pending')
//                                 .snapshots(),
//
//                             builder: (context, snapshot) {
//                               if (!snapshot.hasData) {
//                                 return const Center(
//                                   child: CircularProgressIndicator(color: Colors.white),
//                                 );
//                               }
//
//                               var docs = snapshot.data!.docs;
//
//                               if (docs.isEmpty) {
//                                 return const Center(
//                                   child: Text(
//                                     "No Pending Requests..",
//                                     style: TextStyle(color: Colors.white, fontSize: 16),
//                                   ),
//                                 );
//                               }
//
//                               return ListView.builder(
//                                 itemCount: docs.length,
//                                 itemBuilder: (context, index) {
//                                   var requestData = docs[index];
//                                   String requestId = docs[index].id;
//                                   String blindUserId = requestData['userId'] ?? "User";
//
//                                   return Card(
//                                     color: Colors.white.withOpacity(0.1),
//                                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                     child: ListTile(
//                                       leading: const CircleAvatar(
//                                         backgroundColor: Colors.orange,
//                                         child: Icon(Icons.person, color: Colors.white),
//                                       ),
//                                       title: Text(
//                                         blindUserId,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       subtitle: const Text(
//                                         "🔴 Requesting Help",
//                                         style: TextStyle(color: Colors.white70),
//                                       ),
//                                       trailing: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           // ================= ACCEPT BUTTON =================
//                                           ElevatedButton.icon(
//                                             icon: const Icon(Icons.call),
//                                             label: const Text("Accept"),
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.green,
//                                             ),
//                                             onPressed: () async {
//                                               await _acceptRequest(
//                                                 requestId,
//                                                 blindUserId,
//                                               );
//                                             },
//                                           ),
//                                           const SizedBox(width: 8),
//                                           // ================= REJECT BUTTON =================
//                                           ElevatedButton.icon(
//                                             icon: const Icon(Icons.close),
//                                             label: const Text("Reject"),
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.red,
//                                             ),
//                                             onPressed: () async {
//                                               await _rejectRequest(requestId);
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             }
//                         ),
//                       ),
//                     ],
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
//
//   late AnimationController _controller;
//   late Animation<double> _fade;
//   late Animation<double> _scale;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//
//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//
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
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: widget.gradient,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: InkWell(
//             onTap: widget.onTap,
//             borderRadius: BorderRadius.circular(20),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(widget.icon, color: Colors.white, size: 35),
//
//                   const SizedBox(height: 10),
//
//                   Text(
//                     widget.title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//
//                   if (widget.subtitle.isNotEmpty)
//                     Text(
//                       widget.subtitle,
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 12,
//                       ),
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