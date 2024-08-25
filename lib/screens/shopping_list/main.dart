import 'package:flutter/material.dart';
import 'package:store_navigator/screens/shopping_list/product_search.dart';
import 'package:store_navigator/screens/shopping_list/scan_input.dart';
import 'package:store_navigator/screens/shopping_list/widgets/bulk_search_results.dart';
import 'package:store_navigator/screens/shopping_list/widgets/shopping_list_text.dart';
import 'package:store_navigator/utils/api/shopping_list.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/utils/data/store.dart';
import 'package:store_navigator/screens/select_store.dart';
import 'package:store_navigator/screens/shopping_list/widgets/fake_search_input.dart';
import 'package:store_navigator/utils/debouncer.dart';
import 'package:store_navigator/widgets/shopping_list_item_tile.dart';
import 'package:store_navigator/screens/navigate/navigate_store.dart';

class ShoppingListScreen extends StatefulWidget {
  final String? id;
  final Store store;

  final Function()? onPop;

  const ShoppingListScreen(
      {this.id, required this.store, this.onPop, super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late Store _store;
  late ShoppingList shoppingList;

  ShoppingList? apiShoppingList;

  String shoppingListText = '';

  final Debouncer debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    _store = widget.store;
    shoppingList = ShoppingList(storeId: _store.id)..store = _store;

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

  Future<void> saveToDb({bool immediate = false}) async {
    if (immediate) {
      debouncer.cancel();

      return await shoppingList.saveToDb();
    }

    debouncer.run(() {
      shoppingList.saveToDb();
    });
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

    saveToDb();
  }

  reduceProduct(Product product) {
    final item = shoppingList.findItem(product);

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

    saveToDb();
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 24);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: PopScope(
        onPopInvoked: (_) => widget.onPop?.call(),
        child: widget.id != null &&
                // TODO: better loading checks
                apiShoppingList == null
            ? const Center(
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
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: GestureDetector(
                        onTap: () {
                          // TODO:  pass a "onChangeStore" param to this widget
                          showSelectStore(
                            context,
                            selected: _store,
                            onStoreSelected: (ctx, store) {
                              setState(() {
                                _store = store;
                                shoppingList.store = store;
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
                            padding: const EdgeInsets.symmetric(
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
                                          color: const Color(0xFF3B4254)),
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
                        onScan: () {
                          selectImage(
                            context,
                            shoppingList,
                            addProduct,
                            reduceProduct,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Padding(
                          padding: padding,
                          child: TextButton(
                            style: ButtonStyle(
                              // fixedSize:
                              //     WidgetStatePropertyAll(Size.fromWidth(90)),
                              // padding: WidgetStatePropertyAll(
                              //   EdgeInsets.symmetric(horizontal: 4),
                              // ),
                              visualDensity: VisualDensity.compact,
                              textStyle: WidgetStatePropertyAll(TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16)),
                            ),
                            child: const Text("Or paste shopping list"),
                            onPressed: () {
                              openShoppingListTextInput(context).then((text) {
                                if (text != null && text.isNotEmpty) {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return BulkSearchResults(
                                          shoppingList: shoppingList,
                                          searchText: text,
                                          addProduct: addProduct,
                                          removeProduct: reduceProduct,
                                        );
                                      });
                                }
                              });
                            },
                          ),
                        ),
                      ],
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
                            const SizedBox(height: 18),
                            Padding(
                              padding: padding,
                              child: OutlinedButton(
                                onPressed: () {
                                  print(shoppingList.store);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) => NavigateStoreScreen(
                                            shoppingList: shoppingList,
                                          )));
                                },
                                child: const Text('Navigate'),
                              ),
                            ),
                            Padding(
                              padding: padding,
                              child: FilledButton(
                                onPressed: () async {
                                  await saveToDb(immediate: true);

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Done'),
                              ),
                            ),
                            const SizedBox(height: 18),
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
                            ),
                          ]),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
