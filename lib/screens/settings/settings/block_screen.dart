import 'package:flutter/material.dart';
import 'package:mini_social_media_application/models/user_model.dart';
import 'package:mini_social_media_application/services/blocked_users_service.dart';
import 'package:mini_social_media_application/services/user_service.dart';

class BlockedAccountsScreen extends StatefulWidget {
  const BlockedAccountsScreen({super.key});

  @override
  State<BlockedAccountsScreen> createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  final BlockedUsersService _blockedUsersService = BlockedUsersService.instance;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _blockedUsersService.init();
  }

  void _showAddBlockModal() {
    final searchController = TextEditingController();
    List<UserModel> allUsers = [];
    List<UserModel> searchResults = [];
    bool isLoading = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (allUsers.isEmpty && isLoading) {
              _userService
                  .getUsers()
                  .then((fetched) {
                    if (modalContext.mounted) {
                      setModalState(() {
                        allUsers = fetched;
                        searchResults = fetched;
                        isLoading = false;
                      });
                    }
                  })
                  .catchError((_) {
                    if (modalContext.mounted) {
                      setModalState(() {
                        isLoading = false;
                      });
                    }
                  });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Block an Account",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search accounts to block...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (query) {
                          setModalState(() {
                            final q = query.trim().toLowerCase();
                            searchResults = allUsers.where((u) {
                              return u.fullName.toLowerCase().contains(q) ||
                                  u.username.toLowerCase().contains(q);
                            }).toList();
                          });
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : (searchResults.isEmpty
                                ? const Center(child: Text("No users found"))
                                : ListView.separated(
                                    itemCount: searchResults.length,
                                    separatorBuilder: (_, _) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final user = searchResults[index];
                                      final isBlocked = _blockedUsersService
                                          .isBlocked(user.id);

                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            user.image,
                                          ),
                                        ),
                                        title: Text(
                                          user.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text("@${user.username}"),
                                        trailing: isBlocked
                                            ? const Text(
                                                "Blocked",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red.shade600,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                ),
                                                onPressed: () async {
                                                  await _blockedUsersService
                                                      .blockUser(
                                                        userId: user.id,
                                                        username: user.username,
                                                        fullName: user.fullName,
                                                        image: user.image,
                                                      );
                                                  setModalState(() {});
                                                  if (modalContext.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "Blocked @${user.username}",
                                                        ),
                                                        duration:
                                                            const Duration(
                                                              seconds: 1,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: const Text("Block"),
                                              ),
                                      );
                                    },
                                  )),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Blocked Accounts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: 'Block an account',
            onPressed: _showAddBlockModal,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _blockedUsersService,
        builder: (context, _) {
          final blockedUsers = _blockedUsersService.blockedUsers;

          if (blockedUsers.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.block_outlined,
                        size: 52,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No Blocked Accounts",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You haven't blocked anyone yet. You can block people anytime directly from their profile or using the add button above.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 220,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _showAddBlockModal,
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text("Block an Account"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _blockedUsersService.init(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: blockedUsers.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 70,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                final userId = user['userId'] is int
                    ? user['userId'] as int
                    : int.tryParse(user['userId']?.toString() ?? '0') ?? 0;
                final username = user['username']?.toString() ?? 'User';
                final fullName = user['fullName']?.toString() ?? username;
                final image =
                    user['image']?.toString() ??
                    'https://i.pravatar.cc/150?img=1';

                return ListTile(
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(image),
                  ),
                  title: Text(
                    fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("@$username"),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      foregroundColor: colorScheme.onSurface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () async {
                      await _blockedUsersService.unblockUser(userId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Unblocked @$username"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: const Text('Unblock'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
