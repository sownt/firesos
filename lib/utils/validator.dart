import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(msg: message);
    backgroundColor: Colors.black;
  }

  static void flushBarErrorMessage(String message, BuildContext context) {
    showFlushbar(
        context: context,
        flushbar: Flushbar(
          message: message,
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(15),
          forwardAnimationCurve: Curves.decelerate,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.shade900,
          reverseAnimationCurve: Curves.easeInOut,
          positionOffset: 20,
          borderRadius: BorderRadius.circular(20),
          icon: const Icon(
            Icons.error,
            size: 28,
            color: Colors.white,
          ),
        )..show(context));
  }

  static snackBar(String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(

            backgroundColor: Colors.red[900],
            content: Text(
              message,
            )));
  }
}
