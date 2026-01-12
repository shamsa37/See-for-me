import 'package:flutter/material.dart';
import 'incoming_volunteer_call_screen.dart';
import 'VolunteerVideoConnectedScreen.dart';

class CallScreen extends StatefulWidget {
  final String contactName;

  const CallScreen({
    super.key,
    this.contactName = "Blind User",
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int _selectedIndex = 1;
  bool _isIncomingCall = true;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const Center(
        child: Text("No Call History",
            style: TextStyle(color: Colors.white)),
      ),

      // 🔥 ACTIVE CALL TAB
      _isIncomingCall
          ? IncomingVolunteerCallScreen(
        onAccept: () {
          setState(() {
            _isIncomingCall = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VolunteerVideoConnectedScreen(
                blindName: widget.contactName,
                volunteerName: "Volunteer",
              ),
            ),
          );
        },
        onReject: () {
          setState(() {
            _isIncomingCall = false;
          });
        },
      )
          : const Center(
        child: Text("No Active Call",
            style: TextStyle(color: Colors.white)),
      ),

      const Center(
        child: Text("No Scheduled Calls",
            style: TextStyle(color: Colors.white)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Call Screen")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "Call Back"),
          BottomNavigationBarItem(
              icon: Icon(Icons.call), label: "Active Call"),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: "Scheduled"),
        ],
      ),
    );
  }
}