import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/widgets/product_qty.dart';

class ProductCard extends StatefulWidget {
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
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  ShoppingListItem? _item;

  @override
  void initState() {
    _item = widget.shoppingListItem;

    super.initState();
  }

  addProduct() {
    widget.onAddProduct();

    // This is a hacky way to achieve this. It's better to use a state management solution
    setState(() {
      if (_item != widget.shoppingListItem) {
        // we have created a new instance of the item because og shoppinglistitem given was null
        if (_item != null) {
          _item!.qty++;
        } else {
          _item = ShoppingListItem(
              product: widget.product, qty: 1, shoppingListId: 'temp');
        }
      } else {
        _item = widget.shoppingListItem ??
            ShoppingListItem(
                product: widget.product,
                qty: _item?.qty != null ? _item!.qty + 1 : 1,
                shoppingListId: 'temp');
      }
    });
  }

  removeProduct() {
    setState(() {
      if (_item != widget.shoppingListItem) {
        // we've created a new instance of the item
        if (_item != null && _item!.qty > 1) {
          _item!.qty--;
        } else {
          _item = null;
        }
      } else {
        if (_item != null && _item!.qty == 1) {
          _item = null;
        }
      }
    });

    widget.onRemoveProduct();
  }

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
                        imageUrl: widget.product.image ?? '',
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
                        widget.product.name!,
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
                child: _item != null
                    ? ProductQtyController(
                        qty: _item!.qty,
                        onAddProduct: addProduct,
                        onRemoveProduct: removeProduct)
                    : TinyFab(icon: Icons.add, onPressed: addProduct),
              ),
            ],
          )),
    );
  }
}
