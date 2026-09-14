import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_social_media_application/models/user_model.dart';
import 'package:mini_social_media_application/screens/postDetails/post_details.dart';
import 'package:mini_social_media_application/screens/profile/follower_screen.dart';
import 'package:mini_social_media_application/screens/profile/following_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? currentUser;
  bool isLoading = true;

  final List<String> postImages = List.generate(
    12,
    (index) => 'https://picsum.photos/500/500?random=${index + 10}',
  );

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        setState(() {
          currentUser = UserModel.fromJson(doc.data()!);
          isLoading = false;
        });
      } else {
        // Create a fallback UserModel from FirebaseAuth currentUser
        setState(() {
          currentUser = UserModel(
            id: 1,
            fullName: firebaseUser.displayName ?? 'User',
            username: firebaseUser.email?.split('@').first ?? 'user',
            email: firebaseUser.email ?? '',
            image: firebaseUser.photoURL ?? 'https://i.pravatar.cc/150?img=12',
            bio: 'Welcome to my profile 👋',
          );
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Profile Error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void openPost(int index) {
    if (currentUser == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PostDetails(
            postImages: postImages,
            initialIndex: index,
            username: currentUser!.username,
            profileImage: currentUser!.image,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final user = currentUser ??
        UserModel(
          id: 1,
          fullName: 'User Profile',
          username: 'user',
          email: '',
          image: 'https://i.pravatar.cc/150?img=12',
          bio: 'Welcome to my profile 👋',
        );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: Text(
          user.username,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: loadUser,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 54,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: NetworkImage(
                    user.image.isNotEmpty
                        ? user.image
                        : 'https://i.pravatar.cc/150?img=12',
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '@${user.username}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Text(
                    user.bio.isEmpty ? 'Welcome to my profile 👋' : user.bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat(context, '${postImages.length}', 'Posts'),
                    const SizedBox(width: 45),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FollowersScreen(),
                          ),
                        );
                      },
                      child: _buildStat(context, '50', 'Followers'),
                    ),
                    const SizedBox(width: 45),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FollowingScreen()),
                        );
                      },
                      child: _buildStat(context, '50', 'Following'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await context.push('/editProfile');
                        if (result == true) {
                          await loadUser();
                        }
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),

                const SizedBox(height: 15),

                Icon(Icons.grid_on_rounded, size: 24, color: colorScheme.onSurface),

                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: postImages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => openPost(index),
                      child: Image.network(
                        postImages[index],
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
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String number, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          number,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
      ],
    );
  }
}
