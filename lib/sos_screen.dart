//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'AddContactScreen.dart';
//
// class SosScreen extends StatefulWidget {
//   const SosScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SosScreen> createState() => _SosScreenState();
// }
//
// class _SosScreenState extends State<SosScreen> {
//   String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
//
//   // Direct Emergency Phone Call Logic
//   Future<void> _makePhoneCall(String phoneNumber) async {
//     if (phoneNumber.isEmpty) return;
//
//     final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunchUrl(launchUri)) {
//       await launchUrl(launchUri);
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Could not launch phone dialer'),
//             backgroundColor: Colors.redAccent,
//           ),
//         );
//       }
//     }
//   }
//
//   // 📹 Video Call Trigger Logic
//   void _startVideoCall(String name, String phone) {
//     // Aap yahan apni CallScreen par data pass kar sakte hain
//     Navigator.pushNamed(
//       context,
//       '/videoCall',
//       arguments: {'name': name, 'phone': phone},
//     );
//   }
//
//   // Delete Contact from Firestore sub-collection
//   Future<void> _deleteContact(String docId) async {
//     if (currentUserId == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUserId)
//           .collection('sos')
//           .doc('default')
//           .collection('contacts')
//           .doc(docId)
//           .delete();
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Contact Removed'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint("Delete error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text(
//           'Emergency SOS',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: Colors.purpleAccent,
//         icon: const Icon(Icons.person_add, color: Colors.white),
//         label: const Text(
//           'Add SOS Contact',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddContactScreen()),
//           );
//         },
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF0F051D), Color(0xFF23083B), Color(0xFF43166B)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//
//               // Top Info Banner
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.redAccent.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.warning_amber_rounded,
//                         color: Colors.redAccent, size: 30),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'Tap card to audio call, or use camera icon for video call emergency.',
//                         style: TextStyle(color: Colors.white, fontSize: 13),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Saved Contacts Stream
//               Expanded(
//                 child: currentUserId == null
//                     ? const Center(
//                   child: Text('User not logged in',
//                       style: TextStyle(color: Colors.white)),
//                 )
//                     : StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('users')
//                       .doc(currentUserId)
//                       .collection('sos')
//                       .doc('default')
//                       .collection('contacts')
//                       .orderBy('createdAt', descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const Center(
//                         child: CircularProgressIndicator(
//                             color: Colors.purpleAccent),
//                       );
//                     }
//
//                     if (!snapshot.hasData ||
//                         snapshot.data!.docs.isEmpty) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.contact_phone_outlined,
//                               size: 70,
//                               color: Colors.white.withOpacity(0.3),
//                             ),
//                             const SizedBox(height: 12),
//                             const Text(
//                               'No SOS Contacts Saved Yet',
//                               style: TextStyle(
//                                   color: Colors.white70, fontSize: 16),
//                             ),
//                             const SizedBox(height: 6),
//                             const Text(
//                               'Tap "Add SOS Contact" below to save one.',
//                               style: TextStyle(
//                                   color: Colors.white38, fontSize: 12),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//
//                     var contacts = snapshot.data!.docs;
//
//                     return ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: contacts.length,
//                       itemBuilder: (context, index) {
//                         var doc = contacts[index];
//                         var data = doc.data() as Map<String, dynamic>;
//
//                         String name = data['name'] ?? 'Family Member';
//                         String phone = data['phone'] ?? '';
//
//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.08),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: Colors.white12),
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(16),
//                               onTap: () => _makePhoneCall(phone),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(14),
//                                 child: Row(
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundColor: Colors.redAccent
//                                           .withOpacity(0.2),
//                                       child: const Icon(
//                                         Icons.family_restroom,
//                                         color: Colors.redAccent,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             name,
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 2),
//                                           Text(
//                                             phone,
//                                             style: const TextStyle(
//                                                 color: Colors.white70,
//                                                 fontSize: 13),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     // 📹 Video Call Button
//                                     IconButton(
//                                       icon: const Icon(Icons.videocam,
//                                           color: Colors.purpleAccent,
//                                           size: 26),
//                                       onPressed: () =>
//                                           _startVideoCall(name, phone),
//                                       tooltip: 'Video Call',
//                                     ),
//                                     // Direct Audio Call Button
//                                     IconButton(
//                                       icon: const Icon(Icons.call,
//                                           color: Colors.greenAccent,
//                                           size: 24),
//                                       onPressed: () =>
//                                           _makePhoneCall(phone),
//                                       tooltip: 'Audio Call',
//                                     ),
//                                     // Delete Button
//                                     IconButton(
//                                       icon: const Icon(
//                                           Icons.delete_outline,
//                                           color: Colors.redAccent,
//                                           size: 20),
//                                       onPressed: () =>
//                                           _deleteContact(doc.id),
//                                       tooltip: 'Remove',
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
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

  // Phone Call Launcher
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(' ', ''),
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not place call')),
        );
      }
    }
  }

  // Delete Contact from Firestore sub-collection
  Future<void> _deleteContact(String docId) async {
    if (currentUserId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUserId)
          .collection('sos_contacts')
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
        icon: const Icon(Icons.phone, color: Colors.white),
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
                        'Saved family phone numbers for instant emergency SOS calls.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Saved Phone Contacts Stream
              Expanded(
                child: currentUserId == null
                    ? const Center(
                  child: Text('User not logged in',
                      style: TextStyle(color: Colors.white)),
                )
                    : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('blind')
                      .doc(currentUserId)
                      .collection('sos_contacts')
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
                              Icons.phone_disabled_outlined,
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
                        String relation = data['relation'] ?? '';
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
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.redAccent
                                        .withOpacity(0.2),
                                    child: const Icon(
                                      Icons.person_outline,
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
                                          relation.isNotEmpty
                                              ? "$name ($relation)"
                                              : name,
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
                                  // Quick Direct Call Button
                                  IconButton(
                                    icon: const Icon(
                                        Icons.call,
                                        color: Colors.greenAccent,
                                        size: 22),
                                    onPressed: () =>
                                        _makePhoneCall(phone),
                                    tooltip: 'Call Now',
                                  ),
                                  // Delete Button
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 22),
                                    onPressed: () =>
                                        _deleteContact(doc.id),
                                    tooltip: 'Remove',
                                  ),
                                ],
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