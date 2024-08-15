class Product {
  String? id;
  String? image;
  String? name;
  double? price;

  Product({this.id, this.image, this.name, this.price});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}
