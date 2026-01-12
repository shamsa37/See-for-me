import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'VolunteerDashboard.dart'; // For ThemeOption enum

enum DataUsageOption { WifiOnly, MobileData }

class VolunteerSettingsPage extends StatefulWidget {
  final ThemeOption themeOption;
  final ValueChanged<ThemeOption> onThemeChanged;

  const VolunteerSettingsPage({
    Key? key,
    required this.themeOption,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<VolunteerSettingsPage> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<VolunteerSettingsPage> {
  // Persistent states
  bool isOnline = true;
  bool doNotDisturb = false;
  DataUsageOption dataUsage = DataUsageOption.WifiOnly;
  bool showOnlineStatus = true;
  bool showProfilePicture = true;

  // Skills
  final List<String> skillsList = [
    'Medical Help',
    'Navigation Assistance',
    'Translation',
    'Emergency Handling',
  ];
  Map<String, bool> skillsSelected = {};

  // About
  final String developerEmail = 'kanwalshah720@gmail.com';
  final String appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    for (var s in skillsList) skillsSelected[s] = false;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isOnline = prefs.getBool('is_online') ?? true;
      doNotDisturb = prefs.getBool('dnd') ?? false;
      final du = prefs.getString('data_usage') ?? 'WifiOnly';
      dataUsage = du == 'MobileData' ? DataUsageOption.MobileData : DataUsageOption.WifiOnly;
      showOnlineStatus = prefs.getBool('show_online_status') ?? true;
      showProfilePicture = prefs.getBool('show_profile_picture') ?? true;

      final savedSkills = prefs.getStringList('skills_selected') ?? [];
      for (var s in skillsList) skillsSelected[s] = savedSkills.contains(s);
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_online', isOnline);
    await prefs.setBool('dnd', doNotDisturb);
    await prefs.setString('data_usage', dataUsage == DataUsageOption.MobileData ? 'MobileData' : 'WifiOnly');
    await prefs.setBool('show_online_status', showOnlineStatus);
    await prefs.setBool('show_profile_picture', showProfilePicture);
    final selectedSkills = skillsSelected.entries.where((e) => e.value).map((e) => e.key).toList();
    await prefs.setStringList('skills_selected', selectedSkills);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Availability & Status
              _buildSectionCard(
                title: 'Availability & Status',
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Online'),
                      subtitle: Text(isOnline ? 'You are available' : 'You are offline'),
                      trailing: Switch(
                        value: isOnline,
                        onChanged: (v) {
                          setState(() => isOnline = v);
                          _savePreferences();
                        },
                      ),
                    ),
                    const Divider(),
                    Align(alignment: Alignment.centerLeft, child: Text('Skills', style: theme.textTheme.bodyMedium)),
                    const SizedBox(height: 8),
                    ...skillsList.map((s) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s),
                        value: skillsSelected[s] ?? false,
                        onChanged: (v) {
                          setState(() => skillsSelected[s] = v ?? false);
                          _savePreferences();
                        },
                      );
                    }),
                  ],
                ),
              ),

              // Do Not Disturb
              _buildSectionCard(
                title: 'Do Not Disturb (DND)',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('Only emergency alerts will be allowed while DND is ON.')),
                    Switch(
                      value: doNotDisturb,
                      onChanged: (v) {
                        setState(() => doNotDisturb = v);
                        _savePreferences();
                      },
                    ),
                  ],
                ),
              ),

              // Data Usage
              _buildSectionCard(
                title: 'Data Usage',
                child: Column(
                  children: [
                    RadioListTile<DataUsageOption>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('WiFi Only'),
                      value: DataUsageOption.WifiOnly,
                      groupValue: dataUsage,
                      onChanged: (v) {
                        setState(() => dataUsage = v!);
                        _savePreferences();
                      },
                    ),
                    RadioListTile<DataUsageOption>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mobile Data Allowed'),
                      value: DataUsageOption.MobileData,
                      groupValue: dataUsage,
                      onChanged: (v) {
                        setState(() => dataUsage = v!);
                        _savePreferences();
                      },
                    ),
                  ],
                ),
              ),

              // Theme
              _buildSectionCard(
                title: 'Theme',
                child: Column(
                  children: [
                    Text('Choose Theme Mode', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    ToggleButtons(
                      isSelected: ThemeOption.values.map((e) => e == widget.themeOption).toList(),
                      borderRadius: BorderRadius.circular(8),
                      onPressed: (index) {
                        final option = ThemeOption.values[index];
                        widget.onThemeChanged(option);
                        setState(() {});
                      },
                      children: ThemeOption.values.map((e) {
                        final label = e.toString().split('.').last;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Text(label),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Dark: Black + Purple accents\nLight: White + Purple accents\nDefault: App colors (current)'),
                    ),
                  ],
                ),
              ),

              // Privacy Controls
              _buildSectionCard(
                title: 'Privacy Controls',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show Online Status'),
                      value: showOnlineStatus,
                      onChanged: (v) {
                        setState(() => showOnlineStatus = v);
                        _savePreferences();
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show Profile Picture'),
                      value: showProfilePicture,
                      onChanged: (v) {
                        setState(() => showProfilePicture = v);
                        _savePreferences();
                      },
                    ),
                  ],
                ),
              ),

              // About App
              _buildSectionCard(
                title: 'About App',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Version: $appVersion'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Email: $developerEmail')));
                      },
                      child: Text('Developer: $developerEmail', style: const TextStyle(decoration: TextDecoration.underline)),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Terms & Conditions'),
                            content: const Text('Terms and conditions go here.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                      child: const Text('Terms & Conditions'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: _savePreferences,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
