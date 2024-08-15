import 'package:flutter/material.dart';
import 'package:store_navigator/utils/data/store.dart';
import 'package:store_navigator/utils/icons.dart';

class StoreTile extends StatelessWidget {
  final Store store;
  final void Function() onTap;
  final bool isSelected;

  const StoreTile(
      {required this.store,
      required this.onTap,
      this.isSelected = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 36),
      leading: CustomIcons.store(size: 24),
      tileColor: isSelected ? Colors.grey[300] : null,
      title: Text(
        store.name,
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(fontWeight: FontWeight.w700),
      ),
      // TODO: description/subtitle is store address
      onTap: onTap,
    );
  }
}
