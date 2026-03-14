import 'package:flutter/material.dart';
import 'package:itc_chat/core/config/app_theme.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
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
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: const Color(
                            0x330F766E,
                          ), // Teal tint background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: const Color(
                                0xFF0F766E,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: Colors.white,
                          size: 24,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: ShapeDecoration(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(
                                    0xFF0F766E,
                                  ).withValues(alpha: 0.1),
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

                // Recent Research List
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: const Text(
                    'Recent Research',
                    style: TextStyle(
                      color: Color(0xFFA3A3A3),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: 4, // Number of items in design
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        leading: Icon(
                          Icons.history,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        title: Text(
                          'Recent Research',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.8)
                                : const Color(0xFF999999),
                            fontSize: 14,
                            fontFamily: 'Public Sans',
                            fontWeight: isDark
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
                        ),
                        onTap: () {},
                      );
                    },
                  ),
                ),

                // Footer Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: [
                      // Clear History
                      InkWell(
                        onTap: () {},
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
                                  fontWeight: isDark
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Dark Mode Toggle
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: themeNotifier,
                        builder: (context, currentMode, _) {
                          final isDark = currentMode == ThemeMode.dark;
                          return InkWell(
                            onTap: () {
                              themeNotifier.value = isDark
                                  ? ThemeMode.light
                                  : ThemeMode.dark;
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isDark
                                            ? Icons.dark_mode_outlined
                                            : Icons.light_mode_outlined,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Dark Mode',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.8,
                                                )
                                              : const Color(0xFF999999),
                                          fontSize: 15,
                                          fontFamily: 'Public Sans',
                                          fontWeight: isDark
                                              ? FontWeight.w500
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Custom switch representation
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 44,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isDark
                                          ? const Color(0xFF0F766E)
                                          : const Color(0xFF1E293B),
                                    ),
                                    child: AnimatedAlign(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      alignment: isDark
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Sign Out
                      InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.logout,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sign Out',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.redAccent
                                      : const Color(0xFFF30A0A),
                                  fontSize: 15,
                                  fontFamily: 'Public Sans',
                                  fontWeight: isDark
                                      ? FontWeight.w500
                                      : FontWeight.w600,
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
                              : const Color(
                                  0xFFE6F2F1,
                                ), // Very dark teal or light teal tint
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : const Color(
                                      0xFF0F766E,
                                    ).withValues(alpha: 0.1),
                            ),
                          ),
                        ),
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
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Alaa Ahmed', // Updated name based on requirement
                                    style: TextStyle(
                                      color: Color(0xFF0F766E), // Teal name
                                      fontSize: 14,
                                      fontFamily: 'Public Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Alaa Ahmed@Gmail.Com',
                                    style: TextStyle(
                                      color: Color(
                                        0xFF666666,
                                      ), // Subtitle color
                                      fontSize: 11,
                                      fontFamily: 'Public Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.more_vert,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : const Color(0xFF999999),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
