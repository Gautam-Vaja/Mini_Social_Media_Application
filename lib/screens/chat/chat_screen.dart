import 'package:flutter/material.dart';
import 'package:mini_social_media_application/screens/chatDetails/chat_details.dart';
import 'package:mini_social_media_application/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService chatService = ChatService();

  List chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  Future<void> loadChats() async {
    try {
      chats = await chatService.getChats();
    } catch (e, s) {
      debugPrint("Chat Error: $e\n$s");
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void openChat(dynamic chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ChatDetailScreen(name: chat.name, image: chat.image);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Messages",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: loadChats, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
            : chats.isEmpty
            ? Center(
                child: Text(
                  "No chats found",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: loadChats,
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: chats.length > 50 ? 50 : chats.length,
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 1,
                      indent: 72,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    );
                  },
                  itemBuilder: (context, index) {
                    final chat = chats[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundImage:
                                chat.image != null && chat.image.isNotEmpty
                                ? NetworkImage(chat.image)
                                : null,
                            child: chat.image == null || chat.image.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 13,
                              height: 13,
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
                      title: Text(
                        chat.name,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        chat.message ?? "Tap to message",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        chat.time ?? "09:30 AM",
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => openChat(chat),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
