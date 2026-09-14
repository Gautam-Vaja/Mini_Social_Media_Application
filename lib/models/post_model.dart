class PostModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final List<String> tags;
  final int likes;
  final int views;
  final String image;

  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.tags,
    required this.likes,
    required this.views,
    required this.image,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    int parsedLikes = 0;
    if (json['likes'] is num) {
      parsedLikes = (json['likes'] as num).toInt();
    } else if (json['reactions'] is Map && json['reactions']['likes'] is num) {
      parsedLikes = (json['reactions']['likes'] as num).toInt();
    }

    final parsedId = (json['id'] is num)
        ? (json['id'] as num).toInt()
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final parsedUserId = (json['userId'] is num)
        ? (json['userId'] as num).toInt()
        : int.tryParse(json['userId']?.toString() ?? '0') ?? 0;
    final parsedViews = (json['views'] is num)
        ? (json['views'] as num).toInt()
        : 0;

    final customImage = json['image']?.toString();

    return PostModel(
      id: parsedId,
      userId: parsedUserId,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : <String>[],
      likes: parsedLikes,
      views: parsedViews,
      image: (customImage != null && customImage.isNotEmpty)
          ? customImage
          : 'https://picsum.photos/500/300?random=$parsedId',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'tags': tags,
      'likes': likes,
      'views': views,
      'image': image,
    };
  }
}
