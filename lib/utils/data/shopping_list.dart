import 'package:collection/collection.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:store_navigator/utils/data/database.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/store.dart';

class ShoppingListItem {
  final String id;

  final Product product;
  // used to find the product on the store map
  String? sectionId;
  int qty;
  final String shoppingListId;

  get productId => product.id;

  ShoppingListItem(
      {String? id,
      required this.product,
      this.sectionId,
      this.qty = 1,
      required this.shoppingListId})
      : id = id ?? "${DateTime.now().millisecondsSinceEpoch}";

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      sectionId: json['section_id'],
      qty: json['qty'],
      shoppingListId: json['shopping_list_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['product_id'] = product.id;
    data['shopping_list_id'] = shoppingListId;
    data['product'] = product.toJson();
    data['section_id'] = sectionId;
    data['qty'] = qty;
    return data;
  }

  static String tableName = 'shopping_list_items';
  static String createTableQuery = '''
    CREATE TABLE $tableName(
      id TEXT PRIMARY KEY,
      product_id TEXT,
      shopping_list_id TEXT,
      section_id TEXT,
      qty INTEGER,
      FOREIGN KEY (shopping_list_id) REFERENCES ${ShoppingList.tableName}(id) ON DELETE CASCADE
    )
  ''';
}

class ShoppingList {
  final String id;
  String? name;
  final String storeId;
  List<ShoppingListItem>? items;
  final DateTime? createdAt;
  DateTime? updatedAt;

  Store? store;

  ShoppingList(
      {String? id,
      this.name,
      this.items,
      required this.storeId,
      DateTime? createdAt,
      DateTime? updatedAt})
      : id = id ?? "${DateTime.now().millisecondsSinceEpoch}",
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      name: json['name'],
      storeId: json['store_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => ShoppingListItem.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['store_id'] = storeId;
    data['created_at'] = createdAt.toString();
    data['updated_at'] = updatedAt.toString();
    data['items'] = items?.map((i) => i.toJson()).toList();
    return data;
  }

  ShoppingListItem? findItem(Product product) {
    return (items ?? []).firstWhereOrNull(
      (item) => item.product.id == product.id,
    );
  }

  static String tableName = 'shopping_lists';

  static String createTableQuery = '''
    CREATE TABLE $tableName(
      id TEXT PRIMARY KEY,
      name TEXT,
      store_id TEXT,
      created_at TEXT,
      updated_at TEXT
    )
  ''';
}

QueryResult<List<ShoppingList>> useShoppingLists() {
  return useQuery('shopping-lists', (k) async {
    final db = await DatabaseHelper().db;
    final response = await db.query(ShoppingList.tableName);

    return response.map((e) => ShoppingList.fromJson(e)).toList();
  });
}
