import 'package:flutter/material.dart';

class AccountPrivacy extends StatefulWidget {
  const AccountPrivacy({super.key});

  @override
  State<AccountPrivacy> createState() => _AccountPrivacyState();
}

class _AccountPrivacyState extends State<AccountPrivacy> {
  bool isPrivateAccount = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Account Privacy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Private Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPrivateAccount
                          ? "Only people you approve can see your posts"
                          : "Anyone can see your profile and posts",
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isPrivateAccount,
                activeThumbColor: colorScheme.primary,
                onChanged: (value) {
                  setState(() {
                    isPrivateAccount = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'When your account is private, only people you approve can see your photos, videos, followers, and following list. Your existing followers won’t be affected.',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}