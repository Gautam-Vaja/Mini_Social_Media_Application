import 'package:flutter/material.dart';

import 'package:mini_social_media_application/models/user_model.dart';
import 'package:mini_social_media_application/models/post_model.dart';
import 'package:mini_social_media_application/screens/postDetails/post_details.dart';
import 'package:mini_social_media_application/screens/usersProfiles/users_profile.dart';
import 'package:mini_social_media_application/services/blocked_users_service.dart';
import 'package:mini_social_media_application/services/search_service.dart';
import 'package:mini_social_media_application/services/post_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService searchService = SearchService();
  final PostService postService = PostService();
  final BlockedUsersService _blockedUsersService = BlockedUsersService.instance;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<PostModel> posts = [];
  List<PostModel> filteredPosts = [];
  List<UserModel> users = [];

  bool isSearching = false;
  bool isLoadingUsers = false;
  bool isLoading = false;
  bool hasMore = true;

  int currentPage = 1;
  final int limit = 21;

  @override
  void initState() {
    super.initState();
    _blockedUsersService.init();
    loadPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore &&
          _searchController.text.trim().isEmpty) {
        loadPosts();
      }
    });
  }

  Future<void> loadPosts() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await postService.getPosts(
        page: currentPage,
        limit: limit,
      );

      if (!mounted) return;

      setState(() {
        posts.addAll(data);
        filteredPosts = List.from(posts);
        currentPage++;
        isLoading = false;
        if (data.length < limit) {
          hasMore = false;
        }
      });
    } catch (e) {
      debugPrint("Load Posts Error: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> searchUsers(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        isSearching = false;
        users.clear();
      });
      return;
    }

    setState(() {
      isSearching = true;
      isLoadingUsers = true;
    });

    try {
      final result = await searchService.searchUsers(query);
      if (!mounted) return;
      setState(() {
        users = result;
        isLoadingUsers = false;
      });
    } catch (e) {
      debugPrint("Search User Error: $e");
      if (!mounted) return;
      setState(() {
        users = [];
        isLoadingUsers = false;
      });
    }
  }

  void openPost(int index) {
    if (filteredPosts.isEmpty || index < 0 || index >= filteredPosts.length) return;

    final List<String> postImages = filteredPosts.map((p) => p.image).toList();
    final post = filteredPosts[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetails(
          postImages: postImages,
          initialIndex: index,
          username: "user${post.userId}",
          profileImage: "https://i.pravatar.cc/150?img=${(post.userId % 70) + 1}",
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final visiblePosts = filteredPosts.where((p) => !_blockedUsersService.isBlocked(p.userId)).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: searchUsers,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              searchUsers('');
                            },
                          )
                        : null,
                    hintText: "Search accounts, names...",
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isSearching
                  ? buildUserSearchResults(colorScheme)
                  : buildPostGrid(colorScheme, visiblePosts),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPostGrid(ColorScheme colorScheme, List<PostModel> visiblePosts) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(2),
      itemCount: visiblePosts.length + (hasMore ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        if (index >= visiblePosts.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final post = visiblePosts[index];

        return GestureDetector(
          onTap: () => openPost(index),
          child: Image.network(
            post.image,
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
                child: Icon(
                  Icons.broken_image,
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildUserSearchResults(ColorScheme colorScheme) {
    if (isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Text(
          "No users found",
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 72,
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      itemBuilder: (context, index) {
        final user = users[index];
        final isBlocked = _blockedUsersService.isBlocked(user.id);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(user.image),
          ),
          title: Row(
            children: [
              Text(
                user.fullName,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isBlocked) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Blocked",
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            "@${user.username}",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UsersProfile(userId: user.id),
              ),
            );
          },
        );
      },
    );
  }
}