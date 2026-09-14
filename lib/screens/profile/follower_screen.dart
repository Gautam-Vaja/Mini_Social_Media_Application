import 'package:flutter/material.dart';
import 'package:mini_social_media_application/models/user_model.dart';
import 'package:mini_social_media_application/screens/usersProfiles/users_profile.dart';
import 'package:mini_social_media_application/services/post_service.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final PostService postService = PostService();

  List<UserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final result = await postService.getUsers();

      if (!mounted) return;

      setState(() {
        users = result;
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Followers")),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Followers",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: users.length > 50 ? 50 : users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersProfile(
                    userId: user.id,
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                user.image,
              ),
            ),
            title: Text(
              user.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "@${user.username}",
            ),
            trailing: SizedBox(
              width: 95,
              height: 36,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    users.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Removed @${user.username} from followers"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text("Remove"),
              ),
            ),
          );
        },
      ),
    );
  }
}