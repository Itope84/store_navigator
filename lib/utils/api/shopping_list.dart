import 'package:flutter_query/flutter_query.dart';
import 'package:store_navigator/utils/data/database.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';

Future<ShoppingList?> getShoppingListById(String id) async {
  final db = await DatabaseHelper().db;
  final response =
      await db.query(ShoppingList.tableName, where: "id = ?", whereArgs: [id]);

  return response.map((e) => ShoppingList.fromJson(e)).toList().firstOrNull;
}

QueryResult<List<ShoppingList>> useShoppingLists() {
  return useQuery('shopping-lists', (k) async {
    final db = await DatabaseHelper().db;
    final response = await db.query(ShoppingList.tableName);

    return response.map((e) => ShoppingList.fromJson(e)).toList();
  });
}
