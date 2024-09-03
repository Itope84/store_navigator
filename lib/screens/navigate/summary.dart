import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:store_navigator/screens/home.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';

class SummaryScreen extends StatelessWidget {
  final ShoppingList shoppingList;
  const SummaryScreen({super.key, required this.shoppingList});

  String getItemText(ShoppingListItem item) =>
      "${item.userGivenName ?? item.product.name} ${item.userGivenName != null ? '- ${item.product.name}' : ''} (${item.qty})";

  Map<String, List<ShoppingListItem>> groupItemsByName(
      List<ShoppingListItem> items) {
    return groupBy(
        items, (item) => item.userGivenName ?? item.product.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    List<ShoppingListItem> foundItems =
        shoppingList.items?.where((item) => item.found).toList() ?? [];

    List<ShoppingListItem> unfoundShoppingListItems =
        shoppingList.items?.where((item) => !item.found).toList() ?? [];

    List<String> otherUnfoundItems = shoppingList.uploadedShoppingList
            ?.split('\n')
            .map((e) => e.trim())
            .where((element) => element.isNotEmpty)
            .toList() ??
        [];

    List<Widget> formatShoppingListItems(List<ShoppingListItem> items) =>
        groupItemsByName(items).entries.map(
          (entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(entry.key,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                ...entry.value.map(
                  (item) => ListTile(
                    dense: true,
                    minTileHeight: 0,
                    minVerticalPadding: 2,
                    title: Text(
                      item.product.name ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Text(
                      item.qty.toString(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            );
          },
        ).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Summary'),
      ),
      // TODO: don't use listtile, also group items that have the same userGivenName
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      final String text = [
                        "Shopping Summary:",
                        "---------------",
                        "Found:",
                        ...foundItems.map(getItemText),
                        "---------------",
                        "Not Found:",
                        ...unfoundShoppingListItems.map(getItemText),
                        ...otherUnfoundItems
                      ].join('\n');

                      Clipboard.setData(ClipboardData(text: text));
                    },
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 4),
                      ),
                      visualDensity: VisualDensity.compact,
                      textStyle:
                          WidgetStatePropertyAll(TextStyle(fontSize: 16)),
                    ),
                    child: Text("Copy to clipboard"),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("You've Found",
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
            SizedBox(height: 16),
            ...formatShoppingListItems(foundItems),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("You haven't bought",
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
            SizedBox(height: 16),
            ...formatShoppingListItems(unfoundShoppingListItems),
            ...otherUnfoundItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child:
                    Text(item, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (ctx) => const HomeScreen()),
                              (_) => false);
                        },
                        child: Text("Done")),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
