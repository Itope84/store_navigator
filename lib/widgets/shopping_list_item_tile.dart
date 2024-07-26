import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';

class ShoppingListItemTile extends StatelessWidget {
  final ShoppingListItem item;
  final Function() onDelete;

  const ShoppingListItemTile(this.item, {required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        print('tapped the whole thing');
      },
      leading: SizedBox(width: 48, height: 48, child: Placeholder()),
      title: Text(
        item.product.name!,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 24),
      subtitle: Text("${item.qty} units"),
      trailing: IconButton(onPressed: onDelete, icon: Icon(Icons.delete)),
    );
  }
}
