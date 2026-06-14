// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:project/VolunteerDashboard.dart';
// import 'package:project/VolunteerRegScreen.dart';
// import 'package:project/VolForgotPasswordScreen.dart';
// import 'package:project/auth_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class VolunteerLoginScreen extends StatefulWidget {
//   const VolunteerLoginScreen({super.key});
//
//   @override
//   State<VolunteerLoginScreen> createState() => _VolunteerLoginScreenState();
// }
//
// class _VolunteerLoginScreenState extends State<VolunteerLoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   bool isLoading = false;
//
//   void _login() async {
//     String email = emailController.text.trim();
//     String password = passwordController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please fill all fields"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() => isLoading = true);
//
//     final AuthService _authService = AuthService(); // Single instance
//
//     try {
//       // 1️⃣ Login using Firebase Auth
//       await _authService.loginUser(email, password);
//
//       // 2️⃣ Get current user
//       final User? user = _authService.currentUser();
//       if (user == null) throw Exception("User not found after login");
//
//       // 3️⃣ Get user document from Firestore
//       final DocumentSnapshot<Map<String, dynamic>> userDoc =
//       await _authService.getUserDoc(user.uid);
//
//       final Map<String, dynamic>? data = userDoc.data();
//       if (data == null || !data.containsKey('role')) {
//         throw Exception("Role not defined for this user");
//       }
//
//       // 4️⃣ Role check
//       final String role = data['role'] as String;
//       if (role != 'volunteer') {
//         throw Exception("This account is not registered as a Volunteer");
//       }
//
//       // 5️⃣ Navigate to Volunteer Dashboard
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => VolunteerDashboard()),
//       );
//
//     } on FirebaseAuthException catch (e) {
//       // Handle Firebase Auth errors
//       String message;
//       if (e.code == 'user-not-found') {
//         message = 'No user found for this email.';
//       } else if (e.code == 'wrong-password') {
//         message = 'Wrong password provided.';
//       } else {
//         message = e.message ?? 'Login failed.';
//       }
//
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message), backgroundColor: Colors.red),
//       );
//
//     } catch (e) {
//       // Handle other errors (Firestore or role issues)
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
//       );
//
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> _googleSignIn() async {
//     try {
//       setState(() => isLoading = true);
//
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//
//       if (googleUser == null) {
//         setState(() => isLoading = false);
//         return; // user cancelled
//       }
//
//       final GoogleSignInAuthentication googleAuth =
//       await googleUser.authentication;
//
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       // Firebase sign-in
//       UserCredential userCredential =
//       await FirebaseAuth.instance.signInWithCredential(credential);
//
//       // Firestore me check/create user
//       DocumentReference userRef =
//       FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
//
//       DocumentSnapshot userDoc = await userRef.get();
//
//       await userRef.set({
//         'email': userCredential.user!.email,
//         'role': 'volunteer',
//       }, SetOptions(merge: true));
//
//       if (!mounted) return;
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => VolunteerDashboard()),
//       );
//
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Google Sign-In failed"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       extendBodyBehindAppBar: true,
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF0B0211),
//               Color(0xFF0B0211),
//               Color(0xFF2E0249),
//               Color(0xFF570A57),
//               Color(0xFF570A57),
//               Color(0xFF0B0211),
//               Color(0xFF0B0211),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(25),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//                 child: Container(
//                   padding: const EdgeInsets.all(25),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.4),
//                     borderRadius: BorderRadius.circular(25),
//                     border: Border.all(
//                       color: const Color(0xFF8000FF).withOpacity(0.5),
//                       width: 1.8,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF8000FF).withOpacity(0.25),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           "Volunteer Login",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         _buildTextField(
//                           controller: emailController,
//                           icon: Icons.email,
//                           hint: "Email",
//                         ),
//                         const SizedBox(height: 15),
//                         _buildTextField(
//                           controller: passwordController,
//                           icon: Icons.lock,
//                           hint: "Password",
//                           isPassword: true,
//                         ),
//                         const SizedBox(height: 15),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => VolForgotPasswordScreen(),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             "Forgot Password?",
//                             style: TextStyle(
//                               color: Color(0xFF8000FF),
//                               fontWeight: FontWeight.bold,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 25),
//                         if (isLoading)
//                           const Padding(
//                             padding: EdgeInsets.only(bottom: 15),
//                             child: CircularProgressIndicator(
//                               color: Color(0xFF8000FF),
//                             ),
//                           ),
//                         Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF8000FF), Color(0xFF570A57)],
//                             ),
//                           ),
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               shadowColor: Colors.transparent,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                             ),
//                             onPressed: isLoading
//                                 ? null
//                                 : () {
//                               if (_formKey.currentState!.validate()) {
//                                 _login();
//                               }
//                             },
//                             child: const Text(
//                               "Login",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 25),
//                         Row(
//                           children: const [
//                             Expanded(child: Divider(color: Colors.white24)),
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 10),
//                               child: Text("OR",
//                                   style: TextStyle(color: Colors.white54)),
//                             ),
//                             Expanded(child: Divider(color: Colors.white24)),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             GestureDetector(
//                               onTap: isLoading ? null : _googleSignIn,
//                               child: Container(
//                                 padding: const EdgeInsets.all(14),
//                                 decoration: const BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.white,
//                                 ),
//                                 child: Image.asset(
//                                   "assets/images/image.jpg",
//                                   height: 26,
//                                 )
//                               ),
//                             ),
//                             const SizedBox(width: 25),
//                             GestureDetector(
//                               onTap: isLoading
//                                   ? null
//                                   : () {
//                                 if (_formKey.currentState!.validate()) {
//                                   _login();
//                                 }
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(14),
//                                 decoration: const BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Color(0xFF8000FF),
//                                 ),
//                                 child: const Icon(
//                                   Icons.email,
//                                   color: Colors.white,
//                                   size: 26,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 25),
//                         GestureDetector(
//                           onTap: () {
//                             if (!isLoading) {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => VolunteerRegScreen(),
//                                 ),
//                               );
//                             }
//                           },
//                           child: const Text.rich(
//                             TextSpan(
//                               text: "Don’t have an account? ",
//                               style: TextStyle(color: Colors.white70),
//                               children: [
//                                 TextSpan(
//                                   text: "Register",
//                                   style: TextStyle(
//                                     color: Color(0xFF8000FF),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required IconData icon,
//     required String hint,
//     bool isPassword = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword,
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return "$hint is required";
//         }
//
//         if (hint == "Email" && !value.contains("@")) {
//           return "Enter valid email";
//         }
//
//         if (hint == "Password") {
//           if (value.length < 6) {
//             return "Password must be at least 6 characters";
//           }
//         }
//
//         return null;
//       },
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: const Color(0xFF8000FF)),
//         hintText: hint,
//         hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.08),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide:
//           BorderSide(color: const Color(0xFF8000FF).withOpacity(0.3)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: const BorderSide(color: Color(0xFF8000FF), width: 2),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project/VolunteerDashboard.dart';
import 'package:project/VolunteerRegScreen.dart';
import 'package:project/ForgotPasswordScreen.dart';

