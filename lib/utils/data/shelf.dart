class Shelf {
  String? id;
  String? mapNodeId;
  String? name;
  String? section;
  String? storeId;

  Shelf({this.id, this.mapNodeId, this.name, this.section, this.storeId});

  Shelf.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mapNodeId = json['map_node_id'];
    name = json['name'];
    section = json['section'];
    storeId = json['store_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    data['map_node_id'] = this.mapNodeId;
    data['name'] = this.name;
    data['section'] = this.section;
    data['store_id'] = this.storeId;

    return data;
  }
}
