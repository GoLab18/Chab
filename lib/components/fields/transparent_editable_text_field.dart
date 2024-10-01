import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransparentEditableTextField extends StatefulWidget {
  final String initialText;
  final bool isUpdatedTextLoaded;
  final void Function() onSubmission;
  final int? maxLines;

  const TransparentEditableTextField({
    super.key,
    required this.initialText,
    required this.isUpdatedTextLoaded,
    required this.onSubmission,
    this.maxLines = 1
  });

  @override
  State<TransparentEditableTextField> createState() => _TransparentEditableTextFieldState();
}

class _TransparentEditableTextFieldState extends State<TransparentEditableTextField> {
  late TextEditingController controller;
  late FocusNode focusNode;
  
  bool isEdited = false;

  // Initially the field can't be empty, thus the value is true
  bool isOperationGranted = true;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.initialText)
      ..addListener(handleEmptyTextField);

    focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant TransparentEditableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isUpdatedTextLoaded && widget.initialText != oldWidget.initialText && !isEdited) {
      controller.text = widget.initialText;
    }
  }

  void handleEmptyTextField() {
    bool previousIsOperationGranted = isOperationGranted;
    isOperationGranted = controller.text.isNotEmpty;

    if (previousIsOperationGranted != isOperationGranted) setState(() {});
  }

  void startEdit() {
    setState(() {
      isEdited = true;
      focusNode.requestFocus();
    });
  }

  void editFinished() {
    focusNode.unfocus();

    if (controller.text != widget.initialText) {
      widget.onSubmission();
    }

    setState(() {
      isEdited = false;
    });
  }

  void editCanceled() {
    setState(() {
      isEdited = false;
      FocusScope.of(context).unfocus();
      
      controller.text = widget.initialText;
    });
  }

  @override
  void dispose() {
    controller.removeListener(handleEmptyTextField);
    controller.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: widget.isUpdatedTextLoaded
            ? TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: !isEdited,
              maxLines: widget.maxLines,
              onSubmitted: (_) => editFinished(),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
                overflow: TextOverflow.ellipsis
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(50)
              ],
              cursorColor: Theme.of(context).colorScheme.inversePrimary,
              decoration: const InputDecoration.collapsed(hintText: "")
            )
            : SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.inversePrimary
              )
            )
        ),

        // Utility buttons
        Row(
          children: [
            // Cancel button
            if (isEdited) SizedBox.square(
              dimension: 30,
              child: IconButton(
                onPressed: editCanceled,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.cancel_outlined,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  size: 18
                )
              )
            ),

            // Edit/Submit button
            SizedBox.square(
              dimension: 30,
              child: IconButton(
                onPressed: isEdited
                  ? isOperationGranted
                    ? editFinished
                    : null
                  : startEdit,
                padding: EdgeInsets.zero,
                icon: Icon(
                  isEdited
                    ? Icons.check_outlined
                    : Icons.edit_outlined,
                  color: isEdited
                    ? isOperationGranted
                      ? Theme.of(context).colorScheme.inversePrimary
                      : Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.tertiary,
                  size: 18
                )
              )
            )
          ]
        )
      ]
    );
  }
}