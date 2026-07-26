//
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:project/BaseScreen.dart';
// import 'EditFamilyProfileScreen.dart';
// import 'ChangePasswordScreen.dart';
//
// class FamilySettingScreen extends StatefulWidget {
//   const FamilySettingScreen({Key? key}) : super(key: key);
//
//   @override
//   _FamilySettingScreenState createState() => _FamilySettingScreenState();
// }
//
// class _FamilySettingScreenState extends State<FamilySettingScreen> {
//   String _name = "John's Family Member";
//   String _phone = "0300-1234567";
//   String _relation = "Father";
//
//   bool liveTracking = true;
//   bool sosAlerts = true;
//   bool movementAlerts = false;
//   bool darkMode = false;
//   String language = "English";
//   String updateFrequency = "Every 15 sec";
//   String inactivityTime = "15 minutes";
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseScreen(
//       title: "Settings",
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF0B0211),
//               Color(0xFF2E0249),
//               Color(0xFF570A57),
//               Color(0xFF0B0211),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             _buildSectionTitle("Profile Settings"),
//             _buildGlassCard([
//               _buildListTile(
//                 Icons.person,
//                 "Edit Profile",
//                 _name,
//                 onTap: () async {
//                   final updatedData = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => EditFamilyProfileScreen(
//                         currentName: _name,
//                         currentPhone: _phone,
//                         currentRelation: _relation,
//                       ),
//                     ),
//                   );
//
//                   if (updatedData != null && mounted) {
//                     setState(() {
//                       _name = updatedData["name"];
//                       _phone = updatedData["phone"];
//                       _relation = updatedData["relation"];
//                     });
//                   }
//                 },
//               ),
//               _buildListTile(
//                 Icons.lock,
//                 "Change Password",
//                 "••••••••",
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const ChangePasswordScreen(),
//                     ),
//                   );
//                 },
//               ),
//             ]),
//             const SizedBox(height: 20),
//
//             _buildSectionTitle("Tracking Settings"),
//             _buildGlassCard([
//               _buildSwitchTile(
//                 "Live Tracking",
//                 liveTracking,
//                     (val) => setState(() => liveTracking = val),
//               ),
//               _buildGlassDropdown(
//                 title: "Location Update Frequency",
//                 value: updateFrequency,
//                 items: [
//                   "Every 5 sec",
//                   "Every 15 sec",
//                   "Every 30 sec",
//                   "Every 1 min"
//                 ],
//                 onChanged: (val) => setState(() => updateFrequency = val!),
//               ),
//               _buildGlassDropdown(
//                 title: "Inactivity Alert After",
//                 value: inactivityTime,
//                 items: [
//                   "5 minutes",
//                   "10 minutes",
//                   "15 minutes",
//                   "30 minutes"
//                 ],
//                 onChanged: (val) => setState(() => inactivityTime = val!),
//               ),
//             ]),
//             const SizedBox(height: 20),
//
//             _buildSectionTitle("Notification Preferences"),
//             _buildGlassCard([
//               _buildSwitchTile(
//                 "SOS Alerts",
//                 sosAlerts,
//                     (val) => setState(() => sosAlerts = val),
//               ),
//               _buildSwitchTile(
//                 "Movement Alerts",
//                 movementAlerts,
//                     (val) => setState(() => movementAlerts = val),
//               ),
//             ]),
//             const SizedBox(height: 20),
//
//             _buildSectionTitle("App Preferences"),
//             _buildGlassCard([
//               _buildSwitchTile(
//                 "Dark Mode",
//                 darkMode,
//                     (val) => setState(() => darkMode = val),
//               ),
//               _buildGlassDropdown(
//                 title: "Language",
//                 value: language,
//                 items: ["English", "Urdu"],
//                 onChanged: (val) => setState(() => language = val!),
//               ),
//             ]),
//             const SizedBox(height: 20),
//
//             _buildGlassCard([
//               ListTile(
//                 leading: const Icon(Icons.logout, color: Colors.redAccent),
//                 title: const Text(
//                   "Logout",
//                   style: TextStyle(
//                     color: Colors.redAccent,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 onTap: () => Navigator.pop(context),
//               ),
//             ]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 🔹 Section Title
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8, left: 4),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   // 🔹 Glass Card
//   Widget _buildGlassCard(List<Widget> children) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.08),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//             ),
//           ),
//           child: Column(children: children),
//         ),
//       ),
//     );
//   }
//
//   // 🔹 ListTile
//   Widget _buildListTile(
//       IconData icon,
//       String title,
//       String subtitle, {
//         VoidCallback? onTap,
//       }) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.white.withOpacity(0.15),
//         child: Icon(icon, color: Colors.white),
//       ),
//       title: Text(title,
//           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
//       subtitle: Text(subtitle,
//           style: const TextStyle(color: Colors.white70)),
//       trailing: const Icon(Icons.arrow_forward_ios,
//           size: 16, color: Colors.white54),
//       onTap: onTap,
//     );
//   }
//
//   // 🔹 Switch Tile
//   Widget _buildSwitchTile(
//       String title, bool value, Function(bool) onChanged) {
//     return SwitchListTile(
//       title: Text(title,
//           style: const TextStyle(color: Colors.white)),
//       value: value,
//       activeColor: Colors.deepPurpleAccent,
//       onChanged: onChanged,
//     );
//   }
//
//   // 🔹 Glass Dropdown
//   Widget _buildGlassDropdown({
//     required String title,
//     required String value,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,
//               style: const TextStyle(
//                   color: Colors.white, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 6),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.25),
//                   ),
//                 ),
//                 child: DropdownButton<String>(
//                   dropdownColor: Colors.black87,
//                   isExpanded: true,
//                   value: value,
//                   underline: const SizedBox(),
//                   style: const TextStyle(color: Colors.white),
//                   items: items
//                       .map((item) => DropdownMenuItem(
//                     value: item,
//                     child: Text(item),
//                   ))
//                       .toList(),
//                   onChanged: onChanged,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/BaseScreen.dart';
import 'EditFamilyProfileScreen.dart';
import 'ChangePasswordScreen.dart';
import 'FamilyLoginScreen.dart';

