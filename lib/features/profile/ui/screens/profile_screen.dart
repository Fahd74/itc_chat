import 'package:flutter/material.dart';
import '../../../chat/ui/widgets/sidebar_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        elevation: 3,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.school_outlined,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Assist AI', style: TextStyle(color: Theme.of(context).primaryColor)),
      ),
      drawer: const SidebarWidget(), // Injected new drawer here
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Information
                  SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        // Profile Image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name Text
                        Text(
                          'Fahd Mohamed',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor, // Light Teal text
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Title Text
                        Text(
                          'Software Engineering Student',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant, // Light grey text
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Edit profile',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Learning Stats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Learning stats',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: ShapeDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest, // Very dark teal background
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor, // Teal border
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '40',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'BOOKS\nSUMMARIZED',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: ShapeDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor, // Lighter border
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '120',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'PROBLEMS\nSOLVED',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Options List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildOptionTile(
                          context,
                          icon: Icons.menu_book_outlined,
                          title: 'My Learning Path',
                          subtitle: 'Personalized curriculum',
                        ),
                        _buildOptionTile(
                          context,
                          icon: Icons.notifications_none_outlined,
                          title: 'Notifications',
                          subtitle: 'Updates and reminders',
                        ),
                        _buildOptionTile(
                          context,
                          icon: Icons.api_outlined,
                          title: 'Academic Resources',
                          subtitle: 'Library & datasets',
                        ),
                        _buildOptionTile(
                          context,
                          icon: Icons.shield_outlined,
                          title: 'Security',
                          subtitle: 'Privacy & account protection',
                        ),
                        _buildOptionTile(
                          context,
                          icon: Icons.headset_mic_outlined,
                          title: 'Academic Support',
                          subtitle: '24/7 AI & human assistance',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Log Out Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Log Out',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.logout, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant, // slate-400
              fontSize: 13,
            ),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor, size: 20),
        onTap: () {},
      ),
    );
  }
}
