import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/core/config/app_theme.dart';
import 'package:itc_chat/features/chat/ui/cubit/cubit.dart';
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
      home: BlocProvider(create: (context) => ChatCubit(), child: ChatScreen()),
    );
  }
}
