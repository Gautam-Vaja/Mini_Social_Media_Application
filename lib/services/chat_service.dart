import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class ChatService {
  /// Fetch all users
  Future<List<UserModel>> getUsers() async {
    final response = await http.get(Uri.parse("${ApiService.baseUrl}/users"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data["users"] as List).map((e) => UserModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load users");
  }

  /// Fetch comments of a post
  Future<List<CommentModel>> getComments(int postId) async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/comments/post/$postId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data["comments"] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList();
    }

    throw Exception("Failed to load comments");
  }

  /// Combine users with latest comments
  Future<List<ChatModel>> getChats() async {
    final users = await getUsers();

    List<ChatModel> chats = [];

    for (int i = 0; i < users.length; i++) {
      try {
        final comments = await getComments(i + 1);

        chats.add(
          ChatModel(
            name: "${users[i].fullName} ${users[i].username}",
            message: comments.isNotEmpty ? comments.first.body : "No messages",
            image: users[i].image,
            time: "09:30 AM",
            unread: 0,
            isOnline: false,
            isRead: true,
          ),
        );
      } catch (_) {
        chats.add(
          ChatModel(
            name: "${users[i].fullName} ${users[i].username}",
            message: "No messages",
            image: users[i].image,
            time: "09:30 AM",
            unread: 0,
            isOnline: false,
            isRead: false,
          ),
        );
      }
    }

    return chats;
  }
}
