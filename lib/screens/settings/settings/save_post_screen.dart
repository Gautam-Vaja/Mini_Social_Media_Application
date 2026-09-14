import 'package:flutter/material.dart';
import 'package:mini_social_media_application/models/post_model.dart';
import 'package:mini_social_media_application/screens/postDetails/post_details.dart';
import 'package:mini_social_media_application/services/saved_posts_service.dart';

class SavePostScreen extends StatefulWidget {
  const SavePostScreen({super.key});

  @override
  State<SavePostScreen> createState() => _SavePostScreenState();
}

class _SavePostScreenState extends State<SavePostScreen> {
  final SavedPostsService _savedPostsService = SavedPostsService.instance;

  @override
  void initState() {
    super.initState();
    _savedPostsService.init();
  }

  void _openPost(List<PostModel> posts, int index) {
    if (index < 0 || index >= posts.length) return;
    final post = posts[index];
    final images = posts.map((p) => p.image).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetails(
          postImages: images,
          initialIndex: index,
          username: "user${post.userId}",
          profileImage:
              "https://i.pravatar.cc/150?img=${(post.userId % 70) + 1}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Saved Posts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: _savedPostsService,
        builder: (context, _) {
          final savedPosts = _savedPostsService.savedPosts;

          if (savedPosts.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 56,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No Saved Posts Yet",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save photos and videos from your feed that you want to see again. Only you can see what you\'ve saved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _savedPostsService.init(),
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                final post = savedPosts[index];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: () => _openPost(savedPosts, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
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
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () async {
                          await _savedPostsService.toggleSave(post);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Post removed from saved"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
