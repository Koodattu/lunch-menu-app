import 'dart:ffi';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/pages/views/app_settings_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  late PackageInfo packageInfo;

  bool loaded = false;

  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }

  void getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      loaded = true;
    });
  }

  openFileInCloud() {
    launchUrlString("https://docs.google.com/document/d/1ejQntnQPCHiajV_CLB6Un9AUElxzyOP4/",
        mode: LaunchMode.externalApplication);
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsView()));
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(
                      width: 128,
                      height: 128,
                      child: Image(
                        image: AssetImage("assets/app_icon.png"),
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
                voidCallback: () => {},
                title: "licenses".tr(),
                subTitle: "show_licenses".tr(),
                iconData: Icons.info,
              )
            ],
          )
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
