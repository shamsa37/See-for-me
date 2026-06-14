
/*import 'package:flutter/material.dart';
import 'CallBlind.dart';
import 'EmergencyVideoCallScreen.dart';
import 'SmsScreen.dart';
import 'HistoryScreen.dart';
import 'NotificationScreen.dart';
import 'FamilySettingScreen.dart';

class FamilyDashboard extends StatefulWidget {
  const FamilyDashboard({super.key});

  @override
  State<FamilyDashboard> createState() => _FamilyDashboardState();
}

class _FamilyDashboardState extends State<FamilyDashboard>
    with TickerProviderStateMixin {
  String blindUserName = "John Doe";
  String lastSeen = "Fetching...";
  String blindUserNumber = "+923001234567";

  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HistoryScreen(),
    NotificationScreen(),
    FamilySettingScreen(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _screens[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Gradient Background
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 👤 Profile Section
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage:
                  AssetImage('assets/profile_placeholder.png'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blindUserName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Last seen: $lastSeen",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🩶 Grey Placeholder Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔘 Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    color: Colors.red,
                    icon: Icons.sos,
                    label: "Emergency",
                    screen: EmergencyVideoCallScreen(
                      contactName: blindUserName,
                      contactNumber: blindUserNumber,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    context,
                    color: Colors.blue,
                    icon: Icons.call,
                    label: "Call",
                    screen: CallBlind(
                      contactName: blindUserName,
                      contactNumber: blindUserNumber,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    context,
                    color: Colors.amber,
                    icon: Icons.message,
                    label: "Message",
                    screen: SmsScreen(
                      contactName: blindUserName,
                      contactNumber: blindUserNumber,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // 🔹 AppBar
      appBar: AppBar(
        title: const Text(
          "Family Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),

      // 🔻 Animated Gradient Bottom Bar (Volunteer style)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.black, Color(0xFF4A148C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, -2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomBarButton(
              icon: Icons.history,
              label: "History",
              isSelected: _selectedIndex == 0,
              onTap: () => _onNavItemTapped(0),
              vsync: this,
            ),
            BottomBarButton(
              icon: Icons.notifications,
              label: "Notifications",
              isSelected: _selectedIndex == 1,
              onTap: () => _onNavItemTapped(1),
              vsync: this,
            ),
            BottomBarButton(
              icon: Icons.settings,
              label: "Settings",
              isSelected: _selectedIndex == 2,
              onTap: () => _onNavItemTapped(2),
              vsync: this,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required Color color,
        required IconData icon,
        required String label,
        required Widget screen}) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/////////////////// BOTTOM BAR BUTTON ///////////////////
class BottomBarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final TickerProvider vsync;

  const BottomBarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.vsync,
  });

  @override
  State<BottomBarButton> createState() => _BottomBarButtonState();
}

class _BottomBarButtonState extends State<BottomBarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: widget.vsync,
      duration: const Duration(milliseconds: 250),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isSelected) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BottomBarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? Colors.purpleAccent : Colors.white70;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(widget.label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: widget.isSelected
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'CallBlind.dart';
import 'EmergencyVideoCallScreen.dart';
import 'HistoryScreen.dart';
import 'NotificationScreen.dart';
import 'FamilySettingScreen.dart';

class FamilyDashboard extends StatefulWidget {
  const FamilyDashboard({super.key});

  @override
  State<FamilyDashboard> createState() => _FamilyDashboardState();
}

class _FamilyDashboardState extends State<FamilyDashboard>
    with TickerProviderStateMixin {

  String blindUserName = "John Doe";
  String lastSeen = "Fetching...";
  String blindUserNumber = "+923001234567";

  // Location Variables
  String currentAddress = "Fetching current location...";
  Position? currentPosition;

  int _selectedIndex = 0;
  Timer? _locationTimer;

  final List<Widget> _screens = const [
    HistoryScreen(),
    NotificationScreen(),
    FamilySettingScreen(),
  ];

  // ==================== LIVE LOCATION ONLY ====================
  Future<void> getLiveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => currentAddress = "Please enable GPS");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => currentAddress = "Location permission denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
      );

      String address = "${placemarks[0].subLocality ?? ''}, ${placemarks[0].locality ?? ''}, ${placemarks[0].country ?? ''}";

      setState(() {
        currentPosition = position;
        currentAddress = address.trim().isNotEmpty ? address : "Current Location";
        lastSeen = "Just now"; // Location update hote hi last seen update hoga
      });

    } catch (e) {
      setState(() => currentAddress = "Unable to fetch location");
    }
  }

  void _startLiveLocation() {
    getLiveLocation();
    _locationTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      getLiveLocation();
    });
  }

  @override
  void initState() {
    super.initState();
    _startLiveLocation();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.push(context, MaterialPageRoute(builder: (context) => _screens[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("Family Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0211), Color(0xFF2E0249), Color(0xFF570A57), Color(0xFF0B0211)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),

        child: SafeArea(
          child: Column(
            children: [
              // Profile Section
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(blindUserName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("Last seen: $lastSeen", style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ==================== REMOVED MAP & ADDED CLEAN LOCATION CARD ====================
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 60,
                        color: currentPosition == null ? Colors.grey : Colors.redAccent,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "User's Live Location",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (currentPosition == null)
                        const CircularProgressIndicator(color: Colors.white)
                      else
                        Text(
                          currentAddress,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildGlassButton(
                      color: Colors.red,
                      icon: Icons.sos,
                      label: "Emergency",
                      screen: EmergencyVideoCallScreen(contactName: blindUserName, contactNumber: blindUserNumber),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildGlassButton(
                      color: Colors.blue,
                      icon: Icons.call,
                      label: "Call",
                      screen: CallBlind(contactName: blindUserName, contactNumber: blindUserNumber),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.black, Color(0xFF4A148C)]),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomBarButton(icon: Icons.history, label: "History", isSelected: _selectedIndex == 0, onTap: () => _onNavItemTapped(0), vsync: this),
            BottomBarButton(icon: Icons.notifications, label: "Notifications", isSelected: _selectedIndex == 1, onTap: () => _onNavItemTapped(1), vsync: this),
            BottomBarButton(icon: Icons.settings, label: "Settings", isSelected: _selectedIndex == 2, onTap: () => _onNavItemTapped(2), vsync: this),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({required Color color, required IconData icon, required String label, required Widget screen}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: [color.withOpacity(0.4), color.withOpacity(0.2)]),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// BottomBarButton Class
class BottomBarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final TickerProvider vsync;

  const BottomBarButton({super.key, required this.icon, required this.label, required this.isSelected, required this.onTap, required this.vsync});

  @override
  State<BottomBarButton> createState() => _BottomBarButtonState();
}

class _BottomBarButtonState extends State<BottomBarButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: widget.vsync, duration: const Duration(milliseconds: 250));
    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    if (widget.isSelected) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BottomBarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) _controller.forward();
    else _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? Colors.purpleAccent : Colors.white70;
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(widget.label, style: TextStyle(color: color, fontSize: 12, fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}