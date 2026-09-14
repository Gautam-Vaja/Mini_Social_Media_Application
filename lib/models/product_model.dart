class ProductModel {
  final int id;
  final String thumbnail;

  ProductModel({required this.id, required this.thumbnail});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(id: json["id"], thumbnail: json["thumbnail"]);
  }
}
