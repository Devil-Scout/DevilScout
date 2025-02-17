import 'package:flutter/material.dart';

import '../router.dart';
import 'full_width.dart';

class ActionDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget actionButton;
  final bool canCancel;

  const ActionDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actionButton,
    this.canCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.7)),
      icon: Icon(
        Icons.error_outline,
        size: 40,
        color: Theme.of(context).colorScheme.onSurface,
      ),
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
