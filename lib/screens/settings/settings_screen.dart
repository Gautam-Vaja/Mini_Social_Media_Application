import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }

  Widget settingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget section(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: colorScheme.primary,
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
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          section(context, "Account"),
          settingTile(
            context: context,
            icon: Icons.person_outline,
            title: "Edit Profile",
            onTap: () {
              context.push('/editProfile');
            },
          ),
          settingTile(
            context: context,
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: () {
              context.push('/forgot-password');
            },
          ),
          section(context, "Privacy & Safety"),
          settingTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: "Account Privacy",
            onTap: () {
              context.push('/accountPrivacy');
            },
          ),
          settingTile(
            context: context,
            icon: Icons.notifications_none,
            title: "Notification Settings",
            onTap: () {
              context.push('/notification');
            },
          ),
          settingTile(
            context: context,
            icon: Icons.block_outlined,
            title: "Blocked Users",
            onTap: () {
              context.push('/blockScreen');
            },
          ),
          settingTile(
            context: context,
            icon: Icons.bookmark_border,
            title: "Saved Posts",
            onTap: () {
              context.push('/SavePost');
            },
          ),
          section(context, "About & Legal"),
          settingTile(
            context: context,
            icon: Icons.description_outlined,
            title: "Terms & Conditions",
            onTap: () {
              context.push('/TermsConditions');
            },
          ),
          settingTile(
            context: context,
            icon: Icons.policy_outlined,
            title: "Privacy Policy",
            onTap: () {
              context.push('/PrivacyPolicyScreen');
            },
          ),
          section(context, "Session"),
          settingTile(
            context: context,
            icon: Icons.logout,
            title: "Log Out",
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text("Log Out"),
                  content: const Text(
                    "Are you sure you want to log out of your account?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        logout(context);
                      },
                      child: const Text("Log Out"),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
