import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/lunch_menu_app.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale("en"), Locale("fi")],
      path: "assets/translations",
      fallbackLocale: const Locale("en"),
      child: ChangeNotifierProvider(
        create: (context) => UserSavedVoteModel(),
        child: const LunchMenuApp(),
      ),
    ),
  );
}
