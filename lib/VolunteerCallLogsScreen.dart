import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VolunteerCallLogsScreen extends StatefulWidget {
  @override
  _VolunteerCallLogsScreenState createState() => _VolunteerCallLogsScreenState();
}

class _VolunteerCallLogsScreenState extends State<VolunteerCallLogsScreen> {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLogs = prefs.getStringList('volunteer_call_logs') ?? [];

    setState(() {
      _logs = storedLogs
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> _clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('volunteer_call_logs');
    setState(() => _logs = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer Call Logs"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: "Clear All Logs",
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: _logs.isEmpty
          ? Center(child: Text("No call logs yet."))
          : ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return ListTile(
            leading: Icon(
              log['type'] == "Incoming"
                  ? Icons.call_received
                  : log['type'] == "Missed"
                  ? Icons.call_missed
                  : Icons.call_made,
              color: log['type'] == "Missed" ? Colors.red : Colors.green,
            ),
            title: Text("${log['type']} Call"),
            subtitle: Text(
              "Date: ${log['datetime']}\nDuration: ${log['duration']}",
              style: TextStyle(fontSize: 13),
            ),
          );
        },
      ),
    );
  }
}
