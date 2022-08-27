import 'dart:developer';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';

bool showSnackBar(BuildContext context, String title,
    {Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onPressedAction}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    log("can't find ScaffoldMessenger, showSnackBar failed");
    return false;
  }
  final snackBar = SnackBar(
    content: Text(
      title,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.grey[900],
    duration: duration,
    behavior: SnackBarBehavior.floating,
    action: actionLabel.isNullOrEmpty() || onPressedAction == null
        ? null
        : SnackBarAction(
            textColor: Theme.of(context).colorScheme.secondary,
            label: actionLabel!,
            onPressed: onPressedAction,
          ),
  );
  messenger.showSnackBar(snackBar);
  return true;
}
