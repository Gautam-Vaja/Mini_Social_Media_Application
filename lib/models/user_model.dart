class UserModel {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String image;
  final String bio;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.image,
    required this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle full name from either direct field or firstName + lastName
    String name = json['fullName']?.toString().trim() ?? '';
    if (name.isEmpty) {
      final first = json['firstName']?.toString().trim() ?? '';
      final last = json['lastName']?.toString().trim() ?? '';
      if (first.isNotEmpty || last.isNotEmpty) {
        name = '$first $last'.trim();
      } else {
        name = json['username']?.toString() ?? 'User';
      }
    }

    final idVal = json['id'] ?? json['userId'];
    int parsedId = 0;
    if (idVal is int) {
      parsedId = idVal;
    } else if (idVal is String) {
      parsedId = int.tryParse(idVal) ?? 0;
    }

    // Handle avatar image fallbacks
    String avatarUrl =
        json['image']?.toString() ??
        json['photoUrl']?.toString() ??
        json['photoURL']?.toString() ??
        json['profileImageUrl']?.toString() ??
        '';

    if (avatarUrl.isEmpty) {
      avatarUrl = 'https://i.pravatar.cc/150?img=${(parsedId % 70) + 1}';
    }

    return UserModel(
      id: parsedId,
      fullName: name,
      username: json['username']?.toString() ?? 'user',
      email: json['email']?.toString() ?? '',
      image: avatarUrl,
      bio: json['bio']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'image': image,
      'bio': bio,
    };
  }
}
