import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mini_social_media_application/models/post_model.dart';

// Auth
import 'package:mini_social_media_application/screens/auth/forgot_password_screen.dart';
import 'package:mini_social_media_application/screens/auth/login_screen.dart';
import 'package:mini_social_media_application/screens/auth/signup_screen.dart';

// Main screens
import 'package:mini_social_media_application/screens/home/home_screen.dart';
import 'package:mini_social_media_application/screens/search/search_screen.dart';
import 'package:mini_social_media_application/screens/chat/chat_screen.dart';
import 'package:mini_social_media_application/screens/profile/profile_screen.dart';
import 'package:mini_social_media_application/screens/postDetails/post_details.dart';

// Edit
import 'package:mini_social_media_application/screens/Edit/edit_profile.dart';

// Settings
import 'package:mini_social_media_application/screens/settings/settings_screen.dart';
import 'package:mini_social_media_application/screens/settings/settings/account_privacy.dart';
import 'package:mini_social_media_application/screens/settings/settings/block_screen.dart';
import 'package:mini_social_media_application/screens/settings/settings/notification_screen.dart';
import 'package:mini_social_media_application/screens/settings/settings/privacy_policy_screen.dart';
import 'package:mini_social_media_application/screens/settings/settings/save_post_screen.dart';
import 'package:mini_social_media_application/screens/settings/settings/terms_conditions.dart';

// Splash + Wrapper
import 'package:mini_social_media_application/screens/splash/splash_screen.dart';
import 'package:mini_social_media_application/screens/wrapper/wrapper_screen.dart';

// Bottom navigation
import 'package:mini_social_media_application/widgets/custom_bottom_nav.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      name: 'root',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/wrapper',
      name: 'wrapper',
      builder: (context, state) => const Wrapper(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Map<String, String?>) {
          return LoginScreen(
            initialEmail: extra['email'],
            initialPassword: extra['password'],
          );
        }
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/editProfile',
      name: 'editProfile',
      builder: (context, state) => const EditProfile(),
    ),
    GoRoute(
      path: '/accountPrivacy',
      name: 'accountPrivacy',
      builder: (context, state) => const AccountPrivacy(),
    ),
    GoRoute(
      path: '/notification',
      name: 'notification',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/blockScreen',
      name: 'blockScreen',
      builder: (context, state) => const BlockedAccountsScreen(),
    ),
    GoRoute(
      path: '/PrivacyPolicyScreen',
      name: 'PrivacyPolicyScreen',
      builder: (context, state) => const PrivacyCenterScreen(),
    ),
    GoRoute(
      path: '/SavePost',
      name: 'SavePost',
      builder: (context, state) => const SavePostScreen(),
    ),
    GoRoute(
      path: '/TermsConditions',
      name: 'TermsConditions',
      builder: (context, state) => const TermsConditionsScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return _AppNavigationShell(currentPath: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/post/:id',
          name: 'postDetail',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is PostModel) {
              return PostDetails(
                postImages: [extra.image],
                initialIndex: 0,
                username: 'User ${extra.userId}',
                profileImage:
                    'https://i.pravatar.cc/150?img=${(extra.userId % 70) + 1}',
              );
            }
            return PostDetails(
              postImages: const ['https://picsum.photos/500/500?random=1'],
              initialIndex: 0,
              username: 'User',
              profileImage: 'https://i.pravatar.cc/150?img=1',
            );
          },
        ),
      ],
    ),
  ],
);

class _AppNavigationShell extends StatelessWidget {
  const _AppNavigationShell({required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  int get _currentIndex {
    if (currentPath.startsWith('/search')) return 1;
    if (currentPath.startsWith('/chat')) return 2;
    if (currentPath.startsWith('/profile')) return 3;
    return 0; // /home
  }

  void _showCreatePost(BuildContext context) {
    final titleController = TextEditingController();
    final captionController = TextEditingController();
    final ImagePicker picker = ImagePicker();
    String? selectedImagePath;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create New Post',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setStateModal(() {
                                  selectedImagePath = image.path;
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Gallery'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final image = await picker.pickImage(
                                source: ImageSource.camera,
                              );
                              if (image != null) {
                                setStateModal(() {
                                  selectedImagePath = image.path;
                                });
                              }
                            },
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                          ),
                        ),
                      ],
                    ),
                    if (selectedImagePath != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Image selected!",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setStateModal(() {
                                  selectedImagePath = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Post Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: captionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Write a caption...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty &&
                              captionController.text.trim().isEmpty &&
                              selectedImagePath == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please add content or an image'),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(bottomSheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post published successfully! 🎉'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(
                          'Share Post',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onAddPressed: () {
          _showCreatePost(context);
        },
      ),
    );
  }
}
