import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicEditableField extends StatefulWidget {
  final TextInputType keyboardType;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String description;
  final bool isUpdatedTextLoaded;
  final int? maxLines;
  final int maxChars;
  final String hintText;

  const DynamicEditableField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.description,
    required this.isUpdatedTextLoaded,
    this.maxLines,
    required this.maxChars,
    required this.hintText
  });

  @override
  State<DynamicEditableField> createState() => _DynamicEditableFieldState();
}

class _DynamicEditableFieldState extends State<DynamicEditableField> {
  late ValueNotifier<int> _charCountNotifier;


  @override
  void initState() {
    super.initState();

    // Initialize the ValueNotifier with the current character count
    _charCountNotifier = ValueNotifier<int>(widget.maxChars - widget.controller.text.length);

    // Add a listener to the controller to update the character count dynamically
    widget.controller.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    _charCountNotifier.value = widget.maxChars - widget.controller.text.length;
  }

  @override
  void dispose() {
    _charCountNotifier.dispose();
    widget.controller.removeListener(_updateCharCount);

    super.dispose();
  }

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
            widget.isUpdatedTextLoaded
            // Text to edit
              ? TextField(
                keyboardType: widget.keyboardType,
                controller: widget.controller,
                focusNode: widget.focusNode,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    widget.maxChars,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced
                  )
                ],
                maxLines: widget.maxLines,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  overflow: TextOverflow.ellipsis
                ),
                cursorColor: Theme.of(context).colorScheme.inversePrimary,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary
                  )
                )
              )
              : Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.inversePrimary
                    )
                  )
                ]
              ),

            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Description
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.tertiary
                    )
                  ),

                  // Max characters
                  ValueListenableBuilder(
                    valueListenable: _charCountNotifier,
                    builder: (BuildContext context, int count, Widget? child) => Text(
                      _charCountNotifier.value.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: (count != 0)
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.error
                      )
                    )
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}