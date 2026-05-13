import 'package:flutter/material.dart';
import '../../../chat/ui/widgets/sidebar_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ai Academic Assistant',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      drawer: const SidebarWidget(), // Injected new drawer here
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  //   decoration: const BoxDecoration(
                  //     color: Color(0xFF0F766E), // Teal color
                  //     borderRadius: BorderRadius.only(
                  //       bottomLeft: Radius.circular(0),
                  //       bottomRight: Radius.circular(0),
                  //     ),
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Container(
                  //         padding: const EdgeInsets.all(8),
                  //         decoration: ShapeDecoration(
                  //           color: const Color(0x33000000), // Semi-transparent dark
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //             side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  //           ),
                  //         ),
                  //         child: InkWell(
                  //           onTap: () {
                  //             Scaffold.of(context).openDrawer();
                  //           },
                  //           child: const Icon(
                  //             Icons.school_outlined,
                  //             color: Colors.white,
                  //             size: 20,
                  //           ),
                  //         ),
                  //       ),
                  //       const Text(
                  //         'Ai Academic Assistant',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.all(8),
                  //         decoration: ShapeDecoration(
                  //           color: const Color(0x33000000), // Semi-transparent dark
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //             side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  //           ),
                  //         ),
                  //         child: const Icon(
                  //           Icons.school_outlined,
                  //           color: Colors.white,
                  //           size: 20,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 40),

                  // Profile Information
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
                              color: const Color(0xFF0F766E).withValues(alpha: 0.3),
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name Text
                        const Text(
                          'Fares Mohamed',
                          style: TextStyle(
                            color: Color(0xFF2DD4BF), // Light Teal text
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Title Text
                        const Text(
                          'Grauate Researcher.Stanord Uni',
                          style: TextStyle(
                            color: Color(0xFFA3A3A3), // Light grey text
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
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
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
                        const SizedBox(width: 16),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF1E293B), // Dark slate
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFF334155), width: 1),
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
                              color: const Color(0xFF112220), // Very dark teal background
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Color(0xFF0F766E), // Teal border
                                  width: 1,
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
                                const Text(
                                  'BOOKS\nSUMMARIZED',
                                  style: TextStyle(
                                    color: Color(0xFFE2E8F0),
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
                              color: const Color(0xFF112220),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: const Color(
                                    0xFF0F766E,
                                  ).withValues(alpha: 0.5), // Lighter border
                                  width: 1,
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
                                const Text(
                                  'PROBLEMS\nSOLVED',
                                  style: TextStyle(
                                    color: Color(0xFFE2E8F0),
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
                          icon: Icons.menu_book_outlined,
                          title: 'My Learning Path',
                          subtitle: 'Personalized curriculum',
                        ),
                        _buildOptionTile(
                          icon: Icons.notifications_none_outlined,
                          title: 'Notifications',
                          subtitle: 'Updates and reminders',
                        ),
                        _buildOptionTile(
                          icon: Icons.api_outlined,
                          title: 'Academic Resources',
                          subtitle: 'Library & datasets',
                        ),
                        _buildOptionTile(
                          icon: Icons.shield_outlined,
                          title: 'Security',
                          subtitle: 'Privacy & account protection',
                        ),
                        _buildOptionTile(
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
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
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

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFF112220),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: const Color(0xFF0F766E).withValues(alpha: 0.3), width: 1),
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
                color: const Color(0xFF0F766E).withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8), // slate-400
              fontSize: 13,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
        onTap: () {},
      ),
    );
  }
}
