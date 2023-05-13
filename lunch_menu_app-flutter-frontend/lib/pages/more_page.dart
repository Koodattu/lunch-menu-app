import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/constants/app_settings_keys.dart';
import 'package:flutter_lunch_menu_app/model/request_result.dart';
import 'package:flutter_lunch_menu_app/oss_licenses.dart';
import 'package:flutter_lunch_menu_app/services/networking_service.dart';
import 'package:flutter_lunch_menu_app/services/snackbar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> with AutomaticKeepAliveClientMixin<MorePage> {
  late PackageInfo packageInfo;
  SharedPreferences? preferences;

  bool loaded = false;
  int tapCounter = 0;
  bool showMaintenance = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }

  void getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    preferences = await SharedPreferences.getInstance();
    showMaintenance = preferences!.getBool(appSettingMaintenance) ?? false;
    setState(() {
      loaded = true;
    });
  }

  void appIconTapped() async {
    tapCounter++;
    if (tapCounter == 9) {
      bool setValue = await preferences!.setBool(appSettingMaintenance, true);
      setState(() {
        showMaintenance = setValue;
      });
    }
  }

  void showLicensesDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("oss_licenses").tr(),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ListView.builder(
              itemCount: ossLicenses.length * 2,
              itemBuilder: ((context, i) {
                if (i.isOdd) {
                  return const Divider();
                }
                int index = i ~/ 2;
                Package license = ossLicenses[index];

                return ListTile(
                  title: Text(license.name),
                  subtitle: Text(license.version),
                  trailing: TextButton(
                    child: const Text("details").tr(),
                    onPressed: () => showLicenseDetails(license),
                  ),
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("close").tr(),
            ),
          ],
        );
      },
    );
  }

  Future showLicenseDetails(Package package) async {
    const double padding = 16;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("license_details").tr(),
          content: SizedBox(
            width: 300,
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(package.name),
                  const SizedBox(height: padding),
                  Text(package.description),
                  const SizedBox(height: padding),
                  Text(package.repository.toString()),
                  const SizedBox(height: padding),
                  Text(package.authors.join(", ")),
                  const SizedBox(height: padding),
                  Text(package.version),
                  const SizedBox(height: padding),
                  Text(package.license.toString()),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("close").tr(),
            ),
          ],
        );
      },
    );
  }

  openFileInCloud() {
    launchUrlString(
      "https://docs.google.com/document/d/1ejQntnQPCHiajV_CLB6Un9AUElxzyOP4/",
      mode: LaunchMode.externalApplication,
    );
  }

  sendEmailFeedback() {
    final Uri emailLaunchUri = Uri(
      scheme: "mailto",
      path: "alarantala.juha@gmail.com",
      query: encodeQueryParameters({"subject": "feedback_email_subject".tr()}),
    );

    launchUrlString(emailLaunchUri.toString());
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }

  openPlayStorePage() {
    StoreRedirect.redirect();
  }

  Future openAppSettings(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsView()));
  }

  Future openAppMaintenance(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AppMaintenanceView()));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: appIconTapped,
                      child: const SizedBox(
                        width: 128,
                        height: 128,
                        child: Image(
                          image: AssetImage("assets/app_icon.png"),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 128,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "application".tr().toUpperCase(),
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              Text("lunch_menu_app".tr()),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "developer".tr().toUpperCase(),
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const Text("Juha Ala-Rantala"),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "version".toUpperCase(),
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              Text(
                                loaded ? "${packageInfo.version}+${packageInfo.buildNumber}" : "retrieving".tr(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              InteractableCard(
                voidCallback: () => openAppSettings(context),
                title: "settings".tr(),
                subTitle: "change_settings".tr(),
                iconData: Icons.settings,
              ),
              InteractableCard(
                voidCallback: openFileInCloud,
                title: "menu_in_cloud".tr(),
                subTitle: "open_menu_in_browser".tr(),
                iconData: Icons.cloud,
              ),
              InteractableCard(
                voidCallback: sendEmailFeedback,
                title: "feedback".tr(),
                subTitle: "send_feedback".tr(),
                iconData: Icons.email,
              ),
              InteractableCard(
                voidCallback: openPlayStorePage,
                title: "rate_application".tr(),
                subTitle: "open_store_page".tr(),
                iconData: Icons.play_arrow,
              ),
              InteractableCard(
                voidCallback: showLicensesDialog,
                title: "oss_licenses".tr(),
                subTitle: "show_licenses".tr(),
                iconData: Icons.info,
              ),
              if (showMaintenance)
                InteractableCard(
                  voidCallback: () => openAppMaintenance(context),
                  title: "maintenance".tr(),
                  subTitle: "open_app_maintenance".tr(),
                  iconData: Icons.admin_panel_settings,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class InteractableCard extends StatelessWidget {
  const InteractableCard({
    super.key,
    required this.voidCallback,
    required this.title,
    required this.subTitle,
    required this.iconData,
  });

  final VoidCallback voidCallback;
  final String title;
  final String subTitle;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: voidCallback,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    subTitle,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
              Icon(iconData),
            ],
          ),
        ),
      ),
    );
  }
}

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
                      settingKey: appSettingShowToday,
                      sharedPreferences: _prefs,
                      defaultValue: true,
                    ),
                    SettingToggleCard(
                      settingTitle: "show_tomorrow".tr(),
                      settingKey: appSettingShowTomorrow,
                      sharedPreferences: _prefs,
                      defaultValue: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "testing".tr(),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    SettingToggleCard(
                      settingTitle: "use_mock_data".tr(),
                      settingKey: appSettingMockData,
                      sharedPreferences: _prefs,
                      defaultValue: false,
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
        onTap: () {
          context.setLocale(Locale(context.locale.toString() == "en" ? "fi" : "en"));
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
  const SettingToggleCard({
    super.key,
    required this.settingTitle,
    required this.settingKey,
    required this.sharedPreferences,
    required this.defaultValue,
  });

  final String settingTitle;
  final String settingKey;
  final SharedPreferences sharedPreferences;
  final bool defaultValue;

  @override
  State<SettingToggleCard> createState() => _SettingToggleCardState();
}

class _SettingToggleCardState extends State<SettingToggleCard> {
  bool value = true;

  @override
  void initState() {
    super.initState();
    value = widget.defaultValue;
    setState(() {
      value = widget.sharedPreferences.getBool(widget.settingKey) ?? widget.defaultValue;
    });
  }

  void toggleSetting() async {
    await widget.sharedPreferences.setBool(widget.settingKey, !value);
    setState(() {
      value = widget.sharedPreferences.getBool(widget.settingKey) ?? widget.defaultValue;
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

class AppMaintenanceView extends StatefulWidget {
  const AppMaintenanceView({super.key});

  @override
  State<AppMaintenanceView> createState() => _AppMaintenanceViewState();
}

class _AppMaintenanceViewState extends State<AppMaintenanceView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("maintenance").tr(),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          DynamicRequestCard(
            title: "fetch_menu".tr(),
            subtitle: "force_fetch_menu".tr(),
            icon: Icons.update,
            requestType: RestApiType.updateMenu,
          ),
          DynamicRequestCard(
            title: "clear_cache".tr(),
            subtitle: "force_clear_cache".tr(),
            icon: Icons.cached,
            requestType: RestApiType.clearCache,
          ),
        ]),
      ),
    );
  }
}

class DynamicRequestCard extends StatefulWidget {
  const DynamicRequestCard(
      {super.key, required this.title, required this.subtitle, required this.icon, required this.requestType});

  final String title;
  final String subtitle;
  final IconData icon;
  final RestApiType requestType;

  @override
  State<DynamicRequestCard> createState() => _DynamicRequestCardState();
}

class _DynamicRequestCardState extends State<DynamicRequestCard> {
  bool loading = false;

  void sendGetRequest() async {
    setState(() {
      loading = true;
    });

    NetworkingService networkingService = NetworkingService();
    var response = await networkingService.getFromApi(widget.requestType);

    SnackBarService snackBarService = SnackBarService();
    if (response is RequestResult && response.result) {
      snackBarService.showSnackBar("success".tr(), Colors.green, Colors.white, Icons.check, true);
    } else {
      snackBarService.showSnackBar("error".tr(), Colors.red, Colors.black, Icons.error, true);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: sendGetRequest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.subtitle,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
              loading ? const CircularProgressIndicator() : Icon(widget.icon),
            ],
          ),
        ),
      ),
    );
  }
}
