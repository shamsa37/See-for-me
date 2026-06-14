// // TODO Implement this library.
// import 'package:flutter/material.dart';
//
// class IncomingVolunteerCallScreen extends StatelessWidget {
//   final VoidCallback onAccept;
//   final VoidCallback onReject;
//
//   const IncomingVolunteerCallScreen({
//     super.key,
//     required this.onAccept,
//     required this.onReject,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(Icons.person, size: 90, color: Colors.deepPurple),
//         const SizedBox(height: 20),
//         const Text(
//           "Blind user needs help",
//           style: TextStyle(color: Colors.white, fontSize: 18),
//         ),
//         const SizedBox(height: 40),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               onPressed: onReject,
//               child: const Icon(Icons.call_end),
//             ),
//             const SizedBox(width: 40),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               onPressed: onAccept,
//               child: const Icon(Icons.call),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.85), // overlay effect

      child: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person,
                size: 90,
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 15),

              const Text(
                "Incoming Help Request",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "A blind user needs your assistance",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ❌ REJECT
                  ElevatedButton.icon(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.call_end),
                    label: const Text("Reject"),
                  ),

                  // ✅ ACCEPT
                  ElevatedButton.icon(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.call),
                    label: const Text("Accept"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}