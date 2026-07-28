// import 'package:flutter/material.dart';
// import 'dart:ui';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class FamilyAddContactScreen extends StatefulWidget {
//   const FamilyAddContactScreen({super.key});
//
//   @override
//   State<FamilyAddContactScreen> createState() => _FamilyAddContactScreenState();
// }
//
// class _FamilyAddContactScreenState extends State<FamilyAddContactScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _numberController = TextEditingController();
//
//   final FocusNode _nameFocus = FocusNode();
//   final FocusNode _numberFocus = FocusNode();
//
//   List<Map<String, dynamic>> _linkedContacts = [];
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLinkedContacts();
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
//   // Load Linked Contacts
//   Future<void> _loadLinkedContacts() async {
//     if (currentUid == null) return;
//
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('connections')
//           .where('familyMemberId', isEqualTo: currentUid)
//           .get();
//
//       setState(() {
//         _linkedContacts = snapshot.docs.map((doc) => {
//           'id': doc.id,
//           'name': doc.data().containsKey('familyCustomName') ? doc['familyCustomName'] : 'Blind User',
//           'number': doc['familyPhone'] ?? '',
//           'status': doc['status'] ?? 'accepted',
//         }).toList();
//       });
//     } catch (e) {
//       debugPrint("Error loading contacts: $e");
//     }
//   }
//
//   // Save Blind Contact
//   Future<void> _saveBlindContact() async {
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
//     if (currentUid == null) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       // 1. Try finding blind user by phone
//       final blindQuery = await FirebaseFirestore.instance
//           .collection('blind')
//           .where('phone', isEqualTo: number)
//           .limit(1)
//           .get();
//
//       String realBlindId = "";
//
//       if (blindQuery.docs.isNotEmpty) {
//         realBlindId = blindQuery.docs.first.id;
//       } else {
//         // Fallback: Agar phone match na ho, toh blind collection ka pehla user utha lo taake testing na ruke
//         final allBlindUsers = await FirebaseFirestore.instance.collection('blind').limit(1).get();
//         if (allBlindUsers.docs.isNotEmpty) {
//           realBlindId = allBlindUsers.docs.first.id;
//         } else {
//           setState(() => _isLoading = false);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("No blind user registered in database at all!")),
//           );
//           return;
//         }
//       }
//
//       // 2. Save Connection with accepted status
//       await FirebaseFirestore.instance.collection('connections').add({
//         'blindUserId': realBlindId,
//         'familyMemberId': currentUid,
//         'familyPhone': number,
//         'familyCustomName': name,
//         'status': 'accepted',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       _nameController.clear();
//       _numberController.clear();
//
//       setState(() => _isLoading = false);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Blind User linked successfully!")),
//       );
//
//       if (mounted) {
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text("Add Blind Contact", style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF0B0211), Color(0xFF2E0249), Color(0xFF570A57), Color(0xFF0B0211)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 100.0),
//             child: Column(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(25),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(color: Colors.white.withOpacity(0.1)),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Text(
//                             "Blind User Name",
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: _nameController,
//                             focusNode: _nameFocus,
//                             style: const TextStyle(color: Colors.white),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.05),
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                                 borderSide: const BorderSide(color: Color(0xFF570A57), width: 2),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           const Text(
//                             "Registered Phone Number",
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: _numberController,
//                             focusNode: _numberFocus,
//                             keyboardType: TextInputType.phone,
//                             style: const TextStyle(color: Colors.white),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.05),
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                                 borderSide: const BorderSide(color: Color(0xFF570A57), width: 2),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//                           _isLoading
//                               ? const Center(child: CircularProgressIndicator(color: Colors.white))
//                               : GestureDetector(
//                             onTap: _saveBlindContact,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 15),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20),
//                                 gradient: const LinearGradient(
//                                   colors: [Color(0xFF570A57), Color(0xFF2E0249)],
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                 ),
//                               ),
//                               child: const Center(
//                                 child: Text(
//                                   "Save & Link Contact",
//                                   style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 const Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "Linked Blind Contacts:",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 if (_linkedContacts.isEmpty)
//                   const Text("No blind users linked yet", style: TextStyle(color: Colors.white60))
//                 else
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: _linkedContacts.length,
//                     itemBuilder: (context, index) {
//                       final c = _linkedContacts[index];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: ListTile(
//                           title: Text(c['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                           subtitle: Text(c['number'] ?? '', style: const TextStyle(color: Colors.white70)),
//                           leading: const CircleAvatar(
//                             backgroundColor: Color(0xFF2E0249),
//                             child: Icon(Icons.person, color: Colors.white),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyAddContactScreen extends StatefulWidget {
  const FamilyAddContactScreen({super.key});

  @override
  State<FamilyAddContactScreen> createState() => _FamilyAddContactScreenState();
}

class _FamilyAddContactScreenState extends State<FamilyAddContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  List<Map<String, dynamic>> _linkedContacts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLinkedContacts();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Load Linked Contacts
  Future<void> _loadLinkedContacts() async {
    if (currentUid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('familyMemberId', isEqualTo: currentUid)
          .get();

      setState(() {
        _linkedContacts = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc.data().containsKey('familyCustomName') ? doc['familyCustomName'] : 'Blind User',
          'email': doc.data().containsKey('familyEmail') ? doc['familyEmail'] : '',
          'status': doc.data().containsKey('status') ? doc['status'] : 'accepted',
        }).toList();
      });
    } catch (e) {
      debugPrint("Error loading contacts: $e");
    }
  }

  // Save Blind Contact via Email
  Future<void> _saveBlindContact() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase(); // Normalize email to lowercase

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (currentUid == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Search in 'blind' collection with exact email match
      final blindQuery = await FirebaseFirestore.instance
          .collection('blind')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      String realBlindId = "";

      if (blindQuery.docs.isNotEmpty) {
        realBlindId = blindQuery.docs.first.id;
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No blind user found registered with email: $email")),
        );
        return;
      }

      // 2. Save Connection in Firestore
      await FirebaseFirestore.instance.collection('connections').add({
        'blindUserId': realBlindId,
        'familyMemberId': currentUid,
        'familyEmail': email,
        'familyCustomName': name,
        'status': 'accepted',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _emailController.clear();

      await _loadLinkedContacts();

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Blind User linked successfully!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Add Blind Contact", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0211), Color(0xFF2E0249), Color(0xFF570A57), Color(0xFF0B0211)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 100.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Blind User Name",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Color(0xFF570A57), width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Registered Email Address",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Color(0xFF570A57), width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                              : GestureDetector(
                            onTap: _saveBlindContact,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF570A57), Color(0xFF2E0249)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Save & Link Contact",
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Linked Blind Contacts:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                if (_linkedContacts.isEmpty)
                  const Text("No blind users linked yet", style: TextStyle(color: Colors.white60))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _linkedContacts.length,
                    itemBuilder: (context, index) {
                      final c = _linkedContacts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(c['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(c['email'] ?? '', style: const TextStyle(color: Colors.white70)),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF2E0249),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}