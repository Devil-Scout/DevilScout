import 'package:flutter/material.dart';

class SearchableTextField extends StatefulWidget {
  final TextEditingController controller;

  final String hintText;

  const SearchableTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  State<SearchableTextField> createState() => SearchableTextFieldState();
}

class SearchableTextFieldState extends State<SearchableTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: (value) => setState(() {}),
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, size: 18.0),
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        suffixIcon: widget.controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    widget.controller.clear();
                  });
                },
                icon: Icon(Icons.clear),
                iconSize: 18.0,
              ),
      ),
    );
  }
}
