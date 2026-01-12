/*import 'package:flutter/material.dart';
import 'package:project/BaseScreen.dart';
import 'EditFamilyProfileScreen.dart';
import 'ChangePasswordScreen.dart';

class FamilySettingScreen extends StatefulWidget {
  const FamilySettingScreen({Key? key}) : super(key: key);

  @override
  _FamilySettingScreenState createState() => _FamilySettingScreenState();
}

class _FamilySettingScreenState extends State<FamilySettingScreen> {
  String _name = "John's Family Member";
  String _phone = "0300-1234567";
  String _relation = "Father";

  bool liveTracking = true;
  bool sosAlerts = true;
  bool movementAlerts = false;
  bool darkMode = false;
  String language = "English";
  String updateFrequency = "Every 15 sec";
  String inactivityTime = "15 minutes";

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Settings",
      body: Container(
        color: Colors.grey[100],
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔹 Profile Section
            _buildSectionTitle("Profile Settings"),
            _buildSettingCard([
              _buildListTile(
                Icons.person,
                "Edit Profile",
                _name,
                onTap: () async {
                  final updatedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFamilyProfileScreen(
                        currentName: _name,
                        currentPhone: _phone,
                        currentRelation: _relation,
                      ),
                    ),
                  );

                  if (updatedData != null && mounted) {
                    setState(() {
                      _name = updatedData["name"];
                      _phone = updatedData["phone"];
                      _relation = updatedData["relation"];
                    });
                  }
                },
              ),
              _buildListTile(
                Icons.lock,
                "Change Password",
                "••••••••",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),

            // 🔹 Tracking Settings
            _buildSectionTitle("Tracking Settings"),
            _buildSettingCard([
              _buildSwitchTile("Live Tracking", liveTracking,
                      (val) => setState(() => liveTracking = val)),
              _buildDropdown(
                title: "Location Update Frequency",
                value: updateFrequency,
                items: [
                  "Every 5 sec",
                  "Every 15 sec",
                  "Every 30 sec",
                  "Every 1 min"
                ],
                onChanged: (val) => setState(() => updateFrequency = val!),
              ),
              _buildDropdown(
                title: "Inactivity Alert After",
                value: inactivityTime,
                items: [
                  "5 minutes",
                  "10 minutes",
                  "15 minutes",
                  "30 minutes"
                ],
                onChanged: (val) => setState(() => inactivityTime = val!),
              ),
            ]),
            const SizedBox(height: 20),

            // 🔹 Notification Settings
            _buildSectionTitle("Notification Preferences"),
            _buildSettingCard([
              _buildSwitchTile("SOS Alerts", sosAlerts,
                      (val) => setState(() => sosAlerts = val)),
              _buildSwitchTile("Movement Alerts", movementAlerts,
                      (val) => setState(() => movementAlerts = val)),
            ]),
            const SizedBox(height: 20),

            // 🔹 App Preferences
            _buildSectionTitle("App Preferences"),
            _buildSettingCard([
              _buildSwitchTile("Dark Mode", darkMode,
                      (val) => setState(() => darkMode = val)),
              _buildDropdown(
                title: "Language",
                value: language,
                items: ["English", "Urdu"],
                onChanged: (val) => setState(() => language = val!),
              ),
            ]),
            const SizedBox(height: 20),

            // 🔹 Logout
            Card(
              elevation: 3,
              shadowColor: Colors.red.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🟣 Reusable Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  // 🟣 Section Container Card
  Widget _buildSettingCard(List<Widget> children) {
    return Card(
      elevation: 4,
      shadowColor: Colors.deepPurple.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(children: children),
      ),
    );
  }

  // 🟣 ListTile (Edit / Change)
  Widget _buildListTile(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.deepPurple.withOpacity(0.1),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }

  // 🟣 Switch Tile
  Widget _buildSwitchTile(
      String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      value: value,
      activeColor: Colors.deepPurple,
      onChanged: onChanged,
    );
  }

  // 🟣 Dropdown
  Widget _buildDropdown({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              underline: const SizedBox(),
              items: items
                  .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}*/
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project/BaseScreen.dart';
import 'EditFamilyProfileScreen.dart';
import 'ChangePasswordScreen.dart';

