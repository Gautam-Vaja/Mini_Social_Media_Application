import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback? onTap;

  const ChatTile({
    super.key,
    required this.chat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ==================================================
              // PROFILE IMAGE
              // ==================================================

              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,

                    backgroundColor:
                        colorScheme.surfaceContainerHighest,

                    backgroundImage:
                        chat.image.isNotEmpty
                            ? NetworkImage(chat.image)
                            : null,

                    child: chat.image.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 30,
                            color:
                                colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),

                  // ONLINE DOT
                  if (chat.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 15,
                        height: 15,

                        decoration: BoxDecoration(
                          color: Colors.green,

                          shape: BoxShape.circle,

                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // ==================================================
              // CHAT INFORMATION
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ============================================
                    // NAME + TIME
                    // ============================================

                    Row(
                      children: [
                        // NAME
                        Expanded(
                          child: Text(
                            chat.name,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style: TextStyle(
                              color:
                                  colorScheme.onSurface,

                              fontSize: 16,

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // TIME
                        Flexible(
                          child: Text(
                            chat.time,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style: TextStyle(
                              color: colorScheme
                                  .onSurfaceVariant,

                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // ============================================
                    // LAST MESSAGE
                    // ============================================

                    Row(
                      children: [
                        // READ CHECK
                        if (chat.isRead) ...[
                          Icon(
                            Icons.done_all,
                            color:
                                colorScheme.primary,
                            size: 18,
                          ),

                          const SizedBox(width: 4),
                        ],

                        // MESSAGE
                        Expanded(
                          child: Text(
                            chat.message,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style: TextStyle(
                              color: colorScheme
                                  .onSurfaceVariant,

                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ==================================================
              // UNREAD BADGE
              // ==================================================

              if (chat.unread > 0) ...[
                const SizedBox(width: 8),

                Container(
                  constraints:
                      const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),

                  decoration: BoxDecoration(
                    color: colorScheme.primary,

                    shape: BoxShape.circle,
                  ),

                  alignment: Alignment.center,

                  child: Text(
                    chat.unread > 99
                        ? '99+'
                        : chat.unread.toString(),

                    maxLines: 1,

                    style: TextStyle(
                      color:
                          colorScheme.onPrimary,

                      fontSize: 10,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}