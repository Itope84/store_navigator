import 'dart:async';

import 'package:flutter/material.dart';
import 'package:store_navigator/screens/shopping_list/product_search.dart';
import 'package:store_navigator/utils/api/shopping_list.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/utils/data/store.dart';
import 'package:store_navigator/screens/select_store.dart';
import 'package:store_navigator/screens/shopping_list/fake_search_input.dart';
import 'package:store_navigator/widgets/shopping_list_item_tile.dart';
import 'package:store_navigator/zoomable_map.dart';

class ShoppingListScreen extends StatefulWidget {
  final String? id;
  final Store store;

  ShoppingListScreen({this.id, required this.store, super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late Store _store;
  late ShoppingList shoppingList;

  ShoppingList? apiShoppingList;

  @override
  void initState() {
    _store = widget.store;
    shoppingList = ShoppingList(storeId: _store.id);

    getShoppingListById(widget.id ?? '').then((list) {
      if (list != null) {
        setState(() {
          apiShoppingList = list;
          shoppingList = list;
        });
      }
    });

    super.initState();
  }

  addProduct(Product product) {
    final item = shoppingList.findItem(product);
    setState(() {
      if (item != null) {
        item.qty++;
      } else {
        shoppingList.items ??= [];
        shoppingList.items!.add(ShoppingListItem(
            product: product, shoppingListId: shoppingList.id));
      }
    });

    // TODO: debounce save to db
  }

  reduceProduct(Product product) {
    final item = shoppingList.findItem(product);

    print('reducing product, from ${item?.qty}');

    setState(() {
      if (item == null) {
        return;
      } else {
        if (item.qty > 1) {
          item.qty--;
        } else {
          shoppingList.items!.remove(item);
        }
      }
    });

    print('item now ${item?.qty}');

    // TODO: debounce save to db
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 24);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: widget.id != null &&
              // TODO: better loading checks
              apiShoppingList == null
          ? Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: GestureDetector(
                      onTap: () {
                        // TODO:  pass a "onChangeStore" param to this widget
                        showSelectStore(
                          context,
                          selected: _store,
                          onStoreSelected: (ctx, store) {
                            setState(() {
                              _store = store;
                              shoppingList.storeId = store.id;
                            });

                            Navigator.of(ctx).pop();
                          },
                        );
                      },
                      child: Card(
                        elevation: 4,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("Selected store",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                              Text(
                                _store.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF3B4254)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: padding,
                    child: Text(
                      "Shopping List",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: padding,
                    child: ShoppingListFakeSearch(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (c) => ProductSearch(
                                  storeId: _store.id,
                                  shoppingList: shoppingList,
                                  addProduct: addProduct,
                                  removeProduct: reduceProduct,
                                )));
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...((shoppingList.items ?? []).isNotEmpty
                      ? [
                          Expanded(
                              child: ListView(
                            children: [
                              ...shoppingList.items!
                                  .map((item) => ShoppingListItemTile(
                                        item,
                                        onReduceProduct: () {
                                          reduceProduct(item.product);
                                        },
                                        onAddProduct: () {
                                          addProduct(item.product);
                                        },
                                      ))
                            ],
                          )),
                          SizedBox(height: 18),
                          Padding(
                            padding: padding,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => ZoomableMap()));
                              },
                              child: const Text('Navigate'),
                            ),
                          ),
                          Padding(
                            padding: padding,
                            child: FilledButton(
                              onPressed: () async {
                                await shoppingList.saveToDb();

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Done'),
                            ),
                          ),
                          SizedBox(height: 18),
                        ]
                      : [
                          Center(
                            child: Padding(
                              padding: padding,
                              child: SizedBox(
                                width: 180,
                                height: 180,
                                child: Image.asset(
                                    'assets/empty_shopping_basket.png'),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: padding,
                            child: Text(
                              "Your shopping list is empty. Add new items by searching or scanning above",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.grey[700]),
                            ),
                          )
                        ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
