import 'package:flutter/material.dart';
import 'package:project/CustomAppBar.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Widget buildContactRow(
      BuildContext context, String name, String number, String type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text("$name ($number)", style: TextStyle(fontSize: 16))),
        ElevatedButton(
          onPressed: () => _showMessage(context, "$name Call button pressed!"),
          child: Text("📞 Call"),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _showMessage(context, "$name SMS button pressed!"),
          child: Text("✉ SMS"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Emergency Screen"),
      body:  Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFE0FFFF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Big SOS Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, 60),
                  ),
                  onPressed: () =>
                      _showMessage(context, "SOS Button Pressed!"),
                  child: Text("🔴 SOS", style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 24),


              // Custom Contacts
              Text("--- My Emergency Contacts ---",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              buildContactRow(context, "Mom", "03xx-xxxxxxx", "custom"),
              Container(height: 20,),
              buildContactRow(context, "Brother", "03xx-xxxxxxx", "custom"),
              Container(height: 20,),
              buildContactRow(context, "Sister", "03xx-xxxxxxx", "custom"),
              Container(height: 20,),
              buildContactRow(context, "Father", "03xx-xxxxxxx", "custom"),
              Container(height: 20,),
              buildContactRow(context, "Friend Alizay", "03xx-xxxxxxx", "custom"),
              Container(height: 20,),
              buildContactRow(context, "Friend Haram", "03xx-xxxxxxx", "custom"),
              Container(height: 20,),
              buildContactRow(context, "Friend Horia", "03xx-xxxxxxx", "custom"),
              const Spacer(),

              // Back to Home Button

            ],
          ),
        ),
      ),
    );
  }
}