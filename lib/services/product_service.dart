import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {

  Future<List<ProductModel>> getProducts() async {

    final response = await http.get(
      Uri.parse("https://dummyjson.com/products"),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return (data["products"] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    }

    throw Exception("Failed");
  }
}