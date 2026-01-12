import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CallScreen.dart';
import 'EditProfileScreen.dart';
import 'EmergencyVolunteerScreen.dart';
import 'VolunteerSettingsPage.dart';
import 'VolunteerHistoryScreen.dart';
import 'NotificationFeaturesScreen.dart';

enum ThemeOption { Default, Light, Dark }

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({Key? key}) : super(key: key);

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard>
    with SingleTickerProviderStateMixin {
  String _volunteerName = "Volunteer Name";
  File? _profileImage;

  late AnimationController _bgController;
  late Animation<double> _bgFade;

  ThemeOption themeOption = ThemeOption.Default;

  @override
  void initState() {
    super.initState();
    _loadProfileData();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bgFade =
        CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
    _bgController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _volunteerName = prefs.getString("name") ?? "Volunteer Name";
      final imagePath = prefs.getString("profileImage");
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _bgFade,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Color(0xFF2D0A4E),
                Color(0xFF5E2B97),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ---------- HEADER ----------
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const NetworkImage(
                            "https://via.placeholder.com/150")
                        as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome,",
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            _volunteerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---------- GRID (2 x 3) ----------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      children: [
                        AnimatedTile(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade800, Colors.orange],
                          ),
                          icon: Icons.call,
                          title: "Call",
                          subtitle: "Requests",
                          delay: 200,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CallScreen()),
                          ),
                        ),
                        AnimatedTile(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade800,
                              Colors.purple
                            ],
                          ),
                          icon: Icons.history,
                          title: "History",
                          subtitle: "Call Logs",
                          delay: 300,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const VolunteerHistoryScreen()),
                          ),
                        ),
                        AnimatedTile(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade800, Colors.red],
                          ),
                          icon: Icons.warning_amber,
                          title: "Emergency",
                          subtitle: "",
                          delay: 400,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const EmergencyVolunteerScreen()),
                          ),
                        ),
                        AnimatedTile(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade800, Colors.blue],
                          ),
                          icon: Icons.person,
                          title: "Edit Profile",
                          subtitle: "",
                          delay: 500,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const EditProfileScreen()),
                          ).then((_) => _loadProfileData()),
                        ),
                        AnimatedTile(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade800, Colors.amber],
                          ),
                          icon: Icons.notifications,
                          title: "Notifications",
                          subtitle: "",
                          delay: 600,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const NotificationFeaturesScreen()),
                          ),
                        ),
                        AnimatedTile(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade800,
                              Colors.deepPurple
                            ],
                          ),
                          icon: Icons.settings,
                          title: "Settings",
                          subtitle: "",
                          delay: 700,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VolunteerSettingsPage(
                                themeOption: themeOption,
                                onThemeChanged: (_) {},
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- TILE (BlindDashboard style) ----------------
class AnimatedTile extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int delay;

  const AnimatedTile({
    Key? key,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.delay,
  }) : super(key: key);

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.last.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(4, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(widget.icon, size: 36, color: Colors.white),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.subtitle.isNotEmpty)
                    Text(
                      widget.subtitle,
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