class VolunteerLoginScreen extends StatefulWidget {
  const VolunteerLoginScreen({super.key});

  @override
  State<VolunteerLoginScreen> createState() => _VolunteerLoginScreenState();
}

class _VolunteerLoginScreenState extends State<VolunteerLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    // 🔥 Fake delay (simulate login)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => VolunteerDashboard()),
    );

    setState(() => isLoading = false);
  }

  void _handleGoogleSignIn() async {
    setState(() => isLoading = true);

    // 🔥 Fake Google login
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => VolunteerDashboard()),
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B0211),
              Color(0xFF0B0211),
              Color(0xFF2E0249),
              Color(0xFF570A57),
              Color(0xFF570A57),
              Color(0xFF0B0211),
              Color(0xFF0B0211),
            ],
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
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF8000FF).withOpacity(0.5),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8000FF).withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Volunteer Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),

                        _buildTextField(
                          controller: emailController,
                          icon: Icons.email,
                          hint: "Email",
                        ),

                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: passwordController,
                          icon: Icons.lock,
                          hint: "Password",
                          isPassword: true,
                        ),

                        const SizedBox(height: 15),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color(0xFF8000FF),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: CircularProgressIndicator(
                              color: Color(0xFF8000FF),
                            ),
                          ),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8000FF),
                                Color(0xFF570A57)
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                _login();
                              }
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          children: const [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text("OR",
                                  style: TextStyle(color: Colors.white54)),
                            ),
                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap:
                              isLoading ? null : _handleGoogleSignIn,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.g_mobiledata,
                                    size: 30, color: Colors.black),
                              ),
                            ),

                            const SizedBox(width: 25),

                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                if (_formKey.currentState!
                                    .validate()) {
                                  _login();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF8000FF),
                                ),
                                child: const Icon(
                                  Icons.email,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        GestureDetector(
                          onTap: () {
                            if (!isLoading) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VolunteerRegScreen(),
                                ),
                              );
                            }
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "Don’t have an account? ",
                              style: TextStyle(color: Colors.white70),
                              children: [
                                TextSpan(
                                  text: "Register",
                                  style: TextStyle(
                                    color: Color(0xFF8000FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hint is required";
        }

        if (hint == "Email" && !value.contains("@")) {
          return "Enter valid email";
        }

        if (hint == "Password" && value.length < 6) {
          return "Password must be at least 6 characters";
        }

        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8000FF)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
              color: const Color(0xFF8000FF).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
          const BorderSide(color: Color(0xFF8000FF), width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}