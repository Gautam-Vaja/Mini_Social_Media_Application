import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../models/comment_model.dart';

import '../../services/post_service.dart';
import '../../services/user_service.dart';
import '../../services/comment_service.dart';
import '../../services/saved_posts_service.dart';
import '../../services/blocked_users_service.dart';
import '../usersProfiles/users_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService postService = PostService();
  final UserService userService = UserService();
  final CommentService commentService = CommentService();
  final SavedPostsService _savedPostsService = SavedPostsService.instance;
  final BlockedUsersService _blockedUsersService = BlockedUsersService.instance;

  List<PostModel> posts = [];
  List<UserModel> users = [];

  bool loading = false;
  bool hasMore = true;

  int currentPage = 1;
  final int limit = 10;

  final ScrollController scrollController = ScrollController();
  final Set<int> likedPosts = {};

  @override
  void initState() {
    super.initState();

    _savedPostsService.init();
    _blockedUsersService.init();
    loadData();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !loading &&
          hasMore) {
        loadData();
      }
    });
  }

  Future<void> loadData() async {
    if (loading || !hasMore) return;

    setState(() {
      loading = true;
    });

    try {
      final postData = await postService.getPosts(
        page: currentPage,
        limit: limit,
      );

      if (users.isEmpty) {
        users = await userService.getUsers();
      }

      if (!mounted) return;

      setState(() {
        posts.addAll(postData);
        currentPage++;
        loading = false;
        if (postData.length < limit) {
          hasMore = false;
        }
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  UserModel getUser(int userId) {
    if (users.isEmpty) {
      return UserModel(
        id: userId,
        fullName: "User $userId",
        username: "user$userId",
        email: "",
        image: "https://i.pravatar.cc/150?img=${(userId % 70) + 1}",
        bio: "",
      );
    }

    final match = users.where((u) => u.id == userId);
    if (match.isNotEmpty) {
      return match.first;
    }

    final index = (userId - 1) % users.length;
    return users[index];
  }

  void _showPostOptions(PostModel post, UserModel user) {
    final isSaved = _savedPostsService.isSaved(post.id);
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    isSaved
                        ? Icons.bookmark_remove_outlined
                        : Icons.bookmark_add_outlined,
                  ),
                  title: Text(isSaved ? "Remove from Saved" : "Save Post"),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final saved = await _savedPostsService.toggleSave(post);
                    if (!mounted) return;
                    setState(() {});
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          saved
                              ? "Post saved to your collection"
                              : "Post removed from saved",
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text("View @${user.username}'s Profile"),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsersProfile(userId: user.id),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: Text(
                    "Block @${user.username}",
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _blockedUsersService.blockUser(
                      userId: user.id,
                      username: user.username,
                      fullName: user.fullName,
                      image: user.image,
                    );
                    if (!mounted) return;
                    setState(() {});
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          "Blocked @${user.username}. You can manage blocked users in Settings.",
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showComments(int postId) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Comments",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: FutureBuilder<List<CommentModel>>(
                        future: commentService.getComments(postId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final comments = snapshot.data ?? [];

                          if (comments.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "No comments yet. Be the first to comment!",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(
                                        "https://i.pravatar.cc/150?img=${(comment.id % 70) + 1}",
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.username,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            comment.body,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite_border,
                                        size: 16,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                  hintText: "Add a comment...",
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () {
                                if (commentController.text.trim().isNotEmpty) {
                                  commentController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Comment posted!"),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    // Filter out posts from blocked users
    final visiblePosts = posts
        .where((p) => !_blockedUsersService.isBlocked(p.userId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Social Feed",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              posts.clear();
              currentPage = 1;
              hasMore = true;
            });
            await loadData();
          },
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: visiblePosts.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == visiblePosts.length) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final post = visiblePosts[index];
              final user = getUser(post.userId);
              final isLiked = likedPosts.contains(post.id);
              final isSaved = _savedPostsService.isSaved(post.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                elevation: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UsersProfile(userId: user.id),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(user.image),
                      ),
                      title: Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("@${user.username}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showPostOptions(post, user),
                      ),
                    ),
                    GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          if (!likedPosts.contains(post.id)) {
                            likedPosts.add(post.id);
                          }
                        });
                      },
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: Image.network(
                          post.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (isLiked) {
                                  likedPosts.remove(post.id);
                                } else {
                                  likedPosts.add(post.id);
                                }
                              });
                            },
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                          ),
                          Text(
                            "${post.likes + (isLiked ? 1 : 0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => showComments(post.id),
                            icon: const Icon(Icons.chat_bubble_outline_rounded),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.send_outlined),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () async {
                              final saved = await _savedPostsService.toggleSave(
                                post,
                              );
                              if (!mounted) return;
                              setState(() {});
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    saved
                                        ? "Post saved to your collection"
                                        : "Post removed from saved",
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? colorScheme.primary : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            post.body,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (post.tags.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              children: post.tags
                                  .map(
                                    (tag) => Chip(
                                      label: Text(
                                        "#$tag",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      backgroundColor: colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      side: BorderSide.none,
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
