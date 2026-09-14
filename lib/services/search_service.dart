import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'api_service.dart';

class SearchService {
  Future<List<UserModel>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/users/search?q=$query"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return (json["users"] as List)
          .map((e) => UserModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to search users");
    }
  }
}