import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

class SnackBarService {
  void showSnackBar(String text, Color snackBarColor, Color textColor, IconData iconData, bool clearSnackBars) {
    Card card = Card(
      color: Color(snackBarColor.value + 50),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          iconData,
        ),
      ),
    );

    SnackBar snackBar = SnackBar(
      duration: const Duration(seconds: 2),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          card,
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
          ),
          card,
        ],
      ),
      backgroundColor: Color(snackBarColor.value),
    );

    if (clearSnackBars) {
      snackbarKey.currentState?.clearSnackBars();
    }
    snackbarKey.currentState?.showSnackBar(snackBar);
  }
}
