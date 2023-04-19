import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsView extends StatefulWidget {
  const AppSettingsView({super.key});

  @override
  State<AppSettingsView> createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<AppSettingsView> {
  late final SharedPreferences _prefs;
  late final _prefsFuture = SharedPreferences.getInstance().then((v) => _prefs = v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr()),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<SharedPreferences>(
        future: _prefsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "app".tr(),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    LanguageToggleCard(
                      settingTitle: "change_language".tr(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "menu".tr(),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    SettingToggleCard(
                      settingTitle: "show_today".tr(),
                      settingKey: "app_settings_menu_show_today",
                      sharedPreferences: _prefs,
                    ),
                    SettingToggleCard(
                      settingTitle: "show_tomorrow".tr(),
                      settingKey: "app_settings_menu_show_tomorrow",
                      sharedPreferences: _prefs,
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class LanguageToggleCard extends StatefulWidget {
  const LanguageToggleCard({super.key, required this.settingTitle});

  final String settingTitle;

  @override
  State<LanguageToggleCard> createState() => _LanguageToggleCardState();
}

class _LanguageToggleCardState extends State<LanguageToggleCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          await context.setLocale(Locale(context.locale.toString() == "en" ? "fi" : "en"));
          WidgetsFlutterBinding.ensureInitialized().performReassemble();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.settingTitle,
                style: const TextStyle(fontSize: 16),
              ),
              if (context.locale.toString() == "en")
                const Text(
                  "🇬🇧 🇺🇸",
                  style: TextStyle(fontSize: 36),
                ),
              if (context.locale.toString() == "fi")
                const Text(
                  "🇫🇮",
                  style: TextStyle(fontSize: 36),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingToggleCard extends StatefulWidget {
  const SettingToggleCard(
      {super.key, required this.settingTitle, required this.settingKey, required this.sharedPreferences});

  final String settingTitle;
  final String settingKey;
  final SharedPreferences sharedPreferences;

  @override
  State<SettingToggleCard> createState() => _SettingToggleCardState();
}

class _SettingToggleCardState extends State<SettingToggleCard> {
  bool value = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      value = widget.sharedPreferences.getBool(widget.settingKey) ?? false;
    });
  }

  void toggleSetting() async {
    await widget.sharedPreferences.setBool(widget.settingKey, !value);
    setState(() {
      value = widget.sharedPreferences.getBool(widget.settingKey) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: toggleSetting,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.settingTitle,
                style: const TextStyle(fontSize: 16),
              ),
              IgnorePointer(
                child: Switch(
                  value: value,
                  onChanged: ((value) => {}),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
