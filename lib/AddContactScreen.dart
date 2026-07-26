
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:ui';
// import 'sos_screen.dart';
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
//   List<Map<String, String>> _contacts = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadContacts();
//   }
//
//   @override
//   void dispose() {
//     _nameFocus.dispose();
//     _numberFocus.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadContacts() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? data = prefs.getString('sos_contacts');
//       if (data != null && data.isNotEmpty) {
//         List<dynamic> decoded = jsonDecode(data);
//         _contacts = decoded.map((e) => Map<String, String>.from(e)).toList();
//       } else {
//         _contacts = [];
//       }
//     } catch (e) {
//       _contacts = [];
//     }
//     setState(() {});
//   }
//
//   Future<void> _saveContact() async {
//     if (_nameController.text.isEmpty || _numberController.text.isEmpty) return;
//
//     setState(() {
//       _contacts.add({
//         'name': _nameController.text,
//         'number': _numberController.text,
//       });
//     });
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('sos_contacts', jsonEncode(_contacts));
//
//     _nameController.clear();
//     _numberController.clear();
//
//     // ✅ Navigate to SOS screen after saving
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const sos_screen(),
//       ),
//     );
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
//               // ----------------- Glass Container -----------------
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
//                             "Add Contact",
//                             style: TextStyle(
//                               fontSize: 26,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.purple.shade500,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 25),
//
//                         // Name Field
//                         Text(
//                           "Name",
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
//                             contentPadding:
//                             const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15),
//                               borderSide:
//                               BorderSide(color: Colors.purple, width: 2),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//
//                         // Number Field
//                         Text(
//                           "Number",
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
//                             contentPadding:
//                             const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15),
//                               borderSide:
//                               BorderSide(color: Colors.purple, width: 2),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 25),
//
//                         // Save Button
//                         GestureDetector(
//                           onTap: _saveContact,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               gradient: const LinearGradient(
//                                 colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 "Save Contact",
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
//
//               const SizedBox(height: 30),
//
//               // ----------------- Saved Contacts List -----------------
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Saved Contacts:",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.purple,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               if (_contacts.isEmpty)
//                 const Text("No contacts saved yet")
//               else
//                 ..._contacts.map((c) => ListTile(
//                   title: Text(c['name'] ?? ''),
//                   subtitle: Text(c['number'] ?? ''),
//                   leading: const Icon(Icons.person, color: Colors.deepPurple),
//                 )),
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
  final TextEditingController _numberController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();

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
    _numberFocus.dispose();
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Load Saved Contacts from SOS Sub-collection
  Future<void> _loadSentRequests() async {
    if (currentUid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('sos')
          .doc('default')
          .collection('contacts')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> tempRequests = [];

      for (var doc in snapshot.docs) {
        tempRequests.add({
          'id': doc.id,
          'name': doc['name'] ?? 'Family Member',
          'number': doc['phone'] ?? '',
          'status': doc['status'] ?? 'accepted',
        });
      }

      setState(() {
        _sentRequests = tempRequests;
      });
    } catch (e) {
      debugPrint("Error loading requests: $e");
    }
  }

  // Save Contact directly under users -> {uid} -> sos -> default -> contacts
  Future<void> _sendConnectionRequest() async {
    final name = _nameController.text.trim();
    final number = _numberController.text.trim();

    if (name.isEmpty || number.isEmpty) {
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
      // 📌 UPDATED PATH: users/{uid}/sos/default/contacts
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('sos')
          .doc('default')
          .collection('contacts')
          .add({
        'name': name,
        'phone': number,
        'status': 'accepted',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Contact saved under blind user's SOS sub-collection!");

      _nameController.clear();
      _numberController.clear();

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
                          "Family Member Name",
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
                          "Registered Phone Number",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _numberController,
                          focusNode: _numberFocus,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
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
                      subtitle: Text(r['number'] ?? ''),
                      leading: const Icon(Icons.verified, color: Colors.green),
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