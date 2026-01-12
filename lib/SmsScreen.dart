/*import 'package:flutter/material.dart';
import 'package:project/CustomAppBar.dart';

class SmsScreen extends StatelessWidget {
  final String contactName;
  final String contactNumber;

  const SmsScreen({
    super.key,
    required this.contactName,
    required this.contactNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Send SMS"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF0F8FF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Info
              Text(
                "To: $contactName ($contactNumber)",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // SMS typing box
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Speak or type your emergency message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Voice input button
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  icon: const Icon(Icons.mic, color: Colors.white),
                  label: const Text("Speak Message", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // Yahan speech-to-text ka feature integrate hoga
                  },
                ),
              ),

              const Spacer(),

              // Send button
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text("Send SMS", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("SMS Sent Successfully!")),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:project/CustomAppBar.dart';

class SmsScreen extends StatelessWidget {
  final String contactName;
  final String contactNumber;

  const SmsScreen({
    super.key,
    this.contactName = "Unknown Contact",
    this.contactNumber = "N/A",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ CustomAppBar with settings icon removed
      appBar: CustomAppBar(title: "Send SMS"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF0F8FF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "To: $contactName ($contactNumber)",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Speak or type your emergency message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  icon: const Icon(Icons.mic, color: Colors.white),
                  label: const Text(
                    "Speak Message",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    // Speech-to-text feature can be added here
                  },
                ),
              ),

              const Spacer(),

              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    "Send SMS",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("SMS Sent Successfully!")),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
