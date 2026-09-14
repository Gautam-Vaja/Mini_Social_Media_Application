import 'package:flutter/material.dart';
import 'package:mini_social_media_application/models/post_model.dart';
import 'package:mini_social_media_application/models/user_model.dart';
import 'package:mini_social_media_application/screens/chatDetails/chat_details.dart';
import 'package:mini_social_media_application/screens/postDetails/post_details.dart';
import 'package:mini_social_media_application/services/blocked_users_service.dart';
import 'package:mini_social_media_application/services/post_service.dart';

class UsersProfile extends StatefulWidget {
  final int userId;

  const UsersProfile({
    super.key,
    required this.userId,
  });

  @override
  State<UsersProfile> createState() => _UsersProfileState();
}

class _UsersProfileState extends State<UsersProfile> {
  final PostService postService = PostService();
  final BlockedUsersService _blockedUsersService = BlockedUsersService.instance;

  UserModel? user;
  List<PostModel> userPosts = [];
  bool isLoading = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _blockedUsersService.init();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      // 1. Fetch User Data
      UserModel? fetchedUser;
      try {
        fetchedUser = await postService.getUserById(widget.userId);
      } catch (_) {
        final users = await postService.getUsers();
        final match = users.where((u) => u.id == widget.userId);
        if (match.isNotEmpty) {
          fetchedUser = match.first;
        } else if (users.isNotEmpty) {
          fetchedUser = users.first;
        }
      }

      // 2. Fetch User's Posts
      List<PostModel> posts = [];
      try {
        posts = await postService.getUserPosts(widget.userId);
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        user = fetchedUser;
        userPosts = posts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void openPost(int index) {
    if (user == null) return;

    final List<String> images = userPosts.isNotEmpty
        ? userPosts.map((p) => p.image).toList()
        : List.generate(6, (i) => 'https://picsum.photos/500/500?random=${widget.userId * 10 + i}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetails(
          postImages: images,
          initialIndex: index,
          username: user!.username,
          profileImage: user!.image,
        ),
      ),
    );
  }

  void _showBlockDialog() {
    if (user == null) return;

    final isCurrentlyBlocked = _blockedUsersService.isBlocked(widget.userId);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isCurrentlyBlocked ? "Unblock @${user!.username}?" : "Block @${user!.username}?"),
          content: Text(
            isCurrentlyBlocked
                ? "They will be able to view your profile and send you messages."
                : "They won't be able to find your profile, posts, or message you on Mini Social Media. You can unblock them anytime in Settings.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentlyBlocked ? null : Theme.of(context).colorScheme.error,
                foregroundColor: isCurrentlyBlocked ? null : Theme.of(context).colorScheme.onError,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (isCurrentlyBlocked) {
                  await _blockedUsersService.unblockUser(widget.userId);
                } else {
                  await _blockedUsersService.blockUser(
                    userId: widget.userId,
                    username: user!.username,
                    fullName: user!.fullName,
                    image: user!.image,
                  );
                }
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isCurrentlyBlocked
                            ? "Unblocked @${user!.username}"
                            : "Blocked @${user!.username}. View in Settings > Blocked Users.",
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(isCurrentlyBlocked ? "Unblock" : "Block"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text(
            "User not found",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final isBlocked = _blockedUsersService.isBlocked(widget.userId);
    final postCount = userPosts.isNotEmpty ? userPosts.length : 6;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          user!.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'block') {
                _showBlockDialog();
              } else if (value == 'share') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Profile link copied: @${user!.username}")),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(
                      isBlocked ? Icons.lock_open : Icons.block,
                      color: isBlocked ? null : colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isBlocked ? 'Unblock User' : 'Block User',
                      style: TextStyle(color: isBlocked ? null : colorScheme.error),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Share Profile'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isBlocked) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: colorScheme.error.withValues(alpha: 0.12),
                child: Row(
                  children: [
                    Icon(Icons.block, color: colorScheme.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "You have blocked this account.",
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _showBlockDialog,
                      child: const Text("Unblock"),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            CircleAvatar(
              radius: 54,
              backgroundColor: colorScheme.surfaceContainerHighest,
              backgroundImage: NetworkImage(user!.image),
            ),

            const SizedBox(height: 12),

            Text(
              user!.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "@${user!.username}",
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                user!.bio.isNotEmpty ? user!.bio : "Welcome to my profile 👋",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(value: "$postCount", title: "Posts"),
                _buildStat(value: "${(widget.userId * 43) % 800 + 40}", title: "Followers"),
                _buildStat(value: "${(widget.userId * 21) % 400 + 20}", title: "Following"),
              ],
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: isBlocked
                            ? _showBlockDialog
                            : () {
                                setState(() {
                                  isFollowing = !isFollowing;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isFollowing
                                          ? "You are now following @${user!.username}"
                                          : "You unfollowed @${user!.username}",
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBlocked
                              ? colorScheme.surfaceContainerHighest
                              : (isFollowing
                                  ? colorScheme.surfaceContainerHighest
                                  : colorScheme.primary),
                          foregroundColor: (isBlocked || isFollowing)
                              ? colorScheme.onSurface
                              : colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          isBlocked
                              ? "Blocked"
                              : (isFollowing ? "Following" : "Follow"),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: isBlocked
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailScreen(
                                      name: user!.fullName,
                                      image: user!.image,
                                    ),
                                  ),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          "Message",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),

            Padding(
              padding: const EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.grid_on, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Posts",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isBlocked) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Column(
                  children: [
                    Icon(Icons.lock_outline, size: 48, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      "Posts Hidden",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Unblock @${user!.username} to view their posts.",
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: postCount,
                itemBuilder: (context, index) {
                  final imageUrl = (userPosts.isNotEmpty && index < userPosts.length)
                      ? userPosts[index].image
                      : 'https://picsum.photos/500/500?random=${widget.userId * 10 + index}';

                  return GestureDetector(
                    onTap: () => openPost(index),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                        );
                      },
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({required String value, required String title}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}