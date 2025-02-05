import 'package:flutter/material.dart';

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
