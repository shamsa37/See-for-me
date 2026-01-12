

/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  // ✅ Always initialize to an empty list to avoid null errors
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // ✅ Safe load contacts
  Future<void> _loadContacts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString('sos_contacts');
      if (data != null && data.isNotEmpty) {
        List<dynamic> decoded = jsonDecode(data);
        _contacts = decoded.map((e) => Map<String, String>.from(e)).toList();
      } else {
        _contacts = [];
      }
    } catch (e) {
      _contacts = []; // fallback safety
    }
    setState(() {});
  }

  // ✅ Save contact with safety check
  Future<void> _saveContact() async {
    if (_nameController.text.isEmpty || _numberController.text.isEmpty) return;

    setState(() {
      _contacts.add({
        'name': _nameController.text,
        'number': _numberController.text,
      });
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sos_contacts', jsonEncode(_contacts));

    _nameController.clear();
    _numberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple.shade50,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Save Contact'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Saved Contacts:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              // ✅ Safe rendering even if list is empty
              if (_contacts.isEmpty)
                const Text("No contacts saved yet")
              else
                ..._contacts.map((c) => ListTile(
                  title: Text(c['name'] ?? ''),
                  subtitle: Text(c['number'] ?? ''),
                  leading: const Icon(Icons.person),
                )),
            ],
          ),
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'sos_screen.dart';

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
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString('sos_contacts');
      if (data != null && data.isNotEmpty) {
        List<dynamic> decoded = jsonDecode(data);
        _contacts = decoded.map((e) => Map<String, String>.from(e)).toList();
      } else {
        _contacts = [];
      }
    } catch (e) {
      _contacts = [];
    }
    setState(() {});
  }

  Future<void> _saveContact() async {
    if (_nameController.text.isEmpty || _numberController.text.isEmpty) return;

    setState(() {
      _contacts.add({
        'name': _nameController.text,
        'number': _numberController.text,
      });
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sos_contacts', jsonEncode(_contacts));

    _nameController.clear();
    _numberController.clear();

    // ✅ Navigate to SOS screen after saving
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const sos_screen(),
      ),
    );
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
              // ----------------- Glass Container -----------------
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

                        // Name Field
                        Text(
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
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                              BorderSide(color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Number Field
                        Text(
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
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                              BorderSide(color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Save Button
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

              // ----------------- Saved Contacts List -----------------
              Align(
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
                ..._contacts.map((c) => ListTile(
                  title: Text(c['name'] ?? ''),
                  subtitle: Text(c['number'] ?? ''),
                  leading: const Icon(Icons.person, color: Colors.deepPurple),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
