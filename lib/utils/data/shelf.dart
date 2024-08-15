class Shelf {
  String? id;
  late String mapNodeId;
  String? name;
  String? section;
  String? storeId;

  Shelf(
      {this.id,
      required this.mapNodeId,
      this.name,
      this.section,
      this.storeId});

  Shelf.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mapNodeId = json['map_node_id'];
    name = json['name'];
    section = json['section'];
    storeId = json['store_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['map_node_id'] = mapNodeId;
    data['name'] = name;
    data['section'] = section;
    data['store_id'] = storeId;

    return data;
  }
}
