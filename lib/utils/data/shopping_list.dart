class ShoppingListItem {
  final String productName;
  final String sectionId;

  ShoppingListItem({required this.productName, required this.sectionId});

  // factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
  //   return ShoppingListItem(
  //     name: json['name'],
  //     quantity: json['quantity'],
  //   );
  // }
}

class ShoppingList {
  final String name;
  final String storeId;
  final List<ShoppingListItem> items;

  ShoppingList(
      {required this.name, required this.items, required this.storeId});

  // factory ShoppingList.fromJson(Map<String, dynamic> json) {
  //   var items = json['items'] as List;
  //   List<ShoppingItem> shoppingItems = items.map((i) => ShoppingItem.fromJson(i)).toList();

  //   return ShoppingList(
  //     name: json['name'],
  //     items: shoppingItems,
  //   );
  // }
}
