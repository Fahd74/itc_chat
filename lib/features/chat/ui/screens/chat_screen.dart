import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_cubit.dart';
import 'package:itc_chat/features/chat/data/datasources/gemini_datasource.dart';
import 'package:itc_chat/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_message.dart';
import 'package:itc_chat/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:itc_chat/features/chat/ui/cubit/cubit.dart';
import 'package:itc_chat/features/chat/ui/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls the chat list to the very bottom after the frame renders.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = GeminiDataSource(dotenv.env['GEMINI_API_KEY'] ?? '');
        final repository = ChatRepositoryImpl(dataSource: dataSource);
        final useCase = SendMessageUseCase(repository: repository);
        return ChatCubit(useCase);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: const Text('ITC Ai Chat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatCubit, ChatState>(
                  listener: (context, state) {
                    // Auto-scroll whenever messages change
                    _scrollToBottom();
                  },
                  builder: (context, state) {
                    List<ChatMessage> currentMessages = [];
                    bool isWaiting = false;

                    if (state is ChatWaitingForBot) {
                      currentMessages = state.messages;
                      isWaiting = true;
                    }
                    if (state is ChatUpdated) {
                      currentMessages = state.messages;
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      // +1 item for the typing indicator when waiting
                      itemCount: currentMessages.length + (isWaiting ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Last item when waiting = typing indicator
                        if (isWaiting && index == currentMessages.length) {
                          return const TypingIndicator();
                        }
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
