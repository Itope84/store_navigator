import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:store_navigator/screens/shopping_list/product_search.dart';
import 'package:store_navigator/utils/api/shopping_list.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/utils/data/store.dart' as st;
import 'package:store_navigator/screens/select_store.dart';
import 'package:store_navigator/screens/shopping_list/fake_search_input.dart';
import 'package:store_navigator/widgets/shopping_list_item_tile.dart';

class ShoppingListScreen extends HookWidget {
  final String? id;
  final st.Store store;
  const ShoppingListScreen({this.id, required this.store, super.key});

  @override
  Widget build(BuildContext context) {
    final future =
        useMemoized(() => id != null ? getShoppingListById(id!) : null);
    final snapshot = useFuture(future);

    return HookBuilder(builder: (_) {
      final storeState = useState(store);
      final _store = storeState.value;

      final listState =
          useState(snapshot.data ?? ShoppingList(storeId: _store.id));
      final shoppingList = listState.value;

      const padding = EdgeInsets.symmetric(horizontal: 24);

      addProduct(Product product) {
        final item = shoppingList.findItem(product);
        if (item != null) {
          item.qty++;
        } else {
          shoppingList.items ??= [];
          shoppingList.items!.add(ShoppingListItem(
              product: product, shoppingListId: shoppingList.id));
        }

        // Force rerender
        // TODO: see if there's a better way to do this
        listState.value = ShoppingList.fromJson(shoppingList.toJson());

        // TODO: debounce save to db
      }

      removeProduct(Product product) {
        final item = shoppingList.findItem(product);
        if (item == null) {
          return;
        } else {
          if (item.qty > 1) {
            item.qty--;
          } else {
            shoppingList.items!.remove(item);
          }
        }

        listState.value = ShoppingList.fromJson(shoppingList.toJson());

        // TODO: debounce save to db
      }

      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Container(
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
                        storeState.value = store;
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                                          color: Theme.of(context).primaryColor,
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
                              shoppingListState: listState,
                              addProduct: addProduct,
                              removeProduct: removeProduct,
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
                                    onDelete: () {
                                      removeProduct(item.product);
                                    },
                                  ))
                        ],
                      )),
                      SizedBox(height: 18),
                      Padding(
                        padding: padding,
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Done'),
                        ),
                      ),
                    ]
                  : [
                      Center(
                        child: Padding(
                          padding: padding,
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child:
                                Image.asset('assets/empty_shopping_basket.png'),
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
    });
  }
}
