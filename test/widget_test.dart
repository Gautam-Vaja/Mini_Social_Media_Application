import 'package:flutter_test/flutter_test.dart';
import 'package:mini_social_media_application/models/user_model.dart';
import 'package:mini_social_media_application/models/post_model.dart';
import 'package:mini_social_media_application/models/comment_model.dart';

void main() {
  group('Social Media Models Test', () {
    test('UserModel handles DummyJSON format correctly', () {
      final json = {
        'id': 1,
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'username': 'emilys',
        'email': 'emily.johnson@x.dummyjson.com',
        'image': 'https://dummyjson.com/icon/emilys/128',
        'bio': 'Software engineer',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.fullName, 'Emily Johnson');
      expect(user.username, 'emilys');
      expect(user.image, 'https://dummyjson.com/icon/emilys/128');
    });

    test('UserModel handles Firestore profile format correctly', () {
      final json = {
        'userId': 'abc123xyz',
        'fullName': 'John Doe',
        'username': 'johndoe',
        'email': 'john@example.com',
        'photoUrl': 'https://example.com/avatar.jpg',
        'bio': 'Hello world',
      };

      final user = UserModel.fromJson(json);

      expect(user.fullName, 'John Doe');
      expect(user.username, 'johndoe');
      expect(user.image, 'https://example.com/avatar.jpg');
      expect(user.bio, 'Hello world');
    });

    test('PostModel parses posts and reactions properly', () {
      final json = {
        'id': 1,
        'userId': 5,
        'title': 'His mother had always taught him',
        'body':
            'His mother had always taught him not to ever think of himself as normal.',
        'tags': ['history', 'american', 'crime'],
        'reactions': {'likes': 192, 'dislikes': 25},
        'views': 305,
      };

      final post = PostModel.fromJson(json);

      expect(post.id, 1);
      expect(post.userId, 5);
      expect(post.likes, 192);
      expect(post.views, 305);
      expect(post.tags.length, 3);
    });

    test('CommentModel parses comments and nested user objects safely', () {
      final json = {
        'id': 1,
        'body': 'This is some awesome thinking!',
        'postId': 100,
        'user': {'id': 63, 'username': 'ebrown', 'fullName': 'Evan Brown'},
      };

      final comment = CommentModel.fromJson(json);

      expect(comment.id, 1);
      expect(comment.postId, 100);
      expect(comment.username, 'ebrown');
      expect(comment.body, 'This is some awesome thinking!');
    });
  });
}
