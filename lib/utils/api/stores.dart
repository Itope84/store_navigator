import 'dart:convert';

import 'package:flutter_query/flutter_query.dart';
import 'package:http/http.dart';
import 'package:store_navigator/utils/data/store.dart';

Future<List<Store>> fetchStores() async {
  final url = Uri.parse('https://api.storenav.uk/stores');
  try {
    final response = await get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.map<Store>((store) => Store.fromJson(store)).toList();
    } else {
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

QueryResult<List<Store>> useGetStores() {
  return useQuery('stores', (k) async {
    return await fetchStores();
  });
}
