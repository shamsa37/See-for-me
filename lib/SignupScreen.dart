import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7B1FA2), // Deep Purple
              Color(0xFFF3E5F5), // Light Purple / Whiteish
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    buildInputField(
                      icon: Icons.person,
                      hint: 'Full Name',
                      isPassword: false,
                    ),

                    // Email
                    buildInputField(
                      icon: Icons.email,
                      hint: 'Email',
                      isPassword: false,
                    ),

                    // Password
                    buildInputField(
                      icon: Icons.lock,
                      hint: 'Password',
                      isPassword: true,
                    ),

                    // Confirm Password
                    buildInputField(
                      icon: Icons.lock_outline,
                      hint: 'Confirm Password',
                      isPassword: true,
                    ),

                    const SizedBox(height: 20),

                    // Signup Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // signup logic yahan ayega
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Account created successfully!")),
                          );
                          Navigator.pop(context); // back to login
                        }
                      },
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login Now',
                        style: TextStyle(color: Colors.purpleAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable text field method (same as Login)
  Widget buildInputField({
    required IconData icon,
    required String hint,
    required bool isPassword,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
        validator: (value) =>
        value!.isEmpty ? 'Please enter your $hint' : null,
      ),
    );
  }
}
