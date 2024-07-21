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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}
