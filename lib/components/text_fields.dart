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
        const SizedBox(height: 8),
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

class SearchableTextField extends StatelessWidget {
  final TextEditingController controller;

  final String hintText;

  const SearchableTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, size: 18),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, child) =>
              value.text.isEmpty ? const SizedBox.shrink() : child!,
          child: IconButton(
            onPressed: controller.clear,
            icon: const Icon(Icons.clear),
            iconSize: 18,
          ),
        ),
      ),
    );
  }
}
