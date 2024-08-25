import 'package:flutter/material.dart';
import 'package:store_navigator/widgets/bottom_sheet_appbar.dart';
import 'package:store_navigator/widgets/text_input.dart';

Future<String?> openShoppingListTextInput(BuildContext context,
    [String? initialText]) async {
  final controller = TextEditingController(text: initialText);
  return showModalBottomSheet<String>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: BottomSheetAppBar(
            title: const Text('Paste Shopping List'),
            onPop: () {
              Navigator.of(context).pop();
            },
          ),
          body: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                RoundedMaterialTextFormField(
                  keyboardType: TextInputType.multiline,
                  hintText: "Put each item on a new line...",
                  textInputAction: TextInputAction.newline,
                  minLines: 8,
                  maxLines: 8,
                  controller: controller,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        );
      });
}
