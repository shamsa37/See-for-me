// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import 'ChangePasswordScreen.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen>
//     with TickerProviderStateMixin {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController availabilityController = TextEditingController();
//
//   File? _profileImage;
//   bool _isLoading = false;
//
//   late final List<AnimationController> _controllers;
//   late final List<Animation<Offset>> _animations;
//
//   String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfileData();
//
//     // 🎬 Animations setup
//     _controllers = List.generate(
//       5,
//           (index) => AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 500),
//       ),
//     );
//
//     _animations = _controllers
//         .map((c) => Tween<Offset>(
//       begin: const Offset(1, 0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
//         .toList();
//
//     _runAnimations();
//   }
//
//   Future<void> _runAnimations() async {
//     for (var controller in _controllers) {
//       await Future.delayed(const Duration(milliseconds: 150));
//       controller.forward();
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   // ✅ Firestore + Local SharedPreferences Save Method
//   Future<void> _saveProfileData() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // 1. Save locally in SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('name', nameController.text.trim());
//       await prefs.setString('email', emailController.text.trim());
//       await prefs.setString('availability', availabilityController.text.trim());
//       if (_profileImage != null) {
//         await prefs.setString('profileImage', _profileImage!.path);
//       }
//
//       // 2. Save directly in Firebase Firestore for Volunteer Dashboard
//       if (currentUserId != null) {
//         await FirebaseFirestore.instance
//             .collection('volunteer')
//             .doc(currentUserId)
//             .set({
//           'name': nameController.text.trim(),
//           'email': emailController.text.trim(),
//           'availability': availabilityController.text.trim(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Profile updated successfully!"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error updating profile: $e"),
//             backgroundColor: Colors.redAccent,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   // ✅ Initial Load from Local Prefs & Firestore Sync
//   Future<void> _loadProfileData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       nameController.text = prefs.getString('name') ?? '';
//       emailController.text = prefs.getString('email') ?? '';
//       availabilityController.text = prefs.getString('availability') ?? '';
//       final imagePath = prefs.getString('profileImage');
//       if (imagePath != null && imagePath.isNotEmpty) {
//         _profileImage = File(imagePath);
//       }
//     });
//
//     if (currentUserId != null) {
//       try {
//         var doc = await FirebaseFirestore.instance
//             .collection('volunteer')
//             .doc(currentUserId)
//             .get();
//
//         if (doc.exists && doc.data() != null) {
//           var data = doc.data()!;
//           setState(() {
//             if (data.containsKey('name')) nameController.text = data['name'] ?? '';
//             if (data.containsKey('email')) emailController.text = data['email'] ?? '';
//             if (data.containsKey('availability')) {
//               availabilityController.text = data['availability'] ?? '';
//             }
//           });
//         }
//       } catch (e) {
//         debugPrint("Error fetching profile: $e");
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     for (var c in _controllers) {
//       c.dispose();
//     }
//     nameController.dispose();
//     emailController.dispose();
//     availabilityController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text(
//           "Edit Profile",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Container(
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black, Color(0xFF6A1B9A)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               const SizedBox(height: 100),
//               SlideTransition(
//                 position: _animations[0],
//                 child: GestureDetector(
//                   onTap: _pickImage,
//                   child: CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.white24,
//                     backgroundImage:
//                     _profileImage != null ? FileImage(_profileImage!) : null,
//                     child: _profileImage == null
//                         ? const Icon(Icons.camera_alt,
//                         size: 40, color: Colors.white70)
//                         : null,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SlideTransition(
//                   position: _animations[1],
//                   child: _buildTextField(nameController, "Name")),
//               SlideTransition(
//                   position: _animations[2],
//                   child: _buildTextField(emailController, "Email")),
//               SlideTransition(
//                   position: _animations[3],
//                   child: _buildTextField(
//                       availabilityController, "Availability")),
//               const SizedBox(height: 20),
//               SlideTransition(
//                 position: _animations[4],
//                 child: Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _saveProfileData,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.deepPurple,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 40, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25)),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2),
//                       )
//                           : const Text("Save Profile",
//                           style:
//                           TextStyle(fontSize: 16, color: Colors.white)),
//                     ),
//                     const SizedBox(height: 15),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                               const ChangePasswordScreen()),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.redAccent,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 40, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25)),
//                       ),
//                       child: const Text("Change Password",
//                           style: TextStyle(fontSize: 16, color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextField(
//         controller: controller,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white70),
//           filled: true,
//           fillColor: Colors.white10,
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.white38),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ChangePasswordScreen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();

  // 🔑 New Password Controllers
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;

  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _animations;

  User? get currentUser => FirebaseAuth.instance.currentUser;
  String? get currentUserId => currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadProfileData();

    // 🎬 Animations setup (6 items for smooth entrance)
    _controllers = List.generate(
      6,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _animations = _controllers
        .map((c) => Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _runAnimations();
  }

  Future<void> _runAnimations() async {
    for (var controller in _controllers) {
      await Future.delayed(const Duration(milliseconds: 120));
      controller.forward();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // ✅ Re-authenticate user before updating credentials in Firebase Auth
  Future<bool> _reauthenticateUser(String currentPassword) async {
    final user = currentUser;
    if (user != null && user.email != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Current password is incorrect!"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return false;
      }
    }
    return false;
  }

  // ✅ Complete Profile, Email, Password & Firestore Update
  Future<void> _saveProfileData() async {
    final newEmail = emailController.text.trim();
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    // Agar User Email ya Password update kar raha hai toh current password zaroori hai
    bool isCredentialChange = (newEmail != currentUser?.email && newEmail.isNotEmpty) || newPassword.isNotEmpty;

    if (isCredentialChange && currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your Current Password to update credentials."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = currentUser;

      // 1. Re-authenticate if security changes exist
      if (isCredentialChange) {
        bool authenticated = await _reauthenticateUser(currentPassword);
        if (!authenticated) {
          setState(() => _isLoading = false);
          return;
        }

        // Update Email in Firebase Auth
        if (newEmail.isNotEmpty && newEmail != user?.email) {
          await user?.verifyBeforeUpdateEmail(newEmail);
        }

        // Update Password in Firebase Auth (Next login will require new password)
        if (newPassword.isNotEmpty) {
          if (newPassword.length < 6) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("New password must be at least 6 characters long."),
                backgroundColor: Colors.redAccent,
              ),
            );
            setState(() => _isLoading = false);
            return;
          }
          await user?.updatePassword(newPassword);
        }
      }

      // 2. Save locally in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', nameController.text.trim());
      await prefs.setString('email', newEmail);
      await prefs.setString('availability', availabilityController.text.trim());
      if (_profileImage != null) {
        await prefs.setString('profileImage', _profileImage!.path);
      }

      // 3. Save updated metadata in Firebase Firestore
      if (currentUserId != null) {
        await FirebaseFirestore.instance
            .collection('volunteer')
            .doc(currentUserId)
            .set({
          'name': nameController.text.trim(),
          'email': newEmail,
          'availability': availabilityController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Reset password fields
      currentPasswordController.clear();
      newPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile and credentials updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating profile: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ Initial Load from Local Prefs & Firestore Sync
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      emailController.text = prefs.getString('email') ?? currentUser?.email ?? '';
      availabilityController.text = prefs.getString('availability') ?? '';
      final imagePath = prefs.getString('profileImage');
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
    });

    if (currentUserId != null) {
      try {
        var doc = await FirebaseFirestore.instance
            .collection('volunteer')
            .doc(currentUserId)
            .get();

        if (doc.exists && doc.data() != null) {
          var data = doc.data()!;
          setState(() {
            if (data.containsKey('name')) nameController.text = data['name'] ?? '';
            if (data.containsKey('email')) emailController.text = data['email'] ?? '';
            if (data.containsKey('availability')) {
              availabilityController.text = data['availability'] ?? '';
            }
          });
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    nameController.dispose();
    emailController.dispose();
    availabilityController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF6A1B9A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Profile Avatar
              SlideTransition(
                position: _animations[0],
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.white70)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Text Fields
              SlideTransition(
                  position: _animations[1],
                  child: _buildTextField(nameController, "Name")),
              SlideTransition(
                  position: _animations[2],
                  child: _buildTextField(emailController, "Email")),
              SlideTransition(
                  position: _animations[3],
                  child: _buildTextField(
                      availabilityController, "Availability")),

              // 🔒 Security Credentials Section
              SlideTransition(
                  position: _animations[4],
                  child: _buildTextField(
                      currentPasswordController, "Current Password",
                      isPassword: true)),
              SlideTransition(
                  position: _animations[4],
                  child: _buildTextField(
                      newPasswordController, "New Password (Optional)",
                      isPassword: true)),

              const SizedBox(height: 20),

              // Action Buttons
              SlideTransition(
                position: _animations[5],
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfileData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                          : const Text("Save Profile",
                          style:
                          TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const ChangePasswordScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text("Change Password Screen",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white38),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}