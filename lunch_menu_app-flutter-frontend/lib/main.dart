import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/lunch_menu_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale("en"), Locale("fi")],
      path: "assets/translations",
      fallbackLocale: const Locale("en"),
      child: const LunchMenuApp(),
    ),
  );
}
