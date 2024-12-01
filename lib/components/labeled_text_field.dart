import 'package:flutter/material.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final bool autocorrect;
  final bool obscureText;
  final TextInputType inputType;

  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const LabeledTextField({
    super.key,
    required this.label,
    this.autocorrect = false,
    this.obscureText = false,
    required this.inputType,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8.0),
        TextField(
          autocorrect: autocorrect,
          keyboardType: inputType,
          enableSuggestions: autocorrect,
          obscureText: obscureText,
          controller: controller,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
