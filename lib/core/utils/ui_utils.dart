import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Ui_utils{
  static void showSnakeBar(
      BuildContext context, {
        required String message,
        bool isError = false,
        Duration duration = const Duration(seconds: 2),
      }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Text(
          message,
          style: TextStyle(
            color: isError?Color(0xffA0153E): Color(0xff27391C),
          ),
        ),
        backgroundColor: isError ? Color(0xffFFCACC).withOpacity(0.5) : Color(0xffD0E8C5).withOpacity(0.5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }
}