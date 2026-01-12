import 'package:flutter/material.dart';
import "package:project/CustomAppBar.dart";

class EmergencyHelp extends StatelessWidget {
  const EmergencyHelp({super.key});

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

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Emergency Help Screen"),
      body:  Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFE6E6FA),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

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

              Text("--- Emergency Services ---",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              buildContactRow(context, "Police", "15", "service"),
              SizedBox(height: 16),
              buildContactRow(context, "Edhi Ambulance", "115", "service"),
              SizedBox(height: 16),
              buildContactRow(context, "Rescue 1122", "1122", "service"),
              SizedBox(height: 16),
              buildContactRow(context, "Fire Brigade", "16", "service"),
              SizedBox(height: 16),
              buildContactRow(context, "Traffic Police", "1915", "service"),

              const Spacer(),

            ],
          ),
        ),
      ),
    );
  }
}