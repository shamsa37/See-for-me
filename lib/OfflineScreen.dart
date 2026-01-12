/*import 'package:flutter/material.dart';
import 'package:project/CustomAppBar.dart';
import 'package:project/CallBlind.dart';
import 'package:project/LocationShareScreen.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  Widget buildContactCard(BuildContext context, String name, String number, String type) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(number, style: const TextStyle(fontSize: 16)),
        trailing: Wrap(
          spacing: 8,
          children: [
            // 📞 Voice Call
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallBlind(
                    contactName: name,
                    contactNumber: number,
                  ),
                ),
              ),
            ),
            // 📍 Location share → open LocationShareScreen with parameters
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.red),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationShareScreen(
                    contactName: name,
                    contactNumber: number,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Offline Emergency"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3E5F5),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.wifi_off, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "You are Offline",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Only Voice Call and Location Share are available."),
            const SizedBox(height: 30),

            const Text(
              "--- Emergency Contacts ---",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: [
                  buildContactCard(context, "Police", "15", "service"),
                  buildContactCard(context, "Edhi Ambulance", "115", "service"),
                  buildContactCard(context, "Rescue 1122", "1122", "service"),
                  buildContactCard(context, "Fire Brigade", "16", "service"),
                  buildContactCard(context, "Traffic Police", "1915", "service"),
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
import 'package:project/CallBlind.dart';
import 'package:project/LocationShareScreen.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  Widget buildContactCard(
      BuildContext context, String name, String number, String type) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.black, // ✅ black for subtitle
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallBlind(
                        contactName: name,
                        contactNumber: number,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.location_on, color: Colors.red),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationShareScreen(
                        contactName: name,
                        contactNumber: number,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ AppBar with white title
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: const Text(
          "Offline Emergency",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ white text
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3E5F5),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.wifi_off,
              size: 90,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              "You are Offline",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // ✅ black text
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Only Voice Call and Location Share are available.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black, // ✅ black text
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "--- Emergency Contacts ---",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black, // ✅ black text
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  buildContactCard(context, "Police", "15", "service"),
                  buildContactCard(context, "Edhi Ambulance", "115", "service"),
                  buildContactCard(context, "Rescue 1122", "1122", "service"),
                  buildContactCard(context, "Fire Brigade", "16", "service"),
                  buildContactCard(
                      context, "Traffic Police", "1915", "service"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
