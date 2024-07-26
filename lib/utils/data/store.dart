import 'package:flutter_query/flutter_query.dart';
import 'package:store_navigator/utils/data/shelf.dart';

class Store {
  String? address;
  String? floorPlan;
  late String id;
  String? logo;
  late String name;

  List<Shelf>? shelves;

  Store(
      {this.address,
      this.floorPlan,
      required this.id,
      this.logo,
      required this.name,
      this.shelves});

  Store.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    floorPlan = json['floor_plan'];
    id = json['id'];
    logo = json['logo'];
    name = json['name'];

    if (json['shelves'] != null) {
      shelves = <Shelf>[];
      json['shelves'].forEach((v) {
        shelves!.add(Shelf.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = address;
    data['floor_plan'] = floorPlan;
    data['id'] = id;
    data['logo'] = logo;
    data['name'] = name;

    if (shelves != null) {
      data['shelves'] = shelves!.map((v) => v.toJson()).toList();
    }

    return data;
  }

  static String tableName = 'stores';

  static String createTableQuery = '''
    CREATE TABLE $tableName(
      id TEXT PRIMARY KEY,
      name TEXT,
      address TEXT,
      logo TEXT,
      floor_plan TEXT
    )
  ''';
}
