import 'dart:convert';

import 'package:flutter_query/flutter_query.dart';
import 'package:http/http.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';

Future<ShoppingList?> getShoppingListById(String id) async {
  return (await ShoppingList.fetch(id: id)).firstOrNull;
}

QueryResult<ShoppingList?> useShoppingList(String id) {
  return useQuery('shopping-list-$id', (k) async {
    return await getShoppingListById(id);
  }, enabled: id.isNotEmpty);
}

QueryResult<List<ShoppingList>> useShoppingLists() {
  return useQuery('shopping-lists', (k) async {
    return await ShoppingList.fetch();
  });
}

// a tiny version of the ShoppingListItem class
class ProductWithShelf {
  Product product;
  String sectionId;

  ProductWithShelf(this.product, this.sectionId);

  ProductWithShelf.fromJson(Map<String, dynamic> json)
      : product = Product.fromJson(json['product']),
        sectionId = json['section_id'];
}

Future<List<ProductWithShelf>> getShoppingListProductsWithShelves(
    String storeId, List<String> productIds) async {
  final url = Uri.parse(
      "http://192.168.1.108:8000/stores/$storeId/product-shelves?products=${productIds.join(',')}");

  try {
    final response = await get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final products = data
          .map<ProductWithShelf>(
              (product) => ProductWithShelf.fromJson(product))
          .toList();
      return products;
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}
