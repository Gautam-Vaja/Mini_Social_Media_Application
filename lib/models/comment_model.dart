class CommentModel {
  final int id;
  final int postId;
  final String body;
  final String username;
  final int likes;

  CommentModel({
    required this.id,
    required this.postId,
    required this.body,
    required this.username,
    this.likes = 0,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String parsedUsername = 'User';
    if (json['user'] is Map) {
      parsedUsername =
          json['user']['username']?.toString() ??
          json['user']['fullName']?.toString() ??
          'User';
    } else if (json['username'] != null) {
      parsedUsername = json['username'].toString();
    }

    return CommentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      postId: json['postId'] is int
          ? json['postId']
          : int.tryParse(json['postId']?.toString() ?? '0') ?? 0,
      body: json['body']?.toString() ?? '',
      username: parsedUsername,
      likes: json['likes'] is int
          ? json['likes']
          : int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'body': body,
      'username': username,
      'likes': likes,
    };
  }
}
