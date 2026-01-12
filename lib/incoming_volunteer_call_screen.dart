// TODO Implement this library.
import 'package:flutter/material.dart';

class IncomingVolunteerCallScreen extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingVolunteerCallScreen({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person, size: 90, color: Colors.deepPurple),
        const SizedBox(height: 20),
        const Text(
          "Blind user needs help",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: onReject,
              child: const Icon(Icons.call_end),
            ),
            const SizedBox(width: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: onAccept,
              child: const Icon(Icons.call),
            ),
          ],
        ),
      ],
    );
  }
}