class FamilySettingScreen extends StatefulWidget {
  const FamilySettingScreen({Key? key}) : super(key: key);

  @override
  _FamilySettingScreenState createState() => _FamilySettingScreenState();
}

class _FamilySettingScreenState extends State<FamilySettingScreen> {
  String _name = "John's Family Member";
  String _phone = "0300-1234567";
  String _relation = "Father";

  bool liveTracking = true;
  bool sosAlerts = true;
  bool movementAlerts = false;
  bool darkMode = false;
  String language = "English";
  String updateFrequency = "Every 15 sec";
  String inactivityTime = "15 minutes";

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Settings",
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle("Profile Settings"),
            _buildGlassCard([
              _buildListTile(
                Icons.person,
                "Edit Profile",
                _name,
                onTap: () async {
                  final updatedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFamilyProfileScreen(
                        currentName: _name,
                        currentPhone: _phone,
                        currentRelation: _relation,
                      ),
                    ),
                  );

                  if (updatedData != null && mounted) {
                    setState(() {
                      _name = updatedData["name"];
                      _phone = updatedData["phone"];
                      _relation = updatedData["relation"];
                    });
                  }
                },
              ),
              _buildListTile(
                Icons.lock,
                "Change Password",
                "••••••••",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),

            _buildSectionTitle("Tracking Settings"),
            _buildGlassCard([
              _buildSwitchTile(
                "Live Tracking",
                liveTracking,
                    (val) => setState(() => liveTracking = val),
              ),
              _buildGlassDropdown(
                title: "Location Update Frequency",
                value: updateFrequency,
                items: [
                  "Every 5 sec",
                  "Every 15 sec",
                  "Every 30 sec",
                  "Every 1 min"
                ],
                onChanged: (val) => setState(() => updateFrequency = val!),
              ),
              _buildGlassDropdown(
                title: "Inactivity Alert After",
                value: inactivityTime,
                items: [
                  "5 minutes",
                  "10 minutes",
                  "15 minutes",
                  "30 minutes"
                ],
                onChanged: (val) => setState(() => inactivityTime = val!),
              ),
            ]),
            const SizedBox(height: 20),

            _buildSectionTitle("Notification Preferences"),
            _buildGlassCard([
              _buildSwitchTile(
                "SOS Alerts",
                sosAlerts,
                    (val) => setState(() => sosAlerts = val),
              ),
              _buildSwitchTile(
                "Movement Alerts",
                movementAlerts,
                    (val) => setState(() => movementAlerts = val),
              ),
            ]),
            const SizedBox(height: 20),

            _buildSectionTitle("App Preferences"),
            _buildGlassCard([
              _buildSwitchTile(
                "Dark Mode",
                darkMode,
                    (val) => setState(() => darkMode = val),
              ),
              _buildGlassDropdown(
                title: "Language",
                value: language,
                items: ["English", "Urdu"],
                onChanged: (val) => setState(() => language = val!),
              ),
            ]),
            const SizedBox(height: 20),

            _buildGlassCard([
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // 🔹 Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // 🔹 Glass Card
  Widget _buildGlassCard(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  // 🔹 ListTile
  Widget _buildListTile(
      IconData icon,
      String title,
      String subtitle, {
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.15),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Colors.white54),
      onTap: onTap,
    );
  }

  // 🔹 Switch Tile
  Widget _buildSwitchTile(
      String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title,
          style: const TextStyle(color: Colors.white)),
      value: value,
      activeColor: Colors.deepPurpleAccent,
      onChanged: onChanged,
    );
  }

  // 🔹 Glass Dropdown
  Widget _buildGlassDropdown({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                child: DropdownButton<String>(
                  dropdownColor: Colors.black87,
                  isExpanded: true,
                  value: value,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white),
                  items: items
                      .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
