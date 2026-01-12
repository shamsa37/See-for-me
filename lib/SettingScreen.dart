import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          const ListTile(
            title: Text("Profile Settings",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            value: true,
            onChanged: (val) {},
            title: const Text("Show Name"),
            subtitle: const Text("Display your name to agents/volunteers"),
          ),
          const Divider(),

          const ListTile(
            title: Text("Accessibility",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            value: false,
            onChanged: (val) {},
            title: const Text("Enable High Contrast"),
          ),
          SwitchListTile(
            value: true,
            onChanged: (val) {},
            title: const Text("Enable VoiceOver / TalkBack"),
          ),
          const Divider(),

          const ListTile(
            title: Text("Audio & Video",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            value: true,
            onChanged: (val) {},
            title: const Text("Microphone Access"),
          ),
          SwitchListTile(
            value: true,
            onChanged: (val) {},
            title: const Text("Camera Access"),
          ),
          const Divider(),

          const ListTile(
            title: Text("Notifications",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            value: true,
            onChanged: (val) {},
            title: const Text("Call Notifications"),
          ),
          SwitchListTile(
            value: false,
            onChanged: (val) {},
            title: const Text("App Update Alerts"),
          ),
          const Divider(),

          const ListTile(
            title: Text("Privacy & Security",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Manage Permissions"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}