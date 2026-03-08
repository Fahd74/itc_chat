import 'package:flutter/material.dart';
import 'package:itc_chat/features/chat/ui/widgets/widgets.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Chat'), backgroundColor: Color(0x330F766E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [ChatInputBar()]),
      ),
    );
  }
}