class FamilySettingScreen extends StatefulWidget {
  const FamilySettingScreen({Key? key}) : super(key: key);

  @override
  _FamilySettingScreenState createState() => _FamilySettingScreenState();
}

class _FamilySettingScreenState extends State<FamilySettingScreen> {
  // Profile variables
  String _name = "Fetching...";
  String _phone = "Fetching...";
  String _relation = "Fetching...";

  // Settings functional variables
  bool liveTracking = true;
  bool sosAlerts = true;
  bool movementAlerts = false;
  bool darkMode = false;
  String language = "English";
  String updateFrequency = "Every 15 sec";
  String inactivityTime = "15 minutes";

  bool _isLoading = true;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadFamilySettings();
  }

  // 📥 FIRESTORE SE DATA STREAM / INITIAL FETCH
  Future<void> _loadFamilySettings() async {
    if (currentUid == null) return;
    try {
      // Profile Fetch (Core Doc)
      final userDoc = await FirebaseFirestore.instance
          .collection('family')
          .doc(currentUid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          _name = userDoc.data()?['name'] ?? "No Name Set";
          _phone = userDoc.data()?['phone'] ?? "No Phone Set";
          _relation = userDoc.data()?['relation'] ?? "Relative";
        });
      }

      // Live Real-Time Preferences Fetch (Sub-collection)
      final settingsDoc = await FirebaseFirestore.instance
          .collection('family')
          .doc(currentUid)
          .collection('settings')
          .doc('app_settings')
          .get();

      if (settingsDoc.exists && mounted) {
        final data = settingsDoc.data()!;
        setState(() {
          liveTracking = data['liveTracking'] ?? true;
          sosAlerts = data['sosAlerts'] ?? true;
          movementAlerts = data['movementAlerts'] ?? false;
          darkMode = data['darkMode'] ?? false;
          language = data['language'] ?? "English";
          updateFrequency = data['updateFrequency'] ?? "Every 15 sec";
          inactivityTime = data['inactivityTime'] ?? "15 minutes";
        });
      }
    } catch (e) {
      debugPrint("Error fetching database records: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 💾 FIREBASE MEIN SETTINGS DATA SYNC KARNE KA METHOD
  Future<void> _saveSettingsToFirestore() async {
    if (currentUid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('family')
          .doc(currentUid)
          .collection('settings')
          .doc('app_settings')
          .set({
        'liveTracking': liveTracking,
        'sosAlerts': sosAlerts,
        'movementAlerts': movementAlerts,
        'darkMode': darkMode,
        'language': language,
        'updateFrequency': updateFrequency,
        'inactivityTime': inactivityTime,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Database Update Error: $e");
    }
  }

  Future<void> _updateProfileInFirestore(String newName, String newPhone, String newRelation) async {
    if (currentUid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('family')
          .doc(currentUid)
          .update({
        'name': newName,
        'phone': newPhone,
        'relation': newRelation,
      });
    } catch (e) {
      debugPrint("Profile Root Error: $e");
    }
  }

  // 🔒 SECURE LOGOUT WORKFLOW (Clears history stack)
  Future<void> _handleLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      // Secure sign out from Firebase
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pop(context); // Loading dialog band karein

        // ✅ Yeh line saari pichli screens clear karke Family Login Screen par le jaye gi
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const FamilyLoginScreen()), // 👈 Family login screen class name
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 DYNAMIC BACKGROUND ACCORDING TO DARK MODE STATE (Bina UI change kiye)
    final darkGradient = const [
      Color(0xFF0B0211),
      Color(0xFF2E0249),
      Color(0xFF570A57),
      Color(0xFF0B0211),
    ];

    final lightGradient = const [
      Color(0xFFF3E5F5),
      Color(0xE1E1D6FA),
      Color(0xFFCE93D8),
      Color(0xFFF3E5F5),
    ];

    // Card colors adaptively update based on light/dark mode selection
    final cardColor = darkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);
    final borderColor = darkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15);
    final mainTextColor = darkMode ? Colors.white : Colors.black87;
    final subTextColor = darkMode ? Colors.white70 : Colors.black54;

    return BaseScreen(
      title: "Settings",
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: darkMode ? darkGradient : lightGradient, // Live Toggle UI Background update
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: darkMode ? Colors.white : Colors.purple))
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle("Profile Settings", mainTextColor),
            _buildGlassCard(cardColor, borderColor, [
              _buildListTile(
                Icons.person,
                "Edit Profile",
                _name,
                mainTextColor,
                subTextColor,
                onTap: () async {
                  final updatedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFamilyProfileScreen(
                        currentName: _name,
                        currentPhone: _phone,
                        currentRelation: _relation,
                      ),
                    ),
                  );

                  if (updatedData != null && mounted) {
                    setState(() {
                      _name = updatedData["name"];
                      _phone = updatedData["phone"];
                      _relation = updatedData["relation"];
                    });
                    await _updateProfileInFirestore(_name, _phone, _relation);
                  }
                },
              ),
              _buildListTile(
                Icons.lock,
                "Change Password",
                "••••••••",
                mainTextColor,
                subTextColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),

            _buildSectionTitle("Tracking Settings", mainTextColor),
            _buildGlassCard(cardColor, borderColor, [
              _buildSwitchTile(
                "Live Tracking",
                liveTracking,
                mainTextColor,
                    (val) => setState(() {
                  liveTracking = val;
                  _saveSettingsToFirestore(); // Real-time value push to Firebase
                }),
              ),
              _buildGlassDropdown(
                title: "Location Update Frequency",
                value: updateFrequency,
                textColor: mainTextColor,
                cardBg: cardColor,
                items: [
                  "Every 5 sec",
                  "Every 15 sec",
                  "Every 30 sec",
                  "Every 1 min"
                ],
                onChanged: (val) => setState(() {
                  updateFrequency = val!;
                  _saveSettingsToFirestore(); // Dynamic upload
                }),
              ),
              _buildGlassDropdown(
                title: "Inactivity Alert After",
                value: inactivityTime,
                textColor: mainTextColor,
                cardBg: cardColor,
                items: [
                  "5 minutes",
                  "10 minutes",
                  "15 minutes",
                  "30 minutes"
                ],
                onChanged: (val) => setState(() {
                  inactivityTime = val!;
                  _saveSettingsToFirestore(); // Dynamic upload
                }),
              ),
            ]),
            const SizedBox(height: 20),

            _buildSectionTitle("Notification Preferences", mainTextColor),
            _buildGlassCard(cardColor, borderColor, [
              _buildSwitchTile(
                "SOS Alerts",
                sosAlerts,
                mainTextColor,
                    (val) => setState(() {
                  sosAlerts = val;
                  _saveSettingsToFirestore(); // Dynamic upload live
                }),
              ),
              _buildSwitchTile(
                "Movement Alerts",
                movementAlerts,
                mainTextColor,
                    (val) => setState(() {
                  movementAlerts = val;
                  _saveSettingsToFirestore(); // Dynamic upload live
                }),
              ),
            ]),
            const SizedBox(height: 20),

            _buildSectionTitle("App Preferences", mainTextColor),
            _buildGlassCard(cardColor, borderColor, [
              _buildSwitchTile(
                "Dark Mode",
                darkMode,
                mainTextColor,
                    (val) => setState(() {
                  darkMode = val;
                  _saveSettingsToFirestore(); // Instantly changes full UI brightness parameters
                }),
              ),
              _buildGlassDropdown(
                title: "Language",
                value: language,
                textColor: mainTextColor,
                cardBg: cardColor,
                items: ["English", "Urdu"],
                onChanged: (val) => setState(() {
                  language = val!;
                  _saveSettingsToFirestore(); // Dynamic change language live
                }),
              ),
            ]),
            const SizedBox(height: 20),

            _buildGlassCard(cardColor, borderColor, [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: _handleLogout, // ✅ Secure Dynamic logout logic trigger
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // 🔹 Section Title Helper (Synced text color)
  Widget _buildSectionTitle(String title, Color txtColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: txtColor,
        ),
      ),
    );
  }

  // 🔹 Glass Card Helper (Synced colors)
  Widget _buildGlassCard(Color bg, Color border, List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  // 🔹 ListTile Helper (Synced styles)
  Widget _buildListTile(
      IconData icon,
      String title,
      String subtitle,
      Color titleColor,
      Color subColor, {
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.15),
        child: Icon(icon, color: titleColor),
      ),
      title: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: subColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subColor),
      onTap: onTap,
    );
  }

  // 🔹 Switch Tile Helper
  Widget _buildSwitchTile(
      String title, bool value, Color titleColor, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: titleColor)),
      value: value,
      activeColor: Colors.deepPurpleAccent,
      onChanged: onChanged,
    );
  }

  // 🔹 Glass Dropdown Helper
  Widget _buildGlassDropdown({
    required String title,
    required String value,
    required List<String> items,
    required Color textColor,
    required Color cardBg,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: cardBg.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: textColor.withOpacity(0.2)),
                ),
                child: DropdownButton<String>(
                  dropdownColor: darkMode ? Colors.black87 : Colors.white,
                  isExpanded: true,
                  value: value,
                  underline: const SizedBox(),
                  style: TextStyle(color: textColor),
                  items: items
                      .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(color: textColor)),
                  ))
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}