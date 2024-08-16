import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:http/http.dart';

Future<List<dynamic>> fetchRoute(Uri url) async {
  try {
    final response = await get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

Future<List<dynamic>> fetchRouteBySectionId(String start, String end) async {
  final url =
      Uri.parse('http://192.168.1.108:8000/get-route?start=$start&end=$end');
  return await fetchRoute(url);
}

Future<List<dynamic>> fetchRoutesBySectionIds(List<String> sectionIds) async {
  final url = Uri.parse(
      'http://192.168.1.108:8000/get-traveling-routes?section_ids=${sectionIds.join(',')}');
  return await fetchRoute(url);
}

Future<List<dynamic>> fetchRouteByPos(Offset start, Offset end) async {
  String startStr = '${start.dx.toInt()},${start.dy.toInt()}';
  String endStr = '${end.dx.toInt()},${end.dy.toInt()}';

  final url = Uri.parse(
      'http://192.168.1.108:8000/get-route?start=$startStr&end=$endStr');
  return await fetchRoute(url);
}

Future<void> fetchGrid() async {
  try {
    final response = await get(Uri.parse('http://92.168.1.108:8000/get-grid'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final str = data
          .map((row) =>
              row.map((cell) => (cell != null && cell) ? '0' : '1').join(' '))
          .join('\n');
      log("$str");
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
