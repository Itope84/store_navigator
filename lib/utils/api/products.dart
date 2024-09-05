import 'dart:convert';

import 'package:flutter_query/flutter_query.dart';
import 'package:http/http.dart';
import 'package:store_navigator/utils/data/product.dart';

Future<List<Product>> fetchProducts(
    {String search = '', List<String>? ids, String? storeId}) async {
  if (search.length < 3 && ids == null) {
    return [];
  }

  // TODO: .env baseurl
  final url = Uri.parse(
      "https://api.storenav.uk/products?search=$search&ids=${ids?.join(',') ?? ''}&store_id=${storeId ?? ''}");
  try {
    final response = await get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.map<Product>((product) => Product.fromJson(product)).toList();
    } else {
      return [];
    }
  } catch (e) {
    // TODO handle error
    return [];
  }
}

Future<Map<String, List<Product>>> bulkSearchProducts(
    {required String multiLineQuery, String? storeId}) async {
  final url = Uri.parse(
      "https://api.storenav.uk/products/bulk-search?query=$multiLineQuery&store_id=${storeId ?? ''}");
  try {
    final response = await get(url);
    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return data.map((key, value) => MapEntry(
          key,
          (value as List)
              .map<Product>((product) => Product.fromJson(product))
              .toList()));
    } else {
      return {};
    }
  } catch (e) {
    print(e);
    // TODO handle error
    return {};
  }
}

QueryResult<List<Product>> useGetProducts(String search, String? storeId) {
  return useQuery('products?search=$search&store_id=$storeId', (k) async {
    return await fetchProducts(search: search, storeId: storeId);
  }, staleDuration: const Duration(minutes: 3));
}
