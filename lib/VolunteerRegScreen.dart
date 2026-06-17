// import 'dart:ui';
// import 'package:flutter/material.dart';
// import "package:project/VolunteerDashboard.dart";
// //import 'package:animate_do/animate_do.dart'; // 🎞️ Animation library
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// // ✅ Firebase Auth Import
// import 'auth_service.dart';
//
// class VolunteerRegScreen extends StatefulWidget {
//   const VolunteerRegScreen({super.key});
//
//   @override
//   State<VolunteerRegScreen> createState() => _VolunteerRegScreenState();
// }
//
// class _VolunteerRegScreenState extends State<VolunteerRegScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   String username = '';
//   String email = '';
//   String phoneNumber = '';
//   String password = '';
//   String? gender;
//
//   void _register() async {
//     if (_formKey.currentState!.validate()) {
//       if (gender == null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Please select gender")));
//         return;
//       }
//       _formKey.currentState!.save();
//
//       try {
//         // ✅ Firebase Signup for volunteer
//         await AuthService().signupUser(email, password, 'volunteer');
//         User? user = FirebaseAuth.instance.currentUser;
//
//         if (user != null) {
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .set({
//             'username': username,
//             'email': email,
//             'phoneNumber': phoneNumber,
//             'gender': gender,
//             'role': 'volunteer',
//             'createdAt': FieldValue.serverTimestamp(),
//           });
//         }
//         if (!mounted) return;
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const VolunteerDashboard()),
//             (route) => false,
//         );
//       } catch (e) {
//         if(!mounted) return;
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Registration failed: $e")),);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//         return Scaffold(
//           body: Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xff0211), Color(0xff8000ff)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25,
//                   vertical: 50,
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(25),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
//                     child: Container(
//                       padding: const EdgeInsets.all(25),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.35),
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(
//                           color: const Color(0xFF8000FF).withOpacity(0.4),
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                               const Icon(
//                                 Icons.volunteer_activism,
//                                 color: Color(0xFF9D4EDD),
//                                 size: 65,
//                             ),
//                             const SizedBox(height: 10),
//                              const Text(
//                                 "Register Yourself",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 30,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.5,
//                               ),
//                             ),
//                             const SizedBox(height: 25),
//                                _buildTextField(
//                                 icon: Icons.person,
//                                 label: "Username",
//                                 onSaved: (val) => username = val!,
//                                 validator: (v) =>
//                                     v!.isEmpty ? "Enter Username" : null,
//                               ),
//
//                             const SizedBox(height: 15),
//                              _buildTextField(
//                                 icon: Icons.email,
//                                 label: "Email",
//                                 keyboardType: TextInputType.emailAddress,
//                                 onSaved: (val) => email = val!,
//                                 validator: (v) {
//                                   if (v == null || v.isEmpty)
//                                     return "Enter Email";
//                                   if (!RegExp(
//                                     r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                                   ).hasMatch(v)) {
//                                     return "Enter valid Email";
//                                   }
//                                   return null;
//                                 },
//                               ),
//
//                             const SizedBox(height: 15),
//                                 _buildTextField(
//                                 icon: Icons.phone,
//                                 label: "Phone Number",
//                                 keyboardType: TextInputType.phone,
//                                 onSaved: (val) => phoneNumber = val!,
//                                 validator: (v) {
//                                   if (v == null || v.isEmpty)
//                                     return "Enter Phone Number";
//                                   if (!RegExp(r'^[0-9]{10,15}$').hasMatch(v))
//                                     return "Enter valid Phone Number";
//                                   return null;
//                                 },
//                             ),
//                             const SizedBox(height: 15),
//                             _buildTextField(
//                                 icon: Icons.lock,
//                                 label: "Password",
//                                 isPassword: true,
//                                 onSaved: (val) => password = val!,
//                                 validator: (v) {
//                                   if (v == null || v.isEmpty)
//                                     return "Enter Password";
//                                   if (v.length < 8) return "Min 8 characters";
//                                   return null;
//                                 },
//                               ),
//
//                             const SizedBox(height: 20),
//                             Row(
//                                 children: [
//                                   const Text(
//                                     'Gender:',
//                                     style: TextStyle(
//                                       color: Colors.white70,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Radio<String>(
//                                     value: 'Male',
//                                     groupValue: gender,
//                                     onChanged: (val) =>
//                                         setState(() => gender = val),
//                                     activeColor: const Color(0xFF9D4EDD),
//                                   ),
//                                   const Text(
//                                     'Male',
//                                     style: TextStyle(color: Colors.white70),
//                                   ),
//                                   Radio<String>(
//                                     value: 'Female',
//                                     groupValue: gender,
//                                     onChanged: (val) =>
//                                         setState(() => gender = val),
//                                     activeColor: const Color(0xFF9D4EDD),
//                                   ),
//                                   const Text(
//                                     'Female',
//                                     style: TextStyle(color: Colors.white70),
//                                   ),
//                                 ],
//                               ),
//
//                             const SizedBox(height: 25),
//                             Container(
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(15),
//                                   gradient: const LinearGradient(
//                                     colors: [
//                                       Color(0xFF8000FF),
//                                       Color(0xFF570A57),
//                                     ],
//                                   ),
//                                 ),
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.transparent,
//                                     shadowColor: Colors.transparent,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 16,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(15),
//                                     ),
//                                   ),
//                                   onPressed: _register,
//                                   child: const Text(
//                                     "Register",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 0.8,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//        );
//      }
//
//   Widget _buildTextField({
//     required IconData icon,
//     required String label,
//     bool isPassword = false,
//     TextInputType keyboardType = TextInputType.text,
//     required void Function(String?) onSaved,
//     required String? Function(String?) validator,
//   }) {
//     return TextFormField(
//       obscureText: isPassword,
//       keyboardType: keyboardType,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: const Color(0xFF9D4EDD)),
//         hintText: label,
//         hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.08),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(
//             color: const Color(0xFF9D4EDD).withOpacity(0.3),
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: const BorderSide(color: Color(0xFF9D4EDD), width: 2),
//         ),
//       ),
//       validator: validator,
//       onSaved: onSaved,
//     );
//   }
// }



import 'dart:ui';
import 'package:flutter/material.dart';
import "package:project/VolunteerDashboard.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ ADD THIS

class VolunteerRegScreen extends StatefulWidget {
  const VolunteerRegScreen({super.key});

  @override
  State<VolunteerRegScreen> createState() => _VolunteerRegScreenState();
}

class _VolunteerRegScreenState extends State<VolunteerRegScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String username = '';
  String email = '';
  String password = '';
  String? gender;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (gender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select gender")),
        );
        return;
      }

      _formKey.currentState!.save();

      try {
        // ✅ Firebase Authentication
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        // ✅ FIRESTORE COLLECTION: volunteer..
        await FirebaseFirestore.instance
            .collection('volunteer')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'username': username,
          'email': email.trim(),
          'gender': gender,
          'role': 'volunteer',
          'createdAt': Timestamp.now(),
        });

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const VolunteerDashboard(),
          ),
              (route) => false,
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0211), Color(0xff8000ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF8000FF).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.volunteer_activism,
                          color: Color(0xFF9D4EDD),
                          size: 65,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Register Yourself",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 25),

                        _buildTextField(
                          icon: Icons.person,
                          label: "Username",
                          onSaved: (val) => username = val!,
                          validator: (v) =>
                          v!.isEmpty ? "Enter Username" : null,
                        ),

                        const SizedBox(height: 15),

                        _buildTextField(
                          icon: Icons.email,
                          label: "Email",
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (val) => email = val!,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Enter Email";
                            }

                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v)) {
                              return "Enter valid Email";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        _buildTextField(
                          icon: Icons.lock,
                          label: "Password",
                          isPassword: true,
                          onSaved: (val) => password = val!,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Enter Password";
                            }

                            if (v.length < 8) {
                              return "Min 8 characters";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Text(
                              'Gender:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Radio<String>(
                              value: 'Male',
                              groupValue: gender,
                              onChanged: (val) =>
                                  setState(() => gender = val),
                              activeColor: const Color(0xFF9D4EDD),
                            ),

                            const Text(
                              'Male',
                              style: TextStyle(color: Colors.white70),
                            ),

                            Radio<String>(
                              value: 'Female',
                              groupValue: gender,
                              onChanged: (val) =>
                                  setState(() => gender = val),
                              activeColor: const Color(0xFF9D4EDD),
                            ),

                            const Text(
                              'Female',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8000FF),
                                Color(0xFF570A57),
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: _register,
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF9D4EDD)),
        hintText: label,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: const Color(0xFF9D4EDD).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF9D4EDD),
            width: 2,
          ),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}