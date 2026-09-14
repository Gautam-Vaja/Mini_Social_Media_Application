import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class UserService {
  final String baseUrl = "https://dummyjson.com";

  Future<List<UserModel>> getUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['users'] as List).map((e) => UserModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load users");
  }
}
