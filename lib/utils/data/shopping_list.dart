import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:store_navigator/utils/api/products.dart';
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

  String get productId => product.id!;

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
    final Map<String, dynamic> data = <String, dynamic>{};
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
  String storeId;
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
    final Map<String, dynamic> data = <String, dynamic>{};
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

  static String query = '''
    SELECT
      sl.*,
      sli.id as item_id,
      sli.product_id,
      sli.section_id,
      sli.qty
    FROM
      ${ShoppingListItem.tableName} sli
    LEFT JOIN
      $tableName sl ON sl.id = sli.shopping_list_id
    ''';

  static String queryById = '''
    $query
    WHERE
      sl.id = ?
  ''';

  static Future<List<ShoppingList>> fetch({String? id}) async {
    final db = await DatabaseHelper().db;
    final response = await db.rawQuery(
        // TODO: fix updated_at. it's only being set at creation atm
        id != null ? queryById : '$query ORDER BY sl.updated_at DESC',
        id != null ? [id] : null);

    // response gives us a response for each product in the shopping list. Meaning if there are 3 shopping lists with 3 products each, we get 9 responses.

    if (response.isEmpty) return [];

    // fetch products from api, for each response.
    final uniqueProductIds =
        response.map((e) => "${e['product_id']}").toSet().toList();

    print("db query resp: $response");
    print(uniqueProductIds);

    final products = await fetchProducts(ids: uniqueProductIds);
    final productsMap =
        Map.fromEntries(products.map((p) => MapEntry(p.id!, p)));

    // create a map of shopping list id to shopping list to unique-ify the joined results
    final shoppingLists = response
        .fold<Map<String, ShoppingList>>(
          {},
          (acc, e) {
            final id = e['id'] as String;
            if (acc.containsKey(id)) {
              acc[id]!.items!.add(ShoppingListItem(
                  id: e['item_id'] as String,
                  // TODO: this might be breaking if api is not available, because of not-null enforcer (!). We need to throw an error from this entire fn if the api request fails, i.e productsMap doesn't contain some product id.
                  product: productsMap[e['product_id'] as String]!,
                  sectionId: e['section_id'] as String?,
                  qty: e['qty'] as int,
                  shoppingListId: id));
            } else {
              acc[id] = ShoppingList.fromJson(e)
                ..items = [
                  ShoppingListItem(
                      id: e['item_id'] as String,
                      product: productsMap[e['product_id'] as String]!,
                      sectionId: e['section_id'] as String?,
                      qty: e['qty'] as int,
                      shoppingListId: id)
                ];
            }
            return acc;
          },
        )
        .values
        .toList();

    return shoppingLists;
  }

  saveToDb() async {
    final db = await DatabaseHelper().db;
    // update the updated_at field
    updatedAt = DateTime.now();

    final json = toJson()..remove('items');

    print(json);

    await db.insert(tableName, json,
        conflictAlgorithm: ConflictAlgorithm.replace);

    await Future.forEach<ShoppingListItem>(items ?? [], (item) async {
      final itemJson = item.toJson()..remove('product');
      print(itemJson);
      await db.insert(ShoppingListItem.tableName, itemJson);
    });
  }
}
