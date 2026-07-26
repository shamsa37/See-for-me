//
//
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import 'AddContactScreen.dart';
// import 'CallBlind.dart';
// import 'EmergencyVideoCallScreen.dart';
//
// class sos_screen extends StatefulWidget {
//   const sos_screen({super.key});
//
//   @override
//   State<sos_screen> createState() => _sos_screenState();
// }
//
// class _sos_screenState extends State<sos_screen> {
//   final FlutterTts flutterTts = FlutterTts();
//   final stt.SpeechToText speech = stt.SpeechToText();
//
//   int _selectedIndex = 0;
//   List<Map<String, dynamic>> contacts = [];
//   bool isLoading = true;
//
//   String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     _initSetup();
//   }
//
//   Future<void> _initSetup() async {
//     await _requestMicPermission();
//     await _loadConnectedFamilyContacts();
//     await flutterTts.speak(
//         "Voice S O S mode active. Speak contact name or say add contact");
//   }
//
//   Future<void> _requestMicPermission() async {
//     final status = await Permission.microphone.request();
//     if (status.isDenied || status.isPermanentlyDenied) {
//       await flutterTts.speak("Microphone permission denied. Please allow it from settings.");
//     }
//   }
//
//   Future<void> _loadConnectedFamilyContacts() async {
//     if (currentUid == null) return;
//
//     setState(() => isLoading = true);
//
//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('connections')
//           .where('blindUserId', isEqualTo: currentUid)
//           .where('status', isEqualTo: 'accepted')
//           .get();
//
//       List<Map<String, dynamic>> tempContacts = [];
//
//       for (var doc in querySnapshot.docs) {
//         String familyId = doc['familyMemberId'];
//
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(familyId)
//             .get();
//
//         if (userDoc.exists) {
//           tempContacts.add({
//             'uid': familyId,
//             'name': userDoc.data()?['name'] ?? 'Family Member',
//             'email': userDoc.data()?['email'] ?? '',
//             'phone': userDoc.data()?['phone'] ?? 'No Number',
//           });
//         }
//       }
//
//       setState(() {
//         contacts = tempContacts;
//         isLoading = false;
//       });
//
//       if (contacts.isEmpty) {
//         await flutterTts.speak("No family contacts added yet. Please use add contact button.");
//       }
//     } catch (e) {
//       debugPrint("Load Contacts Error: $e");
//       setState(() => isLoading = false);
//       await flutterTts.speak("Failed to load contacts");
//     }
//   }
//
//   Future<void> _handleAction(String action, Map<String, dynamic> contact) async {
//     if (currentUid == null) return;
//
//     try {
//       if (action == 'call') {
//         await flutterTts.speak("Calling ${contact['name']}");
//       } else {
//         await flutterTts.speak("Starting video call with ${contact['name']}");
//       }
//
//       // Save alert in Firestore
//       await FirebaseFirestore.instance.collection('alerts').add({
//         'blindUserId': currentUid,
//         'familyMemberId': contact['uid'],
//         'action_type': action,
//         'status': 'triggered',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       // Navigate to respective screen
//       if (action == 'call') {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CallBlind(
//               contactName: contact['name'].toString(),
//               contactNumber: contact['phone'].toString(),
//             ),
//           ),
//         );
//       } else if (action == 'video') {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => EmergencyVideoCallScreen(
//               contactName: contact['name'].toString(),
//               contactNumber: contact['phone'].toString(),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       print("❌ SOS Trigger Error: $e");
//       await flutterTts.speak("Failed to trigger emergency alert");
//     }
//   }
//
//   Widget _buildSOSMain() {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator(color: Colors.purple));
//     }
//
//     if (contacts.isEmpty) {
//       return const Center(
//         child: Text(
//           "No verified family contacts.\nUse 'Add Contact' to request connection.",
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 16, color: Colors.grey),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: contacts.length,
//       itemBuilder: (context, index) {
//         final contact = contacts[index];
//         return Card(
//           color: Colors.white,
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           child: ListTile(
//             title: Text(
//               contact['name'] ?? '',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
//             ),
//             subtitle: Text(contact['phone'] ?? ''),
//             trailing: Wrap(
//               spacing: 8,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.call, color: Colors.green),
//                   onPressed: () => _handleAction('call', contact),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.videocam, color: Colors.blue),
//                   onPressed: () => _handleAction('video', contact),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildBottomNavBar() {
//     return BottomNavigationBar(
//       currentIndex: _selectedIndex,
//       backgroundColor: Colors.white,
//       selectedItemColor: Colors.purple,
//       unselectedItemColor: Colors.grey,
//       onTap: (index) {
//         setState(() => _selectedIndex = index);
//         if (index == 0) {
//           flutterTts.speak("SOS main screen opened");
//           _loadConnectedFamilyContacts();
//         } else if (index == 1) {
//           flutterTts.speak("Add contact screen opened");
//         }
//       },
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.sos), label: 'SOS'),
//         BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Add Contact'),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(_selectedIndex == 0 ? "SOS" : "Add Contact"),
//         centerTitle: true,
//         backgroundColor: Colors.purple,
//         foregroundColor: Colors.white,
//       ),
//       body: Container(
//         color: const Color(0xFFF3E5F5),
//         child: _selectedIndex == 0 ? _buildSOSMain() : AddContactScreen(),
//       ),
//       bottomNavigationBar: _buildBottomNavBar(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AddContactScreen.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({Key? key}) : super(key: key);

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Direct Emergency Phone Call Logic
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;

    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // 📹 Video Call Trigger Logic
  void _startVideoCall(String name, String phone) {
    // Aap yahan apni CallScreen par data pass kar sakte hain
    Navigator.pushNamed(
      context,
      '/videoCall',
      arguments: {'name': name, 'phone': phone},
    );
  }

  // Delete Contact from Firestore sub-collection
  Future<void> _deleteContact(String docId) async {
    if (currentUserId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('sos')
          .doc('default')
          .collection('contacts')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact Removed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Emergency SOS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purpleAccent,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add SOS Contact',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddContactScreen()),
          );
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F051D), Color(0xFF23083B), Color(0xFF43166B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Top Info Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.redAccent, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap card to audio call, or use camera icon for video call emergency.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Saved Contacts Stream
              Expanded(
                child: currentUserId == null
                    ? const Center(
                  child: Text('User not logged in',
                      style: TextStyle(color: Colors.white)),
                )
                    : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId)
                      .collection('sos')
                      .doc('default')
                      .collection('contacts')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.purpleAccent),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.contact_phone_outlined,
                              size: 70,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No SOS Contacts Saved Yet',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap "Add SOS Contact" below to save one.',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }

                    var contacts = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        var doc = contacts[index];
                        var data = doc.data() as Map<String, dynamic>;

                        String name = data['name'] ?? 'Family Member';
                        String phone = data['phone'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _makePhoneCall(phone),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.redAccent
                                          .withOpacity(0.2),
                                      child: const Icon(
                                        Icons.family_restroom,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            phone,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 📹 Video Call Button
                                    IconButton(
                                      icon: const Icon(Icons.videocam,
                                          color: Colors.purpleAccent,
                                          size: 26),
                                      onPressed: () =>
                                          _startVideoCall(name, phone),
                                      tooltip: 'Video Call',
                                    ),
                                    // Direct Audio Call Button
                                    IconButton(
                                      icon: const Icon(Icons.call,
                                          color: Colors.greenAccent,
                                          size: 24),
                                      onPressed: () =>
                                          _makePhoneCall(phone),
                                      tooltip: 'Audio Call',
                                    ),
                                    // Delete Button
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 20),
                                      onPressed: () =>
                                          _deleteContact(doc.id),
                                      tooltip: 'Remove',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}