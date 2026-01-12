// lib/EmergencyVolunteerScreen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyVolunteerScreen extends StatefulWidget {
  const EmergencyVolunteerScreen({super.key});

  @override
  State<EmergencyVolunteerScreen> createState() => _EmergencyVolunteerScreenState();
}

class _EmergencyVolunteerScreenState extends State<EmergencyVolunteerScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Call",
    "Chat",
    "Location",
    "Users",
    "Help",
  ];

  final List<Widget> _screens = [
    const VolunteerCallScreen(),  // ✅ renamed
    const ChatScreen(),
    const LocationScreen(),
    const UsersScreen(),
    const HelpScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.arrow_back),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple,
        type: BottomNavigationBarType.fixed,
        iconSize: 32,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: "Call"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Location"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Help"),
        ],
      ),
    );
  }
}

// ✅ Rename to avoid conflict with CallScreen.dart
class VolunteerCallScreen extends StatelessWidget {
  const VolunteerCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.phone_in_talk, size: 70, color: Colors.white),
          SizedBox(height: 20),
          Text(
            "📞 Quick Connect:\nNearest blind user se instant call",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<String> _messages = ["Hello 👋", "Need Help?", "I am on the way 🚶‍♂️"];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(_controller.text.trim());
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white24 : Colors.white54,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    _messages[index],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              )
            ],
          ),
        )
      ],
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(31.5204, 74.3587); // Lahore Example

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("current"),
          position: _center,
          infoWindow: const InfoWindow(title: "You are here"),
        ),
      },
    );
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: const [
        ListTile(
          leading: Icon(Icons.person, color: Colors.white),
          title: Text("User 1 - Nearby", style: TextStyle(color: Colors.white)),
        ),
        ListTile(
          leading: Icon(Icons.person, color: Colors.white),
          title: Text("User 2 - 1km away", style: TextStyle(color: Colors.white)),
        ),
        ListTile(
          leading: Icon(Icons.person, color: Colors.white),
          title: Text("User 3 - 2km away", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "📖 Help & Guide Section\nHow to use the app?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
