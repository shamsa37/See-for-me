// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// enum DataUsageOption { WifiOnly, MobileData }
//
// class VolunteerSettingsPage extends StatefulWidget {
//   const VolunteerSettingsPage({Key? key}) : super(key: key);
//
//   @override
//   State<VolunteerSettingsPage> createState() => _VolunteerSettingsPageState();
// }
//
// class _VolunteerSettingsPageState extends State<VolunteerSettingsPage> {
//   // Persistent State Variables
//   bool isOnline = true;
//   bool doNotDisturb = false;
//   DataUsageOption dataUsage = DataUsageOption.WifiOnly;
//   bool showOnlineStatus = true;
//   bool showProfilePicture = true;
//
//   // App Meta & Developer Info
//   final String developerEmail = 'kanwalshah720@gmail.com';
//   final String appVersion = '1.0.0';
//
//   String? get currentVolunteerId => FirebaseAuth.instance.currentUser?.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPreferences();
//   }
//
//   /// Load settings initially from SharedPreferences and sync with Firestore stream
//   Future<void> _loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isOnline = prefs.getBool('is_online') ?? true;
//       doNotDisturb = prefs.getBool('dnd') ?? false;
//       final du = prefs.getString('data_usage') ?? 'WifiOnly';
//       dataUsage = du == 'MobileData' ? DataUsageOption.MobileData : DataUsageOption.WifiOnly;
//       showOnlineStatus = prefs.getBool('show_online_status') ?? true;
//       showProfilePicture = prefs.getBool('show_profile_picture') ?? true;
//     });
//
//     // Fetch live settings state from Firestore if available
//     if (currentVolunteerId != null) {
//       try {
//         final doc = await FirebaseFirestore.instance
//             .collection('volunteer')
//             .doc(currentVolunteerId)
//             .get();
//
//         if (doc.exists && doc.data() != null) {
//           final data = doc.data()!;
//           setState(() {
//             if (data.containsKey('isOnline')) isOnline = data['isOnline'] ?? isOnline;
//             if (data.containsKey('showProfilePicture')) showProfilePicture = data['showProfilePicture'] ?? showProfilePicture;
//             if (data.containsKey('showOnlineStatus')) showOnlineStatus = data['showOnlineStatus'] ?? showOnlineStatus;
//           });
//         }
//       } catch (e) {
//         debugPrint("Error fetching live settings from Firestore: $e");
//       }
//     }
//   }
//
//   /// Live Auto-Sync to SharedPreferences & Firestore
//   Future<void> _syncSettingLive({required String key, required dynamic value}) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Local Storage Update
//     if (value is bool) {
//       await prefs.setBool(key, value);
//     } else if (value is String) {
//       await prefs.setString(key, value);
//     }
//
//     // Firestore Real-Time Cloud Update
//     if (currentVolunteerId != null) {
//       try {
//         // 1. Update Sub-collection (settings/default)
//         await FirebaseFirestore.instance
//             .collection('volunteer')
//             .doc(currentVolunteerId)
//             .collection('settings')
//             .doc('default')
//             .set({
//           key: value,
//           'updatedAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//
//         // 2. Direct volunteer doc updates for live app-wide access
//         Map<String, dynamic> volunteerDocUpdate = {};
//         if (key == 'is_online' || key == 'isOnline') volunteerDocUpdate['isOnline'] = isOnline;
//         if (key == 'show_profile_picture' || key == 'showProfilePicture') volunteerDocUpdate['showProfilePicture'] = showProfilePicture;
//         if (key == 'show_online_status' || key == 'showOnlineStatus') volunteerDocUpdate['showOnlineStatus'] = showOnlineStatus;
//
//         if (volunteerDocUpdate.isNotEmpty) {
//           await FirebaseFirestore.instance
//               .collection('volunteer')
//               .doc(currentVolunteerId)
//               .set(volunteerDocUpdate, SetOptions(merge: true));
//         }
//       } catch (e) {
//         debugPrint("Firestore Sync Error ($key): $e");
//       }
//     }
//   }
//
//   // Direct Logout To Home / Login Screen
//   Future<void> _handleLogout() async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF2D0A4E),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Logout',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: const Text(
//           'Are you sure you want to log out?',
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Colors.white54),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
//             onPressed: () async {
//               Navigator.pop(context); // Close Dialog
//               await FirebaseAuth.instance.signOut();
//               if (mounted) {
//                 // Clear stack and navigate directly to root / login screen
//                 Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
//               }
//             },
//             child: const Text('Logout', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionCard({required String title, required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.12),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: Colors.orangeAccent,
//             ),
//           ),
//           const SizedBox(height: 10),
//           child,
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const textColor = Colors.white;
//     const subTextColor = Colors.white70;
//
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text(
//           'Settings',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: textColor),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black, Color(0xFF2D0A4E), Color(0xFF5E2B97)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.only(bottom: 24),
//             child: Column(
//               children: [
//                 const SizedBox(height: 10),
//
//                 // Live Availability & Status
//                 _buildSectionCard(
//                   title: 'Availability & Status',
//                   child: SwitchListTile(
//                     contentPadding: EdgeInsets.zero,
//                     activeColor: Colors.purpleAccent,
//                     title: const Text('Online Status', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
//                     subtitle: Text(
//                       isOnline ? 'You are available for visual assistance' : 'You are offline',
//                       style: TextStyle(
//                         color: isOnline ? Colors.greenAccent : subTextColor,
//                         fontSize: 13,
//                       ),
//                     ),
//                     value: isOnline,
//                     onChanged: (v) {
//                       setState(() => isOnline = v);
//                       _syncSettingLive(key: 'isOnline', value: v);
//                     },
//                   ),
//                 ),
//
//                 // Do Not Disturb
//                 _buildSectionCard(
//                   title: 'Do Not Disturb (DND)',
//                   child: SwitchListTile(
//                     contentPadding: EdgeInsets.zero,
//                     activeColor: Colors.purpleAccent,
//                     title: const Text('Enable DND', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
//                     subtitle: const Text(
//                       'Only high-priority alerts will be received',
//                       style: TextStyle(color: subTextColor, fontSize: 13),
//                     ),
//                     value: doNotDisturb,
//                     onChanged: (v) {
//                       setState(() => doNotDisturb = v);
//                       _syncSettingLive(key: 'dnd', value: v);
//                     },
//                   ),
//                 ),
//
//                 // Data Usage
//                 _buildSectionCard(
//                   title: 'Data Usage',
//                   child: Column(
//                     children: [
//                       RadioListTile<DataUsageOption>(
//                         contentPadding: EdgeInsets.zero,
//                         activeColor: Colors.purpleAccent,
//                         title: const Text('WiFi Only', style: TextStyle(color: textColor)),
//                         value: DataUsageOption.WifiOnly,
//                         groupValue: dataUsage,
//                         onChanged: (v) {
//                           if (v != null) {
//                             setState(() => dataUsage = v);
//                             _syncSettingLive(key: 'data_usage', value: 'WifiOnly');
//                           }
//                         },
//                       ),
//                       RadioListTile<DataUsageOption>(
//                         contentPadding: EdgeInsets.zero,
//                         activeColor: Colors.purpleAccent,
//                         title: const Text('Mobile Data Allowed', style: TextStyle(color: textColor)),
//                         value: DataUsageOption.MobileData,
//                         groupValue: dataUsage,
//                         onChanged: (v) {
//                           if (v != null) {
//                             setState(() => dataUsage = v);
//                             _syncSettingLive(key: 'data_usage', value: 'MobileData');
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Live Privacy Controls (Profile Picture & Status Visibility)
//                 _buildSectionCard(
//                   title: 'Privacy Controls',
//                   child: Column(
//                     children: [
//                       SwitchListTile(
//                         contentPadding: EdgeInsets.zero,
//                         activeColor: Colors.purpleAccent,
//                         title: const Text('Show Online Status', style: TextStyle(color: textColor)),
//                         subtitle: const Text('Allow visually impaired users to see when you are active', style: TextStyle(color: subTextColor, fontSize: 12)),
//                         value: showOnlineStatus,
//                         onChanged: (v) {
//                           setState(() => showOnlineStatus = v);
//                           _syncSettingLive(key: 'showOnlineStatus', value: v);
//                         },
//                       ),
//                       const Divider(color: Colors.white12),
//                       SwitchListTile(
//                         contentPadding: EdgeInsets.zero,
//                         activeColor: Colors.purpleAccent,
//                         title: const Text('Show Profile Picture', style: TextStyle(color: textColor)),
//                         subtitle: const Text('Display your avatar on the call screen and dashboard', style: TextStyle(color: subTextColor, fontSize: 12)),
//                         value: showProfilePicture,
//                         onChanged: (v) {
//                           setState(() => showProfilePicture = v);
//                           _syncSettingLive(key: 'showProfilePicture', value: v);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // About App & Support Contact
//                 _buildSectionCard(
//                   title: 'About App',
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Version: $appVersion', style: const TextStyle(color: subTextColor)),
//                       const SizedBox(height: 8),
//
//                       // Developer Email Support Tile
//                       GestureDetector(
//                         onTap: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Developer Support: $developerEmail'),
//                               backgroundColor: const Color(0xFF2D0A4E),
//                             ),
//                           );
//                         },
//                         child: Row(
//                           children: [
//                             const Icon(Icons.support_agent, size: 18, color: Colors.purpleAccent),
//                             const SizedBox(width: 6),
//                             Text(
//                               'Support: $developerEmail',
//                               style: const TextStyle(
//                                 color: Colors.purpleAccent,
//                                 decoration: TextDecoration.underline,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 8),
//                       TextButton(
//                         style: TextButton.styleFrom(padding: EdgeInsets.zero),
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (_) => AlertDialog(
//                               backgroundColor: const Color(0xFF2D0A4E),
//                               title: const Text('Terms & Conditions', style: TextStyle(color: textColor)),
//                               content: const Text(
//                                 'Terms & Conditions for Volunteer Support Application.',
//                                 style: TextStyle(color: subTextColor),
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text('Close', style: TextStyle(color: Colors.purpleAccent)),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Terms & Conditions',
//                           style: TextStyle(color: Colors.orangeAccent),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Logout Button
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: OutlinedButton.icon(
//                     icon: const Icon(Icons.logout, color: Colors.redAccent),
//                     label: const Text(
//                       'Logout Account',
//                       style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       minimumSize: const Size.fromHeight(50),
//                       side: const BorderSide(color: Colors.redAccent, width: 1.5),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     onPressed: _handleLogout,
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum DataUsageOption { WifiOnly, MobileData }

class VolunteerSettingsPage extends StatefulWidget {
  // Ignored / unused theme parameters to accept callers without showing dark mode UI
  final dynamic themeOption;
  final ValueChanged<dynamic>? onThemeChanged;

  const VolunteerSettingsPage({
    Key? key,
    this.themeOption,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  State<VolunteerSettingsPage> createState() => _VolunteerSettingsPageState();
}

class _VolunteerSettingsPageState extends State<VolunteerSettingsPage> {
  // Persistent State Variables
  bool isOnline = true;
  bool doNotDisturb = false;
  DataUsageOption dataUsage = DataUsageOption.WifiOnly;
  bool showOnlineStatus = true;
  bool showProfilePicture = true;

  // App Meta & Developer Info
  final String developerEmail = 'kanwalshah720@gmail.com';
  final String appVersion = '1.0.0';

  String? get currentVolunteerId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Load settings initially from SharedPreferences and sync with Firestore stream
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      final localIsOnline = prefs.getBool('isOnline') ?? prefs.getBool('is_online') ?? true;
      final localDnd = prefs.getBool('dnd') ?? false;
      final du = prefs.getString('data_usage') ?? 'WifiOnly';
      final localDataUsage = du == 'MobileData' ? DataUsageOption.MobileData : DataUsageOption.WifiOnly;
      final localShowOnlineStatus = prefs.getBool('showOnlineStatus') ?? prefs.getBool('show_online_status') ?? true;
      final localShowProfilePicture = prefs.getBool('showProfilePicture') ?? prefs.getBool('show_profile_picture') ?? true;

      setState(() {
        isOnline = localIsOnline;
        doNotDisturb = localDnd;
        dataUsage = localDataUsage;
        showOnlineStatus = localShowOnlineStatus;
        showProfilePicture = localShowProfilePicture;
      });

      final uid = currentVolunteerId;
      if (uid != null && uid.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('volunteer')
            .doc(uid)
            .get();

        if (!mounted) return;

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            if (data['isOnline'] is bool) {
              isOnline = data['isOnline'] as bool;
            }
            if (data['showProfilePicture'] is bool) {
              showProfilePicture = data['showProfilePicture'] as bool;
            }
            if (data['showOnlineStatus'] is bool) {
              showOnlineStatus = data['showOnlineStatus'] as bool;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  /// Live Auto-Sync to SharedPreferences & Firestore
  Future<void> _syncSettingLive({required String key, required dynamic value}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Local Storage Update
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }

      final uid = currentVolunteerId;
      if (uid == null || uid.isEmpty) return;

      // 1. Direct volunteer doc updates for live app-wide access
      Map<String, dynamic> volunteerDocUpdate = {};
      if (key == 'is_online' || key == 'isOnline') volunteerDocUpdate['isOnline'] = isOnline;
      if (key == 'show_profile_picture' || key == 'showProfilePicture') volunteerDocUpdate['showProfilePicture'] = showProfilePicture;
      if (key == 'show_online_status' || key == 'showOnlineStatus') volunteerDocUpdate['showOnlineStatus'] = showOnlineStatus;

      if (volunteerDocUpdate.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('volunteer')
            .doc(uid)
            .set(volunteerDocUpdate, SetOptions(merge: true))
            .catchError((e) => debugPrint("Firestore Volunteer Doc Update Error: $e"));
      }

      // 2. Update Sub-collection (settings/default)
      await FirebaseFirestore.instance
          .collection('volunteer')
          .doc(uid)
          .collection('settings')
          .doc('default')
          .set({
        key: value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).catchError((e) => debugPrint("Firestore Settings Sub-collection Error: $e"));

    } catch (e) {
      debugPrint("Firestore Sync Error ($key): $e");
    }
  }

  // Direct Logout To Home / Login Screen
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2D0A4E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close Dialog
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // Clear stack and navigate directly to root / login screen
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;
    const subTextColor = Colors.white70;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF2D0A4E), Color(0xFF5E2B97)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Live Availability & Status
                _buildSectionCard(
                  title: 'Availability & Status',
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.purpleAccent,
                    title: const Text('Online Status', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      isOnline ? 'You are available for visual assistance' : 'You are offline',
                      style: TextStyle(
                        color: isOnline ? Colors.greenAccent : subTextColor,
                        fontSize: 13,
                      ),
                    ),
                    value: isOnline,
                    onChanged: (v) {
                      setState(() => isOnline = v);
                      _syncSettingLive(key: 'isOnline', value: v);
                    },
                  ),
                ),

                // Do Not Disturb
                _buildSectionCard(
                  title: 'Do Not Disturb (DND)',
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.purpleAccent,
                    title: const Text('Enable DND', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'Only high-priority alerts will be received',
                      style: TextStyle(color: subTextColor, fontSize: 13),
                    ),
                    value: doNotDisturb,
                    onChanged: (v) {
                      setState(() => doNotDisturb = v);
                      _syncSettingLive(key: 'dnd', value: v);
                    },
                  ),
                ),

                // Data Usage
                _buildSectionCard(
                  title: 'Data Usage',
                  child: Column(
                    children: [
                      RadioListTile<DataUsageOption>(
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.purpleAccent,
                        title: const Text('WiFi Only', style: TextStyle(color: textColor)),
                        value: DataUsageOption.WifiOnly,
                        groupValue: dataUsage,
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => dataUsage = v);
                            _syncSettingLive(key: 'data_usage', value: 'WifiOnly');
                          }
                        },
                      ),
                      RadioListTile<DataUsageOption>(
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.purpleAccent,
                        title: const Text('Mobile Data Allowed', style: TextStyle(color: textColor)),
                        value: DataUsageOption.MobileData,
                        groupValue: dataUsage,
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => dataUsage = v);
                            _syncSettingLive(key: 'data_usage', value: 'MobileData');
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Live Privacy Controls (Profile Picture & Status Visibility)
                _buildSectionCard(
                  title: 'Privacy Controls',
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.purpleAccent,
                        title: const Text('Show Online Status', style: TextStyle(color: textColor)),
                        subtitle: const Text('Allow visually impaired users to see when you are active', style: TextStyle(color: subTextColor, fontSize: 12)),
                        value: showOnlineStatus,
                        onChanged: (v) {
                          setState(() => showOnlineStatus = v);
                          _syncSettingLive(key: 'showOnlineStatus', value: v);
                        },
                      ),
                      const Divider(color: Colors.white12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.purpleAccent,
                        title: const Text('Show Profile Picture', style: TextStyle(color: textColor)),
                        subtitle: const Text('Display your avatar on the call screen and dashboard', style: TextStyle(color: subTextColor, fontSize: 12)),
                        value: showProfilePicture,
                        onChanged: (v) {
                          setState(() => showProfilePicture = v);
                          _syncSettingLive(key: 'showProfilePicture', value: v);
                        },
                      ),
                    ],
                  ),
                ),

                // About App & Support Contact
                _buildSectionCard(
                  title: 'About App',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Version: $appVersion', style: const TextStyle(color: subTextColor)),
                      const SizedBox(height: 8),

                      // Developer Email Support Tile
                      GestureDetector(
                        onTap: () {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Developer Support: $developerEmail'),
                                backgroundColor: const Color(0xFF2D0A4E),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.support_agent, size: 18, color: Colors.purpleAccent),
                            const SizedBox(width: 6),
                            Text(
                              'Support: $developerEmail',
                              style: const TextStyle(
                                color: Colors.purpleAccent,
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              backgroundColor: const Color(0xFF2D0A4E),
                              title: const Text('Terms & Conditions', style: TextStyle(color: textColor)),
                              content: const Text(
                                'Terms & Conditions for Volunteer Support Application.',
                                style: TextStyle(color: subTextColor),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Close', style: TextStyle(color: Colors.purpleAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'Terms & Conditions',
                          style: TextStyle(color: Colors.orangeAccent),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      'Logout Account',
                      style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _handleLogout,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}