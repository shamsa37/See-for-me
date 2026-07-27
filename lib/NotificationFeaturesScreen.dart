import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationFeaturesScreen extends StatefulWidget {
  final String userId; // 🔹 User ID passed from login/navigation

  const NotificationFeaturesScreen({super.key, required this.userId});

  @override
  State<NotificationFeaturesScreen> createState() =>
      _NotificationFeaturesScreenState();
}

class _NotificationFeaturesScreenState
    extends State<NotificationFeaturesScreen> {
  // Preference Keys
  static const _kCustomRingtoneKey = 'custom_ringtone';
  static const _kVibrationPatternKey = 'vibration_pattern';
  static const _kScreenFlashKey = 'screen_flash';
  static const _kAvailabilityReminderKey = 'availability_reminder';
  static const _kSkillMatchKey = 'skill_match_alert';
  static const _kFeedbackNotificationKey = 'feedback_notification';
  static const _kSystemUpdateKey = 'system_update_alert';
  static const _kEmergencyRingtoneKey = 'emergency_ringtone';
  static const _kVolumeOverrideKey = 'volume_override';

  // State Variables
  String _customRingtone = 'Default Tone';
  String _vibrationPattern = 'Short';
  bool _screenFlash = false;

  bool _availabilityReminder = true;
  bool _skillMatchAlert = true;
  bool _feedbackNotification = false;
  bool _systemUpdateAlert = true;

  String _emergencyRingtone = 'Emergency Alert';
  bool _volumeOverride = true;

  bool _isLoading = false;
  late SharedPreferences _prefs;

  final List<String> _ringtones = [
    'Default Tone',
    'Classic Ring',
    'Soft Beep',
    'Emergency Alert',
    'Silent'
  ];

  final List<String> _vibrationPatterns = [
    'Short',
    'Long',
    'Short-Short',
    'Short-Long-Short'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndFirestore();
  }

  // 1. Load Local Shared Preferences and Sync with Firestore
  Future<void> _loadPreferencesAndFirestore() async {
    _prefs = await SharedPreferences.getInstance();

    // First load from local storage (Fast UI render)
    setState(() {
      _customRingtone =
          _prefs.getString(_kCustomRingtoneKey) ?? _customRingtone;
      _vibrationPattern =
          _prefs.getString(_kVibrationPatternKey) ?? _vibrationPattern;
      _screenFlash = _prefs.getBool(_kScreenFlashKey) ?? _screenFlash;
      _availabilityReminder =
          _prefs.getBool(_kAvailabilityReminderKey) ?? _availabilityReminder;
      _skillMatchAlert =
          _prefs.getBool(_kSkillMatchKey) ?? _skillMatchAlert;
      _feedbackNotification =
          _prefs.getBool(_kFeedbackNotificationKey) ?? _feedbackNotification;
      _systemUpdateAlert =
          _prefs.getBool(_kSystemUpdateKey) ?? _systemUpdateAlert;
      _emergencyRingtone =
          _prefs.getString(_kEmergencyRingtoneKey) ?? _emergencyRingtone;
      _volumeOverride =
          _prefs.getBool(_kVolumeOverrideKey) ?? _volumeOverride;
    });

    // Fetch latest settings from Firestore Database
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('volunteer_settings')
          .doc(widget.userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _customRingtone = data['customRingtone'] ?? _customRingtone;
          _vibrationPattern = data['vibrationPattern'] ?? _vibrationPattern;
          _screenFlash = data['screenFlash'] ?? _screenFlash;
          _availabilityReminder =
              data['availabilityReminder'] ?? _availabilityReminder;
          _skillMatchAlert = data['skillMatchAlert'] ?? _skillMatchAlert;
          _feedbackNotification =
              data['feedbackNotification'] ?? _feedbackNotification;
          _systemUpdateAlert = data['systemUpdateAlert'] ?? _systemUpdateAlert;
          _emergencyRingtone = data['emergencyRingtone'] ?? _emergencyRingtone;
          _volumeOverride = data['volumeOverride'] ?? _volumeOverride;
        });
      }
    } catch (e) {
      debugPrint("Error fetching Firestore settings: $e");
    }
  }

  // 2. Save settings to both SharedPreferences and Firestore Database
  Future<void> _saveAllSettings() async {
    setState(() => _isLoading = true);

    try {
      // Save Locally
      await _prefs.setString(_kCustomRingtoneKey, _customRingtone);
      await _prefs.setString(_kVibrationPatternKey, _vibrationPattern);
      await _prefs.setBool(_kScreenFlashKey, _screenFlash);
      await _prefs.setBool(_kAvailabilityReminderKey, _availabilityReminder);
      await _prefs.setBool(_kSkillMatchKey, _skillMatchAlert);
      await _prefs.setBool(_kFeedbackNotificationKey, _feedbackNotification);
      await _prefs.setBool(_kSystemUpdateKey, _systemUpdateAlert);
      await _prefs.setString(_kEmergencyRingtoneKey, _emergencyRingtone);
      await _prefs.setBool(_kVolumeOverrideKey, _volumeOverride);

      // Fetch active FCM Token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Save Online to Firestore
      await FirebaseFirestore.instance
          .collection('volunteer_settings')
          .doc(widget.userId)
          .set({
        'userId': widget.userId,
        'fcmToken': fcmToken,
        'customRingtone': _customRingtone,
        'vibrationPattern': _vibrationPattern,
        'screenFlash': _screenFlash,
        'availabilityReminder': _availabilityReminder,
        'skillMatchAlert': _skillMatchAlert,
        'feedbackNotification': _feedbackNotification,
        'systemUpdateAlert': _systemUpdateAlert,
        'emergencyRingtone': _emergencyRingtone,
        'volumeOverride': _volumeOverride,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved & synced to Firestore!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved locally, but Firestore error: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _playRingtonePreview(String selection) {
    FlutterRingtonePlayer().stop();

    if (selection == 'Silent') return;

    switch (selection) {
      case 'Default Tone':
      case 'Classic Ring':
      case 'Soft Beep':
        FlutterRingtonePlayer().playRingtone();
        break;
      case 'Emergency Alert':
        FlutterRingtonePlayer().playAlarm();
        break;
      default:
        FlutterRingtonePlayer().playNotification();
    }

    Future.delayed(const Duration(seconds: 2), () {
      FlutterRingtonePlayer().stop();
    });
  }

  void _vibratePattern(String pattern) async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    switch (pattern) {
      case 'Short':
        Vibration.vibrate(duration: 200);
        break;
      case 'Long':
        Vibration.vibrate(duration: 800);
        break;
      case 'Short-Short':
        Vibration.vibrate(pattern: [0, 200, 100, 200]);
        break;
      case 'Short-Long-Short':
        Vibration.vibrate(pattern: [0, 200, 100, 800, 100, 200]);
        break;
    }
  }

  Future<void> _testCurrentSettings() async {
    _playRingtonePreview(_customRingtone);
    _vibratePattern(_vibrationPattern);
  }

  Future<void> _showRingtoneDialog({required bool emergency}) async {
    final current = emergency ? _emergencyRingtone : _customRingtone;
    final picked = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            emergency ? 'Choose Emergency Ringtone' : 'Choose Ringtone',
            style: const TextStyle(color: Color(0xFFBF5FFF)),
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          children: _ringtones.map((tone) {
            final isSelected = tone == current;
            return ListTile(
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? const Color(0xFFBF5FFF) : Colors.white70,
              ),
              title: Text(tone, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop(tone);
                _playRingtonePreview(tone);
              },
            );
          }).toList(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (emergency) {
          _emergencyRingtone = picked;
        } else {
          _customRingtone = picked;
        }
      });
    }
  }

  Future<void> _showVibrationDialog() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text(
            'Select Vibration Pattern',
            style: TextStyle(color: Color(0xFFBF5FFF)),
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          children: _vibrationPatterns.map((p) {
            return SimpleDialogOption(
              child: Text(p, style: const TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(p);
                _vibratePattern(p);
              },
            );
          }).toList(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _vibrationPattern = picked;
      });
    }
  }

  Widget sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget settingTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    String? subtitle,
  }) =>
      ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(color: Colors.white70))
            : null,
        trailing: trailing,
      );

  Widget toggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) =>
      SwitchListTile(
        secondary: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFBF5FFF),
      );

  Widget smallButton(String text, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFF2E2E2E),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    ),
  );

  Widget divider() => const Divider(color: Colors.grey);

  Widget emergencySection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purpleAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "3. Emergency Connection Settings",
            style: TextStyle(
              color: Colors.purpleAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          settingTile(
            icon: Icons.notifications_active,
            title: "Emergency Call Ringtone",
            subtitle: _emergencyRingtone,
            trailing: smallButton(
              "Choose Ringtone",
                  () => _showRingtoneDialog(emergency: true),
            ),
          ),
          toggleTile(
            icon: Icons.volume_up,
            title: "Volume Override",
            value: _volumeOverride,
            onChanged: (v) {
              setState(() => _volumeOverride = v);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF6A0DAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0,
          title: const Text(
            "Notification Features",
            style: TextStyle(color: Color(0xFFBF5FFF)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFBF5FFF)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterRingtonePlayer().stop();
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test Ringtone & Vibration'),
                onPressed: _testCurrentSettings,
              ),
            ),
            sectionTitle("1. Incoming Call Alerts"),
            settingTile(
              icon: Icons.music_note,
              title: "Custom Call Ringtone",
              subtitle: _customRingtone,
              trailing: smallButton(
                "Choose Ringtone",
                    () => _showRingtoneDialog(emergency: false),
              ),
            ),
            settingTile(
              icon: Icons.vibration,
              title: "Vibration Pattern",
              subtitle: _vibrationPattern,
              trailing: smallButton("Select Pattern", _showVibrationDialog),
            ),
            toggleTile(
              icon: Icons.flash_on,
              title: "Screen Flash Alert",
              value: _screenFlash,
              onChanged: (v) {
                setState(() => _screenFlash = v);
              },
            ),
            divider(),
            sectionTitle("2. System & Status Notifications"),
            toggleTile(
              icon: Icons.access_time,
              title: "Availability Status Reminder",
              value: _availabilityReminder,
              onChanged: (v) {
                setState(() => _availabilityReminder = v);
              },
            ),
            toggleTile(
              icon: Icons.verified,
              title: "Skill Match Alert",
              value: _skillMatchAlert,
              onChanged: (v) {
                setState(() => _skillMatchAlert = v);
              },
            ),
            toggleTile(
              icon: Icons.star_border,
              title: "Feedback/Rating Notification",
              value: _feedbackNotification,
              onChanged: (v) {
                setState(() => _feedbackNotification = v);
              },
            ),
            toggleTile(
              icon: Icons.system_update,
              title: "System Update Alert",
              value: _systemUpdateAlert,
              onChanged: (v) {
                setState(() => _systemUpdateAlert = v);
              },
            ),
            divider(),
            emergencySection(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF5FFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Syncing...' : 'Save All Settings',
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: _isLoading ? null : _saveAllSettings,
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}