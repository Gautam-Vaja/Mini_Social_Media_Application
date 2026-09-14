import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool pauseAll = false;
  bool postNotifications = true;
  bool messageNotifications = true;
  bool followNotifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Push Notifications',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Pause All Notifications'),
            subtitle: const Text('Temporarily pause push alerts'),
            value: pauseAll,
            activeThumbColor: colorScheme.primary,
            onChanged: (value) {
              setState(() {
                pauseAll = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Posts & Comments'),
            subtitle: const Text('Likes, comments, and mentions on your posts'),
            value: !pauseAll && postNotifications,
            activeThumbColor: colorScheme.primary,
            onChanged: pauseAll
                ? null
                : (value) {
                    setState(() {
                      postNotifications = value;
                    });
                  },
          ),
          SwitchListTile(
            title: const Text('Direct Messages'),
            subtitle: const Text('New messages and chat requests'),
            value: !pauseAll && messageNotifications,
            activeThumbColor: colorScheme.primary,
            onChanged: pauseAll
                ? null
                : (value) {
                    setState(() {
                      messageNotifications = value;
                    });
                  },
          ),
          SwitchListTile(
            title: const Text('Followers & Activity'),
            subtitle: const Text('New followers and friend suggestions'),
            value: !pauseAll && followNotifications,
            activeThumbColor: colorScheme.primary,
            onChanged: pauseAll
                ? null
                : (value) {
                    setState(() {
                      followNotifications = value;
                    });
                  },
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Email & SMS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Weekly digest and security announcements'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}