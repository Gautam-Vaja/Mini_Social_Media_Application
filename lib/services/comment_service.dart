import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/comment_model.dart';

class CommentService {
  final String baseUrl = "https://dummyjson.com";

  Future<List<CommentModel>> getComments(int postId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/comments/post/$postId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['comments'] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList();
    }

    throw Exception("Failed to load comments");
  }
}
