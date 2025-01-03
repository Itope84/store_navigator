import 'package:cached_network_image/cached_network_image.dart';
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
        leading: SizedBox(
          width: 48,
          height: 48,
          child: CachedNetworkImage(
            imageUrl: item.product.image ?? '',
            errorWidget: (ctx, exc, obj) {
              // TODO: placeholder image
              return const Placeholder();
            },
            placeholder: (ctx, _) {
              return const Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(),
                ),
              );
            },
            memCacheHeight: 80,
            memCacheWidth: 80,
            fadeInDuration: const Duration(milliseconds: 300),
          ),
        ),
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
