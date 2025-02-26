import 'package:flutter/material.dart';

class FullWidth extends StatelessWidget {
  final Widget? leading;
  final Widget child;

  const FullWidth({
    super.key,
    required this.child,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: leading,
          ),
        Expanded(child: child),
      ],
    );
  }
}
