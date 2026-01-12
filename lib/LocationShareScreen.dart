import 'package:flutter/material.dart';

class LocationShareScreen extends StatelessWidget {
  final String contactName;
  final String contactNumber;

  const LocationShareScreen({
    super.key,
    required this.contactName,
    required this.contactNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy location
    String dummyLocation = "Lat: 24.8607, Lng: 67.0011"; // Karachi coords

    return Scaffold(
      appBar: AppBar(title: const Text("Share Location")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 100, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                "Sharing location with $contactName\n"
                    "Number: $contactNumber\n"
                    "Location: $dummyLocation",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back"),
              )
            ],
          ),
        ),
      ),
    );
  }
}