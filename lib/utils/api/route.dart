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

class RoutePair {
  final String pathId;
  final List<dynamic> route;

  RoutePair(this.pathId, this.route);

  RoutePair.fromJson(dynamic json)
      : pathId = json[0],
        route = json[1];
}

Future<List<dynamic>> fetchRouteBySectionId(String start, String end) async {
  final url =
      Uri.parse('http://192.168.1.108:8000/get-route?start=$start&end=$end');
  return await fetchRoute(url);
}

Future<List<RoutePair>> fetchRoutesBySectionIds(List<String> sectionIds) async {
  final url = Uri.parse(
      'http://192.168.1.108:8000/get-traveling-routes?section_ids=${sectionIds.join(',')}');
  final routes = await fetchRoute(url);
  return routes.map((route) => RoutePair.fromJson(route)).toList();
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
