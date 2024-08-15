import 'package:flutter/material.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/widgets/product_qty.dart';

class ShoppingListItemTile extends StatelessWidget {
  final ShoppingListItem item;
  final Function() onAddProduct;
  final Function() onReduceProduct;

  const ShoppingListItemTile(this.item,
      {required this.onReduceProduct, required this.onAddProduct, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          print('tapped the whole thing');
        },
        leading: const SizedBox(width: 48, height: 48, child: Placeholder()),
        title: Text(
          item.product.name!,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        subtitle: Text('£ ${item.product.price! * item.qty}'),
        trailing: SizedBox(
          width: 100,
          height: 40,
          child: ProductQtyController(
              qty: item.qty,
              onAddProduct: onAddProduct,
              onRemoveProduct: onReduceProduct),
        ));
  }
}
