import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';

class TinyFab extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final bool isFilled;
  const TinyFab(
      {required this.icon,
      required this.onPressed,
      this.isFilled = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: FittedBox(
        child: IconButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: isFilled
                ? WidgetStateProperty.all(
                    Theme.of(context).primaryColor.withAlpha(30))
                : WidgetStateProperty.all(
                    Theme.of(context).scaffoldBackgroundColor),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                side: isFilled
                    ? BorderSide.none
                    : BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                borderRadius: BorderRadius.circular(100.0))),
          ),
          padding: EdgeInsets.zero,
          icon: Icon(
            color: Theme.of(context).primaryColor,
            icon,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final ShoppingListItem? shoppingListItem;
  final void Function() onAddProduct;
  final void Function() onRemoveProduct;

  const ProductCard(
      {required this.product,
      required this.onAddProduct,
      required this.onRemoveProduct,
      this.shoppingListItem,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Card(
          elevation: 0,
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CachedNetworkImage(
                        imageUrl: product.image ?? '',
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
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        product.name!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 12),
                      )),
                ],
              ),
              Positioned(
                right: 4,
                top: 60,
                child: shoppingListItem != null
                    ? Container(
                        width: 90,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(100)),
                        child: Row(
                          children: [
                            TinyFab(
                                icon: Icons.remove_rounded,
                                isFilled: true,
                                onPressed: onRemoveProduct),
                            Expanded(
                                child: Center(
                                    child: Text(
                                        shoppingListItem!.qty.toString()))),
                            TinyFab(icon: Icons.add, onPressed: onAddProduct),
                          ],
                        ),
                      )
                    : TinyFab(icon: Icons.add, onPressed: onAddProduct),
              ),
            ],
          )),
    );
  }
}
