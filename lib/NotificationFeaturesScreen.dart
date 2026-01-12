import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart'; // 🔹 For vibration feedback

class NotificationFeaturesScreen extends StatefulWidget {
  const NotificationFeaturesScreen({super.key});

  @override
  State<NotificationFeaturesScreen> createState() =>
      _NotificationFeaturesScreenState();
}

class _NotificationFeaturesScreenState
    extends State<NotificationFeaturesScreen> {
  static const _kCustomRingtoneKey = 'custom_ringtone';
  static const _kVibrationPatternKey = 'vibration_pattern';
  static const _kScreenFlashKey = 'screen_flash';
  static const _kAvailabilityReminderKey = 'availability_reminder';
  static const _kSkillMatchKey = 'skill_match_alert';
  static const _kFeedbackNotificationKey = 'feedback_notification';
  static const _kSystemUpdateKey = 'system_update_alert';
  static const _kEmergencyRingtoneKey = 'emergency_ringtone';
  static const _kVolumeOverrideKey = 'volume_override';

  String _customRingtone = 'Default Tone';
  String _vibrationPattern = 'Short';
  bool _screenFlash = false;

  bool _availabilityReminder = true;
  bool _skillMatchAlert = true;
  bool _feedbackNotification = false;
  bool _systemUpdateAlert = true;

  String _emergencyRingtone = 'Emergency Alert';
  bool _volumeOverride = true;

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
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _customRingtone =
          _prefs.getString(_kCustomRingtoneKey) ?? _customRingtone;
      _vibrationPattern =
          _prefs.getString(_kVibrationPatternKey) ?? _vibrationPattern;
      _screenFlash = _prefs.getBool(_kScreenFlashKey) ?? _screenFlash;

      _availabilityReminder =
          _prefs.getBool(_kAvailabilityReminderKey) ?? _availabilityReminder;
      _skillMatchAlert = _prefs.getBool(_kSkillMatchKey) ?? _skillMatchAlert;
      _feedbackNotification =
          _prefs.getBool(_kFeedbackNotificationKey) ?? _feedbackNotification;
      _systemUpdateAlert =
          _prefs.getBool(_kSystemUpdateKey) ?? _systemUpdateAlert;

      _emergencyRingtone =
          _prefs.getString(_kEmergencyRingtoneKey) ?? _emergencyRingtone;
      _volumeOverride = _prefs.getBool(_kVolumeOverrideKey) ?? _volumeOverride;
    });
  }

  Future<void> _saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
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
    // 🔹 Play current ringtone
    _playRingtonePreview(_customRingtone);

    // 🔹 Vibrate current pattern
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
                _playRingtonePreview(tone); // 🔹 play immediately
              },
            );
          }).toList(),
          backgroundColor: const Color(0xFF1E1E1E),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (emergency) {
          _emergencyRingtone = picked;
          _saveString(_kEmergencyRingtoneKey, picked);
        } else {
          _customRingtone = picked;
          _saveString(_kCustomRingtoneKey, picked);
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
          children: _vibrationPatterns.map((p) {
            return SimpleDialogOption(
              child: Text(p, style: const TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(p);
                _vibratePattern(p); // 🔹 vibrate immediately
              },
            );
          }).toList(),
          backgroundColor: const Color(0xFF1E1E1E),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _vibrationPattern = picked;
        _saveString(_kVibrationPatternKey, picked);
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
        onChanged: (v) => onChanged(v),
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
              _saveBool(_kVolumeOverrideKey, v);
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
                onPressed: _testCurrentSettings, // 🔹 new test button
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
                _saveBool(_kScreenFlashKey, v);
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
                _saveBool(_kAvailabilityReminderKey, v);
              },
            ),
            toggleTile(
              icon: Icons.verified,
              title: "Skill Match Alert",
              value: _skillMatchAlert,
              onChanged: (v) {
                setState(() => _skillMatchAlert = v);
                _saveBool(_kSkillMatchKey, v);
              },
            ),
            toggleTile(
              icon: Icons.star_border,
              title: "Feedback/Rating Notification",
              value: _feedbackNotification,
              onChanged: (v) {
                setState(() => _feedbackNotification = v);
                _saveBool(_kFeedbackNotificationKey, v);
              },
            ),
            toggleTile(
              icon: Icons.system_update,
              title: "System Update Alert",
              value: _systemUpdateAlert,
              onChanged: (v) {
                setState(() => _systemUpdateAlert = v);
                _saveBool(_kSystemUpdateKey, v);
              },
            ),
            divider(),
            emergencySection(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save All Settings'),
                onPressed: () {
                  _saveString(_kCustomRingtoneKey, _customRingtone);
                  _saveString(_kVibrationPatternKey, _vibrationPattern);
                  _saveBool(_kScreenFlashKey, _screenFlash);
                  _saveBool(_kAvailabilityReminderKey, _availabilityReminder);
                  _saveBool(_kSkillMatchKey, _skillMatchAlert);
                  _saveBool(_kFeedbackNotificationKey, _feedbackNotification);
                  _saveBool(_kSystemUpdateKey, _systemUpdateAlert);
                  _saveString(_kEmergencyRingtoneKey, _emergencyRingtone);
                  _saveBool(_kVolumeOverrideKey, _volumeOverride);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved')),
                  );
                },
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
