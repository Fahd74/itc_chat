import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/features/chat/data/models/chat_message.dart';
import 'package:itc_chat/features/chat/ui/cubit/cubit.dart';
import 'package:itc_chat/features/chat/ui/widgets/widgets.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text('ITC Ai Chat'),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    List<ChatMessage> currentMessages = [];
                    if (state is ChatWaitingForBot) {
                      currentMessages = state.messages;
                    }
                    if (state is ChatUpdated) {
                      currentMessages = state.messages;
                    }
                    return ListView.builder(
                      itemCount: currentMessages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(
                          text: currentMessages[index].text,
                          isUser: currentMessages[index].isUser,
                        );
                      },
                    );
                  },
                ),
              ),
              Builder(
                builder: (context) {
                  return ChatInputBar(
                    controller: _controller,
                    onSendPressed: () {
                      // استدعاء دالة الإرسال من الـ Cubit
                      context.read<ChatCubit>().sendMessage(_controller.text);
                      _controller.clear();
                    },
                    onAddAttachmentPressed: () {},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
