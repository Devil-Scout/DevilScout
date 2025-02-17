import 'package:flutter/material.dart';

import '../router.dart';
import 'full_width.dart';

class ActionDialog extends StatelessWidget {
  final String title;
  final Widget? icon;
  final Widget content;
  final Widget actionButton;
  final bool canCancel;

  const ActionDialog({
    super.key,
    this.icon,
    required this.title,
    required this.content,
    required this.actionButton,
    this.canCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.7)),
      icon: icon,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const Padding(
            padding: EdgeInsets.all(8),
            child: Divider(),
          ),
          FullWidth(child: actionButton),
          if (canCancel)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FullWidth(
                child: OutlinedButton(
                  onPressed: router.pop,
                  child: const Text('Cancel'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TextDialog extends StatelessWidget {
  final String title;
  final String message;
  final Widget? icon;

  const TextDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ActionDialog(
      title: title,
      icon: icon,
      content: Text(message),
      actionButton: ElevatedButton(
        onPressed: router.pop,
        child: const Text('Okay'),
      ),
      canCancel: false,
    );
  }
}

class UnexpectedErrorDialog extends StatelessWidget {
  final String title;
  const UnexpectedErrorDialog({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return TextDialog(
      icon: const Icon(
        Icons.error_outline,
        size: 40,
      ),
      title: title,
      message: 'An unexpected error occured. Please try again later.',
    );
  }
}
