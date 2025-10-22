import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final authController = AuthController(ApiServive(), StorageService());

class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }

  static String convertNumber(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }
}

void showGlobalSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

void showExpiredTokenDialog({
  required BuildContext context,
  VoidCallback? onConfirm
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Set to false to make it non-dismissible
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text("Session Expired"),
          ],
        ),
        content: const Text(
          "Your session has expired. Please log in again to continue.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          // TextButton(
          //   onPressed: () {
          //     Navigator.pop(context); // Close the dialog
          //   },
          //   child: Text("Cancel"),
          // ),
          ElevatedButton(
            onPressed: () async {
              await authController.logout();
              GoRouter.of(context).go('/login');
              // Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
            },
            child: Text("Log In", style: TextStyle(color: Colors.black),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showLoadingDialog({
  required BuildContext context,
  String message = "Loading...",
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Set to false to make it non-dismissible
    builder: (context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.all(0),
        backgroundColor: const Color(0xFFF5F5F5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 4.0,
              backgroundColor: Color(0xFFe1e1e1),
              color: Color(0xFFFFFFFF),
            ),
            const SizedBox(height: 16),
            Text(message,
                style: TextStyle(fontSize: 16, color: Colors.grey[800])),
          ],
        ),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

void showGlobalAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onCancel != null) onCancel();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

void shoMyBadDialog({
  required BuildContext context,
  required String title,
  required String message
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

String getInitials(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0])
        .join()
        .toUpperCase(); // Optional: make it uppercase
    }

String formatTimeOfDay(TimeOfDay tod, {String pattern = "HH:mm:ss"}) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  return DateFormat(pattern).format(dt);
}