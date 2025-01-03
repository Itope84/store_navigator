import 'package:flutter/material.dart';
import 'package:store_navigator/screens/shopping_list/scan_input.dart';
import 'package:store_navigator/utils/api/products.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/widgets/product_card.dart';
import 'package:store_navigator/widgets/text_input.dart';

class ProductSearch extends StatefulWidget {
  final String storeId;
  final ShoppingList shoppingList;
  final Function(Product, {String? userDefinedName}) addProduct;
  final Function(Product) removeProduct;

  const ProductSearch(
      {required this.storeId,
      required this.shoppingList,
      required this.addProduct,
      required this.removeProduct,
      super.key});

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  String search = '';
  TextEditingController searchController = TextEditingController();

  List<Product> products = [];

  @override
  void initState() {
    getProducts();

    super.initState();
  }

  getProducts() async {
    // TODO: debounce the search
    fetchProducts(search: search, storeId: widget.storeId).then((value) {
      setState(() {
        products = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: debounce the search
    // final productQuery = useGetProducts(search, widget.storeId);
    // final products = productQuery.state.data ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: RoundedMaterialTextFormField(
          controller: searchController,
          filled: true,
          hintText: 'Search for a product',
          isClearable: true,
          onChanged: (value) {
            setState(() {
              search = value;
              getProducts();
            });
          },
        ),
      ),
      // TODO: fetch and display categories for the empty query state to make searching easier
      // TODO: empty query state
      body: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton(
                  style: ButtonStyle(
                    // fixedSize:
                    //     WidgetStatePropertyAll(Size.fromWidth(90)),
                    // padding: WidgetStatePropertyAll(
                    //   EdgeInsets.symmetric(horizontal: 4),
                    // ),
                    visualDensity: VisualDensity.compact,
                    textStyle: WidgetStatePropertyAll(TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 16)),
                  ),
                  child: const Text("Or scan shopping list or receipt"),
                  onPressed: () {
                    selectImage(
                      context,
                      widget.shoppingList,
                      widget.addProduct,
                      widget.removeProduct,
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 24,
            ),
            // TODO: the scan to input pill
            if (search.isNotEmpty)
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 160,
                mainAxisSpacing: 4,
              ),
              itemCount: products.length,
              itemBuilder: (ctx, index) {
                return ProductCard(
                  product: products[index],
                  shoppingListItem:
                      widget.shoppingList.findItem(products[index]),
                  onAddProduct: () {
                    widget.addProduct(products[index]);
                  },
                  onRemoveProduct: () {
                    widget.removeProduct(products[index]);
                  },
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
