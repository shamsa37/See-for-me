/*import 'package:flutter/material.dart';
import 'package:project/BaseScreen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // 🔹 Dummy history data (frontend only)
  final List<Map<String, String>> historyData = const [
    {
      'date': '22 Oct 2025',
      'event': 'John sent SOS alert — Volunteer connected.',
      'time': '10:15 AM'
    },
    {
      'date': '21 Oct 2025',
      'event': 'John reached home safely.',
      'time': '7:30 PM'
    },
    {
      'date': '20 Oct 2025',
      'event': 'John requested scene description.',
      'time': '3:05 PM'
    },
    {
      'date': '19 Oct 2025',
      'event': 'Battery low warning triggered.',
      'time': '5:45 PM'
    },
    {
      'date': '18 Oct 2025',
      'event': 'Volunteer helped John cross the road.',
      'time': '11:20 AM'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "History Screen",
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          final history = historyData[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.blueAccent, size: 30),
              title: Text(
                history['event']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(history['date']!),
              trailing: Text(
                history['time']!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}*/
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project/BaseScreen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<Map<String, String>> historyData = const [
    {
      'date': '22 Oct 2025',
      'event': 'John sent SOS alert — Volunteer connected.',
      'time': '10:15 AM'
    },
    {
      'date': '21 Oct 2025',
      'event': 'John reached home safely.',
      'time': '7:30 PM'
    },
    {
      'date': '20 Oct 2025',
      'event': 'John requested scene description.',
      'time': '3:05 PM'
    },
    {
      'date': '19 Oct 2025',
      'event': 'Battery low warning triggered.',
      'time': '5:45 PM'
    },
    {
      'date': '18 Oct 2025',
      'event': 'Volunteer helped John cross the road.',
      'time': '11:20 AM'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Activity History",
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B0211),
              Color(0xFF2E0249),
              Color(0xFF570A57),
              Color(0xFF0B0211),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyData.length,
          itemBuilder: (context, index) {
            final history = historyData[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        child: const Icon(
                          Icons.history,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        history['event']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        history['date']!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        history['time']!,
                        style: const TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

