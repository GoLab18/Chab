import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final TextInputType keyboardType;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String description;
  final bool isUpdatedTextLoaded;

  const EditableField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.description,
    required this.isUpdatedTextLoaded
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 10
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary
          ),
          borderRadius: BorderRadius.circular(8)
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isUpdatedTextLoaded
            
            // Text to edit
            ? EditableText(
              keyboardType: keyboardType,
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.inversePrimary,
                overflow: TextOverflow.ellipsis
              ),
              cursorColor: Theme.of(context).colorScheme.inversePrimary,
              backgroundCursorColor: Theme.of(context).colorScheme.tertiary
            )
            : Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.inversePrimary
                  ),
                ),
              ],
            ),

            // Description
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.tertiary
                )
              )
            )
          ]
        )
      )
    );
  }
}