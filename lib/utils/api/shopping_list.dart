import 'package:flutter_query/flutter_query.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';

Future<ShoppingList?> getShoppingListById(String id) async {
  return (await ShoppingList.fetch(id: id)).firstOrNull;
}

QueryResult<ShoppingList?> useShoppingList(String id) {
  return useQuery('shopping-list-${id}', (k) async {
    return await getShoppingListById(id);
  }, enabled: id.isNotEmpty);
}

QueryResult<List<ShoppingList>> useShoppingLists() {
  return useQuery('shopping-lists', (k) async {
    return await ShoppingList.fetch();
  });
}
