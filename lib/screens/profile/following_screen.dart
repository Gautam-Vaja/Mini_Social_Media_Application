import 'package:flutter/material.dart';
import 'package:mini_social_media_application/models/user_model.dart';
import 'package:mini_social_media_application/screens/usersProfiles/users_profile.dart';
import 'package:mini_social_media_application/services/post_service.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final PostService postService = PostService();
  List<UserModel> users = [];
  bool isLoading = true;
  final Set<int> followingUserIds = {};

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final fetched = await postService.getUsers();
      if (!mounted) return;
      setState(() {
        users = fetched;
        for (var u in users) {
          followingUserIds.add(u.id);
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Following")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Following",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: users.length > 50 ? 50 : users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isFollowing = followingUserIds.contains(user.id);

          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersProfile(userId: user.id),
                ),
              );
            },
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(user.image),
            ),
            title: Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text("@${user.username}"),
            trailing: SizedBox(
              width: 110,
              height: 36,
              child: isFollowing
                  ? OutlinedButton(
                      onPressed: () {
                        setState(() {
                          followingUserIds.remove(user.id);
                        });
                      },
                      child: const Text("Following"),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          followingUserIds.add(user.id);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: const Text("Follow"),
                    ),
            ),
          );
        },
      ),
    );
  }
}
