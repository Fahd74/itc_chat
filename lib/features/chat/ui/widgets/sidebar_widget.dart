import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_cubit.dart';
import 'package:itc_chat/features/profile/ui/screens/profile_screen.dart';
import 'package:itc_chat/features/chat/ui/cubit/chat_history_cubit.dart';
import 'package:itc_chat/features/chat/ui/cubit/chat_history_state.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Logo and App Name
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    decoration: ShapeDecoration(
                      color: Colors.transparent, // Teal tint background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Image.asset(
                      'assets/Logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ai Assistant',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 18,
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Academic Research',
                        style: TextStyle(
                          color: Color(0xFF9C9C9C),
                          fontSize: 12,
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // New Research Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  final historyCubit = context.read<ChatHistoryCubit>();
                  historyCubit.createNewConversation();
                  Navigator.pop(context); // Close drawer
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  ); // Go back to ChatScreen if in another screen like Profile
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: ShapeDecoration(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFF0F766E).withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFF0F766E),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'New Research',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : const Color(0xFF0F766E),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recent Research Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: const Text(
                'Recent Research',
                style: TextStyle(
                  color: Color(0xFFA3A3A3),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Real Conversation List from ChatHistoryCubit
            Expanded(
              child: BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
                builder: (context, state) {
                  if (state is ChatHistoryLoaded) {
                    final conversations = state.conversations;
                    final activeId = state.activeConversationId;

                    if (conversations.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No conversations yet.\nTap "New Research" to start!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : const Color(0xFF999999),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conv = conversations[index];
                        final isActive = conv.id == activeId;

                        return Dismissible(
                          key: Key(conv.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.redAccent.withValues(alpha: 0.3),
                            child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          ),
                          onDismissed: (_) {
                            context.read<ChatHistoryCubit>().deleteConversation(conv.id);
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                            selected: isActive,
                            selectedTileColor: isDark
                                ? const Color(0xFF0F766E).withValues(alpha: 0.15)
                                : const Color(0xFF0F766E).withValues(alpha: 0.08),
                            leading: Icon(
                              isActive ? Icons.chat_bubble : Icons.history,
                              color: isActive
                                  ? const Color(0xFF0F766E)
                                  : Colors.white.withValues(alpha: 0.5),
                              size: 20,
                            ),
                            title: Text(
                              conv.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isActive
                                    ? const Color(0xFF0F766E)
                                    : isDark
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : const Color(0xFF999999),
                                fontSize: 14,
                                fontFamily: 'Public Sans',
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              context.read<ChatHistoryCubit>().selectConversation(conv.id);
                              Navigator.pop(context); // Close drawer
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              ); // Go back to ChatScreen
                            },
                          ),
                        );
                      },
                    );
                  }

                  // Loading or initial state
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF0F766E),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // Clear History
                  InkWell(
                    onTap: () {
                      // Show confirmation dialog before clearing
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          title: const Text('Clear All History?'),
                          content: const Text(
                            'This will delete all your conversations permanently.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Color(0xFF0F766E)),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<ChatHistoryCubit>().clearAllHistory();
                                Navigator.pop(dialogContext); // Close dialog
                                Navigator.pop(context); // Close drawer
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                ); // Go back to ChatScreen
                              },
                              child: const Text(
                                'Delete All',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cleaning_services_outlined,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : const Color(0xFF999999),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Clear History',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : const Color(0xFF999999),
                              fontSize: 15,
                              fontFamily: 'Public Sans',
                              fontWeight: isDark ? FontWeight.w500 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sign Out
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        context.read<AuthCubit>().logout();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.redAccent, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              color: isDark ? Colors.redAccent : const Color(0xFFF30A0A),
                              fontSize: 15,
                              fontFamily: 'Public Sans',
                              fontWeight: isDark ? FontWeight.w500 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Profile Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: isDark
                          ? const Color(0xFF112220)
                          : const Color(0xFFE6F2F1), // Very dark teal or light teal tint
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFF0F766E).withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green, // Green status border
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 24,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Fahd Mohamed',
                                  style: TextStyle(
                                    color: Color(0xFF0F766E), // Teal name
                                    fontSize: 14,
                                    fontFamily: 'Public Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Fahd@Gmail.Com',
                                  style: TextStyle(
                                    color: Color(0xFF666666), // Subtitle color
                                    fontSize: 11,
                                    fontFamily: 'Public Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
