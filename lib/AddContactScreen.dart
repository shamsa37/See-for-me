
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
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'sos_screen.dart';
// NEW IMPORTS
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

  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _numberFocus.dispose();
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  // UID Getter
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Updated to load from Firestore
  Future<void> _loadContacts() async {
    if (currentUid == null) {
      debugPrint("❌ No User Logged In");
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid)
          .collection('sos_contacts')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _contacts = snapshot.docs.map((doc) => {
            'name': doc['name'].toString(),
            'number': doc['number'].toString(),
          }).toList();
        });
      } else {
        // Fallback to local if Firestore is empty
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? data = prefs.getString('sos_contacts');
        if (data != null && data.isNotEmpty) {
          List<dynamic> decoded = jsonDecode(data);
          setState(() {
            _contacts = decoded.map((e) => Map<String, String>.from(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading contacts: $e");
    }
  }

  // Updated to Save to Firestore with Debugging
  Future<void> _saveContact() async {
    final name = _nameController.text.trim();
    final number = _numberController.text.trim();

    if (name.isEmpty || number.isEmpty) return;

    if (currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User session expired. Please login again.")),
      );
      return;
    }

    try {
      // 1. Save to Firestore (blind -> UID -> sos_contacts)
      await FirebaseFirestore.instance
          .collection('blind')
          .doc(currentUid!)
          .collection('sos_contacts')
          .add({
        'name': name,
        'number': number,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Saved to Firestore Successfully");

      // 2. Update Local List & SharedPreferences
      setState(() {
        _contacts.add({'name': name, 'number': number});
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('sos_contacts', jsonEncode(_contacts));

      _nameController.clear();
      _numberController.clear();

      // ✅ Navigate to SOS screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const sos_screen()),
        );
      }
    } catch (e) {
      debugPrint("❌ Firestore Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cloud Save Failed: $e")),
      );
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
                            "Add Contact",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          "Name",
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Number",
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        GestureDetector(
                          onTap: _saveContact,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Save Contact",
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
                  "Saved Contacts:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_contacts.isEmpty)
                const Text("No contacts saved yet")
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final c = _contacts[index];
                    return ListTile(
                      title: Text(c['name'] ?? ''),
                      subtitle: Text(c['number'] ?? ''),
                      leading: const Icon(Icons.person, color: Colors.deepPurple),
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