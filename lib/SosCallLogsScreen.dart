/*import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SosCallLogsScreen extends StatefulWidget {
  const SosCallLogsScreen({super.key});

  @override
  State<SosCallLogsScreen> createState() => _SosCallLogsScreenState();
}

class _SosCallLogsScreenState extends State<SosCallLogsScreen> {
  final FlutterTts flutterTts = FlutterTts();

  // Dummy SOS call logs (you can later link real data)
  final List<Map<String, String>> sosCallLogs = [
    {'name': 'MOM', 'number': '0300-1234567', 'type': 'Outgoing', 'time': '10:15 AM'},
    {'name': 'BROTHER', 'number': '0301-2345678', 'type': 'Incoming', 'time': '09:50 AM'},
    {'name': 'SISTER', 'number': '0302-3456789', 'type': 'Missed', 'time': '09:10 AM'},
    {'name': 'FATHER', 'number': '0303-4567890', 'type': 'Outgoing', 'time': 'Yesterday'},
    {'name': 'FRIEND ALIZAY', 'number': '0304-5678901', 'type': 'Incoming', 'time': 'Yesterday'},
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.speak("You are now on SOS call logs screen");
  }

  Icon _getIcon(String type) {
    switch (type) {
      case 'Outgoing':
        return const Icon(Icons.call_made, color: Colors.green);
      case 'Incoming':
        return const Icon(Icons.call_received, color: Colors.blue);
      case 'Missed':
        return const Icon(Icons.call_missed, color: Colors.red);
      default:
        return const Icon(Icons.phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SOS Call Logs"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF3E5F5),
        child: ListView.builder(
          itemCount: sosCallLogs.length,
          itemBuilder: (context, index) {
            final log = sosCallLogs[index];
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: _getIcon(log['type']!),
                title: Text(
                  log['name']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  "${log['number']}  •  ${log['type']}  •  ${log['time']}",
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SosCallLogsScreen extends StatefulWidget {
  const SosCallLogsScreen({super.key});

  @override
  State<SosCallLogsScreen> createState() => _SosCallLogsScreenState();
}

class _SosCallLogsScreenState extends State<SosCallLogsScreen> {
  List<Map<String, String>> _callLogs = [];

  @override
  void initState() {
    super.initState();
    _loadCallLogs();
  }

  Future<void> _loadCallLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('sos_call_logs');
    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);
      _callLogs = decoded.map((e) => Map<String, String>.from(e)).toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _callLogs.isEmpty
            ? const Center(
          child: Text(
            'No call logs found',
            style: TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: _callLogs.length,
          itemBuilder: (context, index) {
            final log = _callLogs[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.purple),
                title: Text(log['name'] ?? 'Unknown'),
                subtitle: Text(log['number'] ?? ''),
                trailing: Text(log['time'] ?? ''),
              ),
            );
          },
        ),
      ),
    );
  }
}