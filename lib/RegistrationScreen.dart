import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/BlindDashboardScreen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field variables
  String username = '';
  String email = '';
  String phoneNumber = '';
  String password = '';
  bool isMale = false;
  bool isFemale = false;
  bool isPreferNotToSay = false;

  // Animation variable
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Trigger fade-in animation after short delay
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Top White
              Color(0xFF7B1FA2),
              Colors.white,// Purple Bottom
            ],
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: _opacity,
            child: SingleChildScrollView(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Registration',
                        style: TextStyle(
                          fontSize: 26,
                          color: Color(0xFF7B1FA2), // Purple heading
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                        label: 'Username',
                        hint: 'Enter your username',
                        onSaved: (val) => username = val!,
                      ),
                      buildTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (val) => email = val!,
                      ),
                      buildTextField(
                        label: 'Phone Number',
                        hint: 'Enter your number',
                        keyboardType: TextInputType.phone,
                        onSaved: (val) => phoneNumber = val!,
                      ),
                      buildTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        isPassword: true,
                        onSaved: (val) => password = val!,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Gender:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          Checkbox(
                            value: isMale,
                            activeColor: Colors.purple,
                            onChanged: (val) => setState(() => isMale = val!),
                          ),
                          const Text('Male'),
                          Checkbox(
                            value: isFemale,
                            activeColor: Colors.purple,
                            onChanged: (val) => setState(() => isFemale = val!),
                          ),
                          const Text('Female'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            print('Username: $username');
                            print('Email: $email');
                            print('Phone: $phoneNumber');
                            print('Password: $password');
                            print('Gender: ${getSelectedGender()}');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BlindDashboardScreen()),
                            );
                          }
                        },
                        child: const Text(
                          'REGISTER',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 5),
          TextFormField(
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[100],
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
            onSaved: onSaved,
          ),
        ],
      ),
    );
  }

  String getSelectedGender() {
    if (isMale) return 'Male';
    if (isFemale) return 'Female';
    if (isPreferNotToSay) return 'Prefer not to say';
    return 'Not selected';
  }
}