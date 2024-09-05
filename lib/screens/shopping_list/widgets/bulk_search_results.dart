import 'package:flutter/material.dart';
import 'package:store_navigator/screens/shopping_list/scan_input.dart';
import 'package:store_navigator/screens/shopping_list/widgets/shopping_list_text.dart';
import 'package:store_navigator/utils/api/products.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/widgets/bottom_sheet_appbar.dart';
import 'package:store_navigator/widgets/product_card.dart';

class BulkSearchResults extends StatefulWidget {
  final String searchText;
  final ShoppingList shoppingList;
  final Function(Product, {String userDefinedName}) addProduct;
  final Function(Product) removeProduct;

  const BulkSearchResults(
      {required this.searchText,
      required this.shoppingList,
      required this.addProduct,
      required this.removeProduct,
      super.key});

  @override
  State<BulkSearchResults> createState() => _BulkSearchResultsState();
}

class _BulkSearchResultsState extends State<BulkSearchResults> {
  Map<SearchResultsClass, Map<String, List<Product>>> groupSearchResults(
      Map<String, List<Product>> searchResults) {
    return {
      SearchResultsClass.nonEmpty: Map.fromEntries(
          searchResults.entries.where((entry) => entry.value.isNotEmpty)),
      SearchResultsClass.empty: Map.fromEntries(
          searchResults.entries.where((entry) => entry.value.isEmpty)),
    };
  }

  bool isLoading = false;
  Map<SearchResultsClass, Map<String, List<Product>>> groupedSearchResults = {
    SearchResultsClass.nonEmpty: {},
    SearchResultsClass.empty: {},
  };

  Future<void> searchProducts(String text) async {
    setState(() {
      isLoading = true;
    });

    widget.shoppingList.uploadedShoppingList = text;
    widget.shoppingList.saveToDb();

    final searchResults = await bulkSearchProducts(multiLineQuery: text);

    final grouped = groupSearchResults(searchResults);

    setState(() {
      isLoading = false;
      groupedSearchResults = grouped;
    });
  }

  @override
  void initState() {
    super.initState();

    searchProducts(widget.searchText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BottomSheetAppBar(
        title: const Text('Search Results'),
        onPop: () {
          Navigator.of(context).pop();
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO: centered empty state if no text was found, i.e. searchResults will have no key

                    ...groupedSearchResults[SearchResultsClass.nonEmpty]!
                        .entries
                        .map(
                      (entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.w900),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 6),
                            entry.value.isNotEmpty
                                ? GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisExtent: 160,
                                      mainAxisSpacing: 4,
                                    ),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: entry.value.length,
                                    itemBuilder: (ctx, index) {
                                      return ProductCard(
                                        product: entry.value[index],
                                        shoppingListItem: widget.shoppingList
                                            .findItem(entry.value[index]),
                                        onAddProduct: () {
                                          widget.addProduct(entry.value[index],
                                              userDefinedName: entry.key);
                                        },
                                        onRemoveProduct: () {
                                          widget.removeProduct(
                                              entry.value[index]);
                                        },
                                      );
                                    },
                                  )
                                : const Text('No results'),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    if (groupedSearchResults[SearchResultsClass.empty]!
                        .isNotEmpty) ...[
                      Text(
                        "We could not find results for the following items:",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w900),
                      ),
                      const Text("You can edit them and try again"),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: Container(),
                        ),
                        TextButton(
                            onPressed: () {
                              openShoppingListTextInput(
                                      context,
                                      groupedSearchResults[
                                              SearchResultsClass.empty]!
                                          .keys
                                          .join('\n'))
                                  .then((text) => {
                                        if (text != null && text.isNotEmpty)
                                          {
                                            // replace current page content with new results
                                            searchProducts(text)
                                          }
                                      });
                            },
                            child: Text(
                              'Edit',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context).primaryColor),
                            )),
                      ]),
                      ...groupedSearchResults[SearchResultsClass.empty]!
                          .entries
                          .map(
                        (entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.w500),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ),
    );
  }
}
