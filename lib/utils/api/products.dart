import 'dart:convert';

import 'package:flutter_query/flutter_query.dart';
import 'package:http/http.dart';
import 'package:store_navigator/utils/data/product.dart';

Future<List<Product>> fetchProducts(
    {String search = '', List<String>? ids, String? storeId}) async {
  if (search.length < 3 && ids == null) {
    return [];
  }

  print('fetching products');
  // TODO: .env baseurl
  final url = Uri.parse(
      "http://192.168.1.108:8000/products?search=$search&ids=${ids?.join(',') ?? ''}&store_id=${storeId ?? ''}");
  try {
    final response = await get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.map<Product>((product) => Product.fromJson(product)).toList();
    } else {
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

QueryResult<List<Product>> useGetProducts(String search, String? storeId) {
  return useQuery('products?search=$search&store_id=$storeId', (k) async {
    return await fetchProducts(search: search, storeId: storeId);
  }, staleDuration: Duration(minutes: 3));
}
