import 'package:flutter/material.dart';

class BottomSheetAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Function()? onPop;

  @override
  final Size preferredSize = const Size.fromHeight(86);

  const BottomSheetAppBar({super.key, this.title, this.onPop});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: 86,
      title: Padding(
        padding: const EdgeInsets.only(top: 46),
        child: title,
      ),
      leading: Container(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 46),
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (onPop != null) {
                onPop!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ],
    );
  }
}
