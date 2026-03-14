import 'dart:async';
import 'package:flutter/material.dart';
import 'package:itc_chat/core/config/app_theme.dart';
import 'package:itc_chat/features/onboarding/ui/screens/onbo.dart';
import 'package:itc_chat/features/screens.dart';
import 'package:device_preview/device_preview.dart';

void main() => runApp(
  DevicePreview(
    enabled: true,
    builder: (context) => MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ITC Ai Chat',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for 6 seconds (matches navigation delay)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Navigate after 6 seconds
    Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Onboarding()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Logo
            Image.asset(
              "assets/Dall-e_3__jan__24__artificial_intelligence_icon.png-removebg-preview.png",
              width: 186,
              height: 186,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 32),

            const Text(
              'AI Academic',
              style: TextStyle(
                color: Color(0xFF0F766E),
                fontSize: 32,
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'assistant',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1AB5A9),
                fontSize: 28,
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(flex: 3),

            // Animated Loading Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Background track
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      // Progress fill
                      FractionallySizedBox(
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            

                      const SizedBox(height: 40),

            
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:itc_chat/core/config/app_theme.dart';
import 'package:itc_chat/features/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ITC Ai Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const ChatScreen(),
    );
  }
}
