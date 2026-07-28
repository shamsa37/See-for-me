//
// import 'package:flutter/material.dart';
// import 'dart:ui';
// import 'sos_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AddContactScreen extends StatefulWidget {
//   const AddContactScreen({super.key});
//
//   @override
//   State<AddContactScreen> createState() => _AddContactScreenState();
// }
//
// class _AddContactScreenState extends State<AddContactScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _numberController = TextEditingController();
//
//   final FocusNode _nameFocus = FocusNode();
//   final FocusNode _numberFocus = FocusNode();
//
//   List<Map<String, dynamic>> _sentRequests = [];
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSentRequests();
//   }
//
//   @override
//   void dispose() {
//     _nameFocus.dispose();
//     _numberFocus.dispose();
//     _nameController.dispose();
//     _numberController.dispose();
//     super.dispose();
//   }
//
//   String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
//
//   // Load Saved Contacts from SOS Sub-collection
//   Future<void> _loadSentRequests() async {
//     if (currentUid == null) return;
//
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUid)
//           .collection('sos')
//           .doc('default')
//           .collection('contacts')
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       List<Map<String, dynamic>> tempRequests = [];
//
//       for (var doc in snapshot.docs) {
//         tempRequests.add({
//           'id': doc.id,
//           'name': doc['name'] ?? 'Family Member',
//           'number': doc['phone'] ?? '',
//           'status': doc['status'] ?? 'accepted',
//         });
//       }
//
//       setState(() {
//         _sentRequests = tempRequests;
//       });
//     } catch (e) {
//       debugPrint("Error loading requests: $e");
//     }
//   }
//
//   // Save Contact directly under users -> {uid} -> sos -> default -> contacts
//   Future<void> _sendConnectionRequest() async {
//     final name = _nameController.text.trim();
//     final number = _numberController.text.trim();
//
//     if (name.isEmpty || number.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all fields")),
//       );
//       return;
//     }
//
//     if (currentUid == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("User session expired. Please login again.")),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       // 📌 UPDATED PATH: users/{uid}/sos/default/contacts
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUid)
//           .collection('sos')
//           .doc('default')
//           .collection('contacts')
//           .add({
//         'name': name,
//         'phone': number,
//         'status': 'accepted',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       debugPrint("✅ Contact saved under blind user's SOS sub-collection!");
//
//       _nameController.clear();
//       _numberController.clear();
//
//       await _loadSentRequests();
//
//       setState(() => _isLoading = false);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Contact saved successfully!")),
//         );
//
//         // Back to SOS Screen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SosScreen()),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       debugPrint("❌ Firestore Request Error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Request Failed: $e")),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3E5F5),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(25),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//                   child: Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(25),
//                       border: Border.all(color: Colors.white.withOpacity(0.3)),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.deepPurple.withOpacity(0.3),
//                           blurRadius: 20,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Center(
//                           child: Text(
//                             "Add SOS Contact",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.purple.shade500,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 25),
//                         const Text(
//                           "Family Member Name",
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.purple,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         TextField(
//                           controller: _nameController,
//                           focusNode: _nameFocus,
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white.withOpacity(0.25),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 15, vertical: 12),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15),
//                               borderSide: const BorderSide(
//                                   color: Colors.purple, width: 2),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         const Text(
//                           "Registered Phone Number",
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.purple,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         TextField(
//                           controller: _numberController,
//                           focusNode: _numberFocus,
//                           keyboardType: TextInputType.phone,
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white.withOpacity(0.25),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 15, vertical: 12),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15),
//                               borderSide: const BorderSide(
//                                   color: Colors.purple, width: 2),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 25),
//                         _isLoading
//                             ? const Center(
//                             child:
//                             CircularProgressIndicator(color: Colors.purple))
//                             : GestureDetector(
//                           onTap: _sendConnectionRequest,
//                           child: Container(
//                             padding:
//                             const EdgeInsets.symmetric(vertical: 15),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               gradient: const LinearGradient(
//                                 colors: [
//                                   Color(0xFF6A1B9A),
//                                   Color(0xFF8E24AA)
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 "Save SOS Contact",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Saved SOS Contacts:",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.purple,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               if (_sentRequests.isEmpty)
//                 const Text("No SOS contacts saved yet")
//               else
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: _sentRequests.length,
//                   itemBuilder: (context, index) {
//                     final r = _sentRequests[index];
//                     return ListTile(
//                       title: Text(r['name'] ?? ''),
//                       subtitle: Text(r['number'] ?? ''),
//                       leading: const Icon(Icons.verified, color: Colors.green),
//                       trailing: const Text(
//                         "Saved",
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:ui';
import 'sos_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  List<Map<String, dynamic>> _sentRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSentRequests();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Load Saved Phone Contacts from Firestore
  Future<void> _loadSentRequests() async {
    if (currentUid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid)
          .collection('sos_contacts')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> tempRequests = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        tempRequests.add({
          'id': doc.id,
          'name': data['name'] ?? 'Family Member',
          'phone': data['phone'] ?? '',
          'status': 'Saved',
        });
      }

      setState(() {
        _sentRequests = tempRequests;
      });
    } catch (e) {
      debugPrint("Error loading contacts: $e");
    }
  }

  // Save Contact Phone Number under blind -> {uid} -> sos_contacts
  Future<void> _sendConnectionRequest() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User session expired. Please login again.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 📌 UPDATED PATH: blind/{uid}/sos_contacts
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid)
          .collection('sos_contacts')
          .add({
        'name': name,
        'relation': name,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Contact phone number saved under blind user's SOS sub-collection!");

      _nameController.clear();
      _phoneController.clear();

      await _loadSentRequests();

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact saved successfully!")),
        );

        // Back to SOS Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SosScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("❌ Firestore Request Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request Failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "Add SOS Contact",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          "Contact / Relation Name (e.g. Mama)",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          decoration: InputDecoration(
                            hintText: "Mama, Baba, etc.",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.25),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Phone Number",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "03001234567",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.25),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _isLoading
                            ? const Center(
                            child:
                            CircularProgressIndicator(color: Colors.purple))
                            : GestureDetector(
                          onTap: _sendConnectionRequest,
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6A1B9A),
                                  Color(0xFF8E24AA)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Save SOS Contact",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Saved SOS Contacts:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_sentRequests.isEmpty)
                const Text("No SOS contacts saved yet")
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sentRequests.length,
                  itemBuilder: (context, index) {
                    final r = _sentRequests[index];
                    return ListTile(
                      title: Text(r['name'] ?? ''),
                      subtitle: Text(r['phone'] ?? ''),
                      leading: const Icon(Icons.phone_in_talk, color: Colors.green),
                      trailing: const Text(
                        "Saved",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}