/*import 'package:flutter/material.dart';
import 'package:project/BaseScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Notification preferences toggles
  bool sosAlert = true;
  bool movementAlert = true;
  bool batteryAlert = false;

  // Sample alerts list
  final List<Map<String, String>> alerts = [
    {
      'title': '🚨 SOS Alert',
      'message': 'Blind user triggered SOS alert.',
      'time': '2 mins ago'
    },
    {
      'title': '📍 Location Update',
      'message': 'John moved to a new area.',
      'time': '10 mins ago'
    },
    {
      'title': '⚠️ Inactivity Alert',
      'message': 'User has been inactive for 20 minutes.',
      'time': '25 mins ago'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Notification Screen",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔧 Notification Preferences Section
            const Text(
              "Notification Preferences",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildSwitchTile(
              "SOS Alerts",
              "Get notified when a blind user triggers SOS.",
              sosAlert,
                  (value) => setState(() => sosAlert = value),
            ),
            _buildSwitchTile(
              "Movement Alerts",
              "Receive updates when the user changes location.",
              movementAlert,
                  (value) => setState(() => movementAlert = value),
            ),
            _buildSwitchTile(
              "Battery Low Alerts",
              "Get alerts when user's device battery is low.",
              batteryAlert,
                  (value) => setState(() => batteryAlert = value),
            ),

            const SizedBox(height: 25),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            // 🔔 Recent Alerts Section
            const Text(
              "Recent Notifications",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            ...alerts.map((alert) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.notifications_active,
                    color: Colors.blue),
                title: Text(
                  alert['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(alert['message']!),
                trailing: Text(
                  alert['time']!,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      activeColor: Colors.blue,
      onChanged: onChanged,
    );
  }
}*/

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project/BaseScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool sosAlert = true;
  bool movementAlert = true;
  bool batteryAlert = false;

  final List<Map<String, String>> alerts = [
    {
      'title': '🚨 SOS Alert',
      'message': 'Blind user triggered SOS alert.',
      'time': '2 mins ago'
    },
    {
      'title': '📍 Location Update',
      'message': 'John moved to a new area.',
      'time': '10 mins ago'
    },
    {
      'title': '⚠️ Inactivity Alert',
      'message': 'User has been inactive for 20 minutes.',
      'time': '25 mins ago'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Notifications",
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                "Notification Preferences",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              _glassSwitchTile(
                "SOS Alerts",
                "Get notified when a blind user triggers SOS.",
                sosAlert,
                    (value) => setState(() => sosAlert = value),
              ),
              _glassSwitchTile(
                "Movement Alerts",
                "Receive updates when the user changes location.",
                movementAlert,
                    (value) => setState(() => movementAlert = value),
              ),
              _glassSwitchTile(
                "Battery Low Alerts",
                "Get alerts when user's device battery is low.",
                batteryAlert,
                    (value) => setState(() => batteryAlert = value),
              ),

              const SizedBox(height: 25),
              Divider(color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 10),

              const Text(
                "Recent Notifications",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Notification cards
              ...alerts.map(
                    (alert) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
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
                              Icons.notifications_active,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            alert['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            alert['message']!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            alert['time']!,
                            style: const TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
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

  // 🔹 Glass Switch Tile
  Widget _glassSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: SwitchListTile(
              title: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
              subtitle:
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
              value: value,
              activeColor: Colors.deepPurpleAccent,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}


