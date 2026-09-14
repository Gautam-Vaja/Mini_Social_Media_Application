import 'package:flutter/material.dart';
import 'package:mini_social_media_application/models/post_model.dart';
import 'package:mini_social_media_application/services/saved_posts_service.dart';

class PostDetails extends StatefulWidget {
  final List postImages;
  final int initialIndex;
  final String username;
  final String profileImage;

  const PostDetails({
    super.key,
    required this.postImages,
    required this.initialIndex,
    required this.username,
    required this.profileImage,
  });

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final SavedPostsService _savedPostsService = SavedPostsService.instance;
  late PageController pageController;
  late int currentIndex;
  final Set<int> likedPosts = {};

  @override
  void initState() {
    super.initState();
    _savedPostsService.init();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void toggleLike(int index) {
    setState(() {
      if (likedPosts.contains(index)) {
        likedPosts.remove(index);
      } else {
        likedPosts.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Post",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "${currentIndex + 1} of ${widget.postImages.length}",
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.postImages.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final bool isLiked = likedPosts.contains(index);
          final imageUrl = widget.postImages[index].toString();
          final pseudoPostId = imageUrl.hashCode.abs() % 100000 + 1;
          final isSaved = _savedPostsService.isSaved(pseudoPostId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage: NetworkImage(widget.profileImage),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_vert,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
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
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => toggleLike(index),
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : colorScheme.onSurface,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: colorScheme.onSurface,
                          size: 26,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.send_outlined,
                          color: colorScheme.onSurface,
                          size: 26,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          final post = PostModel(
                            id: pseudoPostId,
                            userId: 1,
                            title: "Post by ${widget.username}",
                            body: "Enjoying this moment! ✨",
                            tags: ["lifestyle"],
                            likes: isLiked ? 1001 : 1000,
                            views: 2500,
                            image: imageUrl,
                          );
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
                          color: isSaved
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    isLiked ? "1,001 likes" : "1,000 likes",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.username,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "  Enjoying this awesome moment! ✨",
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "View all 24 comments",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
