
/*import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ✅ Imports for extra screens
import 'AddContactScreen.dart';
import 'SosCallLogsScreen.dart';
import 'CallScreen.dart';
import 'SmsScreen.dart';
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
            builder: (context) => CallScreen(
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
      case 'message':
        await flutterTts.speak("Sending message to ${contact['name']}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SmsScreen(
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
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.orange),
                        onPressed: () => _handleAction('message', contact),
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
        return const AddContactScreen();
      case 2:
        return const SosCallLogsScreen();
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
          case 2:
            flutterTts.speak("Call logs screen opened");
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
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Call Logs',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ["SOS", "Add Contact", "Call Logs"];
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
}*/
/*import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // for json encode/decode

// ✅ Yahan apni screens ka import add karo
import 'AddContactScreen.dart';
import 'SosCallLogsScreen.dart';

class sos_screen extends StatefulWidget {
  const sos_screen({super.key});

  @override
  State<sos_screen> createState() => _sos_screenState();
}

class _sos_screenState extends State<sos_screen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  List<Map<String, String>> contacts = [
    {'name': 'MOM', 'number': '0300-1234567'},
    {'name': 'BROTHER', 'number': '0301-2345678'},
    {'name': 'SISTER', 'number': '0302-3456789'},
    {'name': 'FATHER', 'number': '0303-4567890'},
    {'name': 'FRIEND ALIZAY', 'number': '0304-5678901'},
    {'name': 'FRIEND HARAM', 'number': '0305-6789012'},
  ];

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
    }
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      await flutterTts.speak("Microphone permission denied");
    }
  }

  void _addContact() async {
    await flutterTts.speak("Add contact button pressed");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContactScreen()),
    );
  }

  void _openCallLogs() async {
    await flutterTts.speak("Opening call logs");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SosCallLogsScreen()),
    );
  }

  // ✅ Voice feedback for Call / Video / Message
  Future<void> _handleAction(String action, String name) async {
    switch (action) {
      case 'call':
        await flutterTts.speak("Calling $name");
        break;
      case 'video':
        await flutterTts.speak("Starting video call with $name");
        break;
      case 'message':
        await flutterTts.speak("Sending message to $name");
        break;
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SOS"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF3E5F5),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Voice SOS Mode Active (Speak Contact Name or say 'Add contact')",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Card(
                    color: Colors.white,
                    margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            onPressed: () => _handleAction(
                                'call', contact['name'] ?? 'contact'),
                          ),
                          IconButton(
                            icon:
                            const Icon(Icons.videocam, color: Colors.blue),
                            onPressed: () => _handleAction(
                                'video', contact['name'] ?? 'contact'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.message,
                                color: Colors.orange),
                            onPressed: () => _handleAction(
                                'message', contact['name'] ?? 'contact'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Buttons row
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addContact,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Contact"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openCallLogs,
                    icon: const Icon(Icons.history),
                    label: const Text("View Call Logs"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_apps/CustomAppBar.dart';
import 'package:my_apps/CallScreen.dart';
import 'package:my_apps/SmsScreen.dart';
import 'package:my_apps/EmergencyVideoCallScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class sos_screen extends StatefulWidget {
  const sos_screen({super.key});

  @override
  State<sos_screen> createState() => _sos_screenState();
}

class _sos_screenState extends State<sos_screen> {
  final FlutterTts tts = FlutterTts();
  late stt.SpeechToText speech;

  String recognizedWords = "";
  String selectedContactName = "";
  String selectedContactNumber = "";

  // Existing contacts map (unchanged)
  final Map<String, String> contacts = {
    "mom": "0300-1234567",
    "brother": "0301-2345678",
    "sister": "0302-3456789",
    "father": "0303-4567890",
    "friend alizay": "0304-5678901",
    "friend haram": "0305-6789012",
    "friend horia": "0306-7890123",
  };

  final int maxContacts = 50;
  Map<String, String> dynamicContacts = {}; // for newly added contacts

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    _startFlow();
  }

  Future<void> _startFlow() async {
    await tts.speak(
        "Your emergency contacts are Mom, Brother, Sister, Father, and Friends. Whom do you want to call? You can also say 'Add contact' to add a new number.");
    _listenForContactOrAdd();
  }

  Future<void> _listenForContactOrAdd() async {
    bool available = await speech.initialize();
    if (available) {
      speech.listen(onResult: (result) async {
        recognizedWords = result.recognizedWords.toLowerCase();

        if (recognizedWords.contains("add")) {
          _addContactVoice();
          return;
        }

        // Check in existing contacts
        for (var contact in contacts.keys) {
          if (recognizedWords.contains(contact)) {
            selectedContactName = contact;
            selectedContactNumber = contacts[contact]!;
            await tts.speak(
                "You selected $selectedContactName. The number is $selectedContactNumber. Do you want video call, audio call or send SMS?");
            _listenForAction(selectedContactName, selectedContactNumber);
            return;
          }
        }

        // Check in dynamic contacts (safe null check)
        dynamicContacts = dynamicContacts ?? {};
        for (var contact in dynamicContacts.keys) {
          if (recognizedWords.contains(contact)) {
            selectedContactName = contact;
            selectedContactNumber = dynamicContacts[contact]!;
            await tts.speak(
                "You selected $selectedContactName. The number is $selectedContactNumber. Do you want video call, audio call or send SMS?");
            _listenForAction(selectedContactName, selectedContactNumber);
            return;
          }
        }

        await tts.speak(
            "Contact not recognized. Please say again or say 'Add contact'.");
        _listenForContactOrAdd();
      });
    }
  }

  Future<void> _addContactVoice() async {
    if ((dynamicContacts.length + contacts.length) >= maxContacts) {
      await tts.speak(
          "You have reached maximum 50 contacts. Cannot add more.");
      _listenForContactOrAdd();
      return;
    }

    await tts.speak("Please say the name of the new contact.");
    speech.listen(onResult: (result) async {
      String newName = result.recognizedWords.toLowerCase();
      await tts.speak(
          "You said $newName. Now say the phone number, digit by digit.");
      speech.stop();

      speech.listen(onResult: (numberResult) async {
        String number = numberResult.recognizedWords.replaceAll(" ", "");
        await tts.speak(
            "You said number $number. Say confirm to save or cancel to re-enter.");
        speech.stop();

        speech.listen(onResult: (confirmResult) async {
          String decision = confirmResult.recognizedWords.toLowerCase();
          if (decision.contains("confirm")) {
            setState(() {
              dynamicContacts[newName] = number;
            });
            await tts.speak(
                "Contact $newName added successfully. Total contacts: ${contacts.length + dynamicContacts.length}");
            _listenForContactOrAdd();
          } else {
            await tts.speak("Cancelled. Let's try again.");
            _addContactVoice();
          }
        });
      });
    });
  }

  Future<void> _listenForAction(String contactName, String number) async {
    speech.listen(onResult: (result) {
      String action = result.recognizedWords.toLowerCase();
      if (action.contains("video")) {
        _startVideoCall(contactName, number);
      } else if (action.contains("audio") || action.contains("call")) {
        _startAudioCall(contactName, number);
      } else if (action.contains("sms") || action.contains("message")) {
        _startSms(contactName, number);
      } else {
        tts.speak(
            "Action not recognized. Please say audio call, video call, or SMS.");
        _listenForAction(contactName, number);
      }
    });
  }

  void _startVideoCall(String name, String number) {
    speech.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EmergencyVideoCallScreen(contactName: name, contactNumber: number),
      ),
    );
  }

  void _startAudioCall(String name, String number) {
    speech.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CallScreen(contactName: name, contactNumber: number),
      ),
    );
  }

  void _startSms(String name, String number) {
    speech.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SmsScreen(contactName: name, contactNumber: number),
      ),
    );
  }

  Widget buildContactCard(String name, String number) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Text(
          name.toUpperCase(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(number, style: const TextStyle(fontSize: 16)),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _startAudioCall(name, number),
            ),
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.blueAccent),
              onPressed: () => _startVideoCall(name, number),
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Colors.orange),
              onPressed: () => _startSms(name, number),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "SOS"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3E5F5),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Voice SOS Mode Active (Speak Contact Name or say 'Add contact')",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ...contacts.entries.map((entry) => buildContactCard(entry.key, entry.value)),
                  ...dynamicContacts.entries.map((entry) => buildContactCard(entry.key, entry.value)),
                ],
              ),
            ),
            if (selectedContactName.isNotEmpty) ...[
              const Divider(),
              Text(
                "Selected Contact: $selectedContactName\nNumber: $selectedContactNumber",
                style: const TextStyle(fontSize: 18, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // for json encode/decode

// ✅ Yahan apni screens ka import add karo
import 'AddContactScreen.dart';
import 'SosCallLogsScreen.dart';

class sos_screen extends StatefulWidget {
  const sos_screen({super.key});

  @override
  State<sos_screen> createState() => _sos_screenState();
}

class _sos_screenState extends State<sos_screen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  String currentView = 'main'; // "main", "add", "logs"

  List<Map<String, String>> contacts = [
    {'name': 'MOM', 'number': '0300-1234567'},
    {'name': 'BROTHER', 'number': '0301-2345678'},
    {'name': 'SISTER', 'number': '0302-3456789'},
    {'name': 'FATHER', 'number': '0303-4567890'},
    {'name': 'FRIEND ALIZAY', 'number': '0304-5678901'},
    {'name': 'FRIEND HARAM', 'number': '0305-6789012'},
  ];

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
    }
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      await flutterTts.speak("Microphone permission denied");
    }
  }

  void _switchView(String view) async {
    if (view == currentView) return;
    setState(() => currentView = view);
    switch (view) {
      case 'add':
        await flutterTts.speak("Add contact screen opened");
        break;
      case 'logs':
        await flutterTts.speak("Viewing call logs");
        break;
      case 'main':
        await flutterTts.speak("Returning to SOS main screen");
        break;
    }
  }

  Future<void> _handleAction(String action, String name) async {
    switch (action) {
      case 'call':
        await flutterTts.speak("Calling $name");
        break;
      case 'video':
        await flutterTts.speak("Starting video call with $name");
        break;
      case 'message':
        await flutterTts.speak("Sending message to $name");
        break;
    }
  }

  Widget _buildMainView() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Voice SOS Mode Active (Speak Contact Name or say 'Add contact')",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                color: Colors.white,
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        onPressed: () =>
                            _handleAction('call', contact['name'] ?? 'contact'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.videocam, color: Colors.blue),
                        onPressed: () => _handleAction(
                            'video', contact['name'] ?? 'contact'),
                      ),
                      IconButton(
                        icon:
                        const Icon(Icons.message, color: Colors.orange),
                        onPressed: () => _handleAction(
                            'message', contact['name'] ?? 'contact'),
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

  Widget _buildDynamicBody() {
    switch (currentView) {
      case 'add':
        return const AddContactScreen();
      case 'logs':
        return const SosCallLogsScreen();
      default:
        return _buildMainView();
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (currentView == 'add') {
      title = "Add Contact";
    } else if (currentView == 'logs') {
      title = "Call Logs";
    } else {
      title = "SOS";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: currentView != 'main'
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _switchView('main'),
        )
            : null,
      ),
      body: Container(
        color: const Color(0xFFF3E5F5),
        child: Column(
          children: [
            Expanded(child: _buildDynamicBody()),
            Container(
              color: Colors.white,
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _switchView('add'),
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Contact"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _switchView('logs'),
                    icon: const Icon(Icons.history),
                    label: const Text("View Call Logs"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ✅ Imports for extra screens
import 'AddContactScreen.dart';
import 'SosCallLogsScreen.dart';
import 'CallBlind.dart';
import 'SmsScreen.dart';
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
      case 'message':
        await flutterTts.speak("Sending message to ${contact['name']}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SmsScreen(
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
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.orange),
                        onPressed: () => _handleAction('message', contact),
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
      case 2:
        return SosCallLogsScreen();
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
          case 2:
            flutterTts.speak("Call logs screen opened");
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
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Call Logs',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ["SOS", "Add Contact", "Call Logs"];
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


