import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:store_navigator/utils/api/products.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/widgets/product_card.dart';
import 'package:store_navigator/widgets/text_input.dart';

class ProductSearch extends HookWidget {
  final String storeId;
  final ValueNotifier<ShoppingList> shoppingListState;
  final Function(Product) addProduct;
  final Function(Product) removeProduct;

  const ProductSearch(
      {required this.storeId,
      required this.shoppingListState,
      required this.addProduct,
      required this.removeProduct,
      super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = useState('');

    String search = searchState.value;

    final searchController = useTextEditingController();

    // TODO: debounce the search
    final productQuery = useGetProducts(search, storeId);
    final products = productQuery.state.data ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: RoundedMaterialTextFormField(
          controller: searchController,
          filled: true,
          hintText: 'Search for a product',
          isClearable: true,
          onChanged: (value) {
            searchState.value = value;
          },
        ),
      ),
      // TODO: fetch and display categories for the empty query state to make searching easier
      // TODO: empty query state
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: the scan to input pill
            Text(
              '${products.length} results for $search',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Expanded(
                child: GridView.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    // shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisExtent: 160,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: products.length,
                    itemBuilder: (ctx, index) {
                      print('building $index');
                      // TODO: avoid rerendering everything by passing the listenable notifier to each product card and in there create a new ValueNotifier that only checks that shoppinglistitems state
                      return ValueListenableBuilder<ShoppingList>(
                          valueListenable: shoppingListState,
                          builder: (context, shoppingList, child) {
                            return ProductCard(
                              product: products[index],
                              shoppingListItem:
                                  shoppingList.findItem(products[index]),
                              onAddProduct: () {
                                addProduct(products[index]);
                              },
                              onRemoveProduct: () {
                                removeProduct(products[index]);
                              },
                            );
                          });
                    }))
          ],
        ),
      ),
    );
  }
}
