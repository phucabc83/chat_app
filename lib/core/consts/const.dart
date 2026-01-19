
import 'package:flutter/material.dart';
double getWidth(context) => MediaQuery.of(context).size.width;
double getHeight(context) => MediaQuery.of(context).size.height;
double paddingCustom(context) => getWidth(context) * 0.05;

void hideKeyboard(context) {
  FocusScope.of(context).unfocus();
}

void showKeyboard(context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

void showMessageSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black87,
    ),
  );
}
