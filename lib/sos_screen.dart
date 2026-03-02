import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ✅ Imports for extra screens
import 'AddContactScreen.dart';
import 'CallBlind.dart';
import 'EmergencyVideoCallScreen.dart';

class sos_screen extends StatefulWidget {
  const sos_screen({super.key});

  @override
  State<sos_screen> createState() => _sos_screenState();
}

class _sos_screenState extends State<sos_screen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  int _selectedIndex = 0; // for bottom navigation
  List<Map<String, String>> contacts = [];

  @override
  void initState() {
    super.initState();
    _initSetup();
  }

  Future<void> _initSetup() async {
    await _requestMicPermission();
    await _loadContacts();
    await flutterTts.speak(
        "Voice SOS mode active. Speak contact name or say add contact");
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('contacts');
    if (savedData != null) {
      try {
        final decoded = jsonDecode(savedData);
        if (decoded is List) {
          setState(() {
            contacts = decoded.map((e) => Map<String, String>.from(e)).toList();
          });
        }
      } catch (e) {
        debugPrint("Error decoding contacts: $e");
      }
    } else {
      // Default demo contacts
      contacts = [
        {'name': 'MOM', 'number': '0300-1234567'},
        {'name': 'BROTHER', 'number': '0301-2345678'},
        {'name': 'SISTER', 'number': '0302-3456789'},
        {'name': 'FATHER', 'number': '0303-4567890'},
        {'name': 'FRIEND ALIZAY', 'number': '0304-5678901'},
        {'name': 'FRIEND HARAM', 'number': '0305-6789012'},
      ];
    }
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      await flutterTts.speak("Microphone permission denied");
    }
  }

  // ✅ Open the correct screen on icon tap
  Future<void> _handleAction(String action, Map<String, String> contact) async {
    switch (action) {
      case 'call':
        await flutterTts.speak("Calling ${contact['name']}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallBlind(
              contactName: contact['name']!,
              contactNumber: contact['number']!,
            ),
          ),
        );
        break;
      case 'video':
        await flutterTts.speak("Starting video call with ${contact['name']}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmergencyVideoCallScreen(
              contactName: contact['name']!,
              contactNumber: contact['number']!,
            ),
          ),
        );
        break;
    }
  }

  // ✅ SOS Contacts List UI (top text removed)
  Widget _buildSOSMain() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    contact['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  subtitle: Text(contact['number'] ?? ''),
                  trailing: Wrap(
                    spacing: 10,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _handleAction('call', contact),
                      ),
                      IconButton(
                        icon: const Icon(Icons.videocam, color: Colors.blue),
                        onPressed: () => _handleAction('video', contact),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ✅ Select body based on bottom navigation
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 1:
        return AddContactScreen();
      default:
        return _buildSOSMain();
    }
  }

  // ✅ Bottom navigation bar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            flutterTts.speak("SOS main screen opened");
            break;
          case 1:
            flutterTts.speak("Add contact screen opened");
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.sos),
          label: 'SOS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'Add Contact',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ["SOS", "Add Contact"];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ✅ removes back arrow
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFFF3E5F5),
        child: _getSelectedScreen(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}


