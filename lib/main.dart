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
