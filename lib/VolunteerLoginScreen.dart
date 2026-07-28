
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:project/VolunteerDashboard.dart';
// import 'package:project/VolunteerRegScreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
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
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   // ================= LOGIN =================
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
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       if (!mounted) return;
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const VolunteerDashboard()),
//       );
//     } on FirebaseAuthException catch (e) {
//       String msg = "Login failed";
//
//       if (e.code == "user-not-found") {
//         msg = "No user found";
//       } else if (e.code == "wrong-password") {
//         msg = "Wrong password";
//       } else if (e.code == "invalid-email") {
//         msg = "Invalid email";
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(msg), backgroundColor: Colors.red),
//       );
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   // ================= GOOGLE SIGN-IN =================
//   Future<void> _handleGoogleSignIn() async {
//     try {
//       setState(() => isLoading = true);
//
//       final googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return;
//
//       final googleAuth = await googleUser.authentication;
//
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       await FirebaseAuth.instance.signInWithCredential(credential);
//
//       if (!mounted) return;
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const VolunteerDashboard()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Google Sign-in failed: $e")),
//       );
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   // ================= FORGOT PASSWORD =================
//   void _resetPassword() async {
//     String email = emailController.text.trim();
//
//     if (email.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter email first")),
//       );
//       return;
//     }
//
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Password reset link sent"),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
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
//
//                         const SizedBox(height: 30),
//
//                         _buildTextField(
//                           controller: emailController,
//                           icon: Icons.email,
//                           hint: "Email",
//                         ),
//
//                         const SizedBox(height: 15),
//
//                         _buildTextField(
//                           controller: passwordController,
//                           icon: Icons.lock,
//                           hint: "Password",
//                           isPassword: true,
//                         ),
//
//                         const SizedBox(height: 15),
//
//                         // ================= FORGOT PASSWORD =================
//                         GestureDetector(
//                           onTap: _resetPassword,
//                           child: const Text(
//                             "Forgot Password?",
//                             style: TextStyle(
//                               color: Color(0xFF8000FF),
//                               fontWeight: FontWeight.bold,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 25),
//
//                         if (isLoading)
//                           const CircularProgressIndicator(
//                             color: Color(0xFF8000FF),
//                           ),
//
//                         const SizedBox(height: 10),
//
//                         // ================= LOGIN BUTTON =================
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF8000FF),
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                             ),
//                             onPressed: isLoading ? null : _login,
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
//
//                         const SizedBox(height: 25),
//
//                         const Text("OR",
//                             style: TextStyle(color: Colors.white54)),
//
//                         const SizedBox(height: 20),
//
//                         GestureDetector(
//                           onTap: isLoading ? null : _handleGoogleSignIn,
//                           child: Container(
//                             padding: const EdgeInsets.all(14),
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.white,
//                             ),
//                             child: const Icon(
//                               Icons.g_mobiledata,
//                               size: 30,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 25),
//
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                 const VolunteerRegScreen(),
//                               ),
//                             );
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
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: const Color(0xFF8000FF)),
//         hintText: hint,
//         hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.08),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide.none,
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
import 'package:project/ForgetPasswordScreen.dart'; // Import added
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ================= LOGIN =================
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

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VolunteerDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "Login failed";

      if (e.code == "user-not-found") {
        msg = "No user found";
      } else if (e.code == "wrong-password") {
        msg = "Wrong password";
      } else if (e.code == "invalid-email") {
        msg = "Invalid email";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= GOOGLE SIGN-IN =================
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => isLoading = true);

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VolunteerDashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-in failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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

                        // ================= FORGOT PASSWORD NAVIGATION =================
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgetPasswordScreen(),
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
                          const CircularProgressIndicator(
                            color: Color(0xFF8000FF),
                          ),

                        const SizedBox(height: 10),

                        // ================= LOGIN BUTTON =================
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8000FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: isLoading ? null : _login,
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

                        const Text("OR",
                            style: TextStyle(color: Colors.white54)),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: isLoading ? null : _handleGoogleSignIn,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.g_mobiledata,
                              size: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const VolunteerRegScreen(),
                              ),
                            );
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8000FF)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
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