import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';

class PostService {
  final String baseUrl = "https://dummyjson.com";

  // Posts with Pagination
  Future<List<PostModel>> getPosts({int page = 1, int limit = 20}) async {
    final int skip = (page - 1) * limit;

    final response = await http.get(
      Uri.parse("$baseUrl/posts?limit=$limit&skip=$skip"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['posts'] as List).map((e) => PostModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load posts");
  }

  // Users
  Future<List<UserModel>> getUsers({int limit = 50}) async {
    final response = await http.get(Uri.parse("$baseUrl/users?limit=$limit"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['users'] as List).map((e) => UserModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load users");
  }

  // Single User by ID
  Future<UserModel> getUserById(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/users/$userId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    }

    throw Exception("Failed to load user $userId");
  }

  // Posts of a specific user
  Future<List<PostModel>> getUserPosts(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/posts/user/$userId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['posts'] as List).map((e) => PostModel.fromJson(e)).toList();
    }

    return [];
  }

  // Comments
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
