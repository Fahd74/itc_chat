import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:itc_chat/features/chat/data/datasources/chat_datasource.dart';
import 'package:itc_chat/features/chat/data/datasources/gemini_datasource.dart';
import 'package:itc_chat/features/chat/data/datasources/backend_datasource.dart';
import 'package:itc_chat/features/chat/data/datasources/chat_history_datasource.dart';
import 'package:itc_chat/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_message.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';
import 'package:itc_chat/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:itc_chat/features/chat/ui/cubit/cubit.dart';
import 'package:itc_chat/features/chat/ui/cubit/chat_history_cubit.dart';
import 'package:itc_chat/features/chat/ui/cubit/chat_history_state.dart';
import 'package:itc_chat/features/chat/ui/widgets/widgets.dart';
import 'package:itc_chat/features/chat/ui/widgets/sidebar_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatCubit _chatCubit;
  late final ChatHistoryDataSource _historyDs;

  @override
  void initState() {
    super.initState();

    // --- Data Source Selection (Strategy Pattern) ---
    final backendUrl = dotenv.env['BACKEND_URL'];
    final ChatDataSource dataSource;

    if (backendUrl != null && backendUrl.isNotEmpty) {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      dataSource = BackendDataSource(baseUrl: backendUrl, authToken: token);
    } else {
      dataSource = GeminiDataSource(dotenv.env['GEMINI_API_KEY'] ?? '');
    }

    final repository = ChatRepositoryImpl(dataSource: dataSource);
    final useCase = SendMessageUseCase(repository: repository);
    _historyDs = ChatHistoryDataSource(client: Supabase.instance.client);
    _chatCubit = ChatCubit(useCase, _historyDs);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _chatCubit.close();
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

  /// Called when the user taps "New Research" or sends the first message.
  Future<void> _ensureConversation() async {
    if (_chatCubit.conversationId != null) return;

    // Create a new conversation in Supabase and set it active
    final historyCubit = context.read<ChatHistoryCubit>();
    final newId = await historyCubit.createNewConversation();
    _chatCubit.loadConversation(newId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>.value(
      value: _chatCubit,
      child: BlocListener<ChatHistoryCubit, ChatHistoryState>(
        listener: (context, historyState) {
          // When the active conversation changes in the sidebar, load its messages
          if (historyState is ChatHistoryLoaded) {
            final activeId = historyState.activeConversationId;
            if (activeId != null && activeId != _chatCubit.conversationId) {
              _chatCubit.loadConversation(activeId);
            } else if (activeId == null) {
              _chatCubit.clearMessages();
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.school_outlined, color: Colors.white, size: 24),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: const Text('ITC Ai Chat'),
          ),
          drawer: const SidebarWidget(),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                BlocConsumer<ChatCubit, ChatState>(
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
                      padding: const EdgeInsets.only(bottom: 50),
                      controller: _scrollController,
                      itemCount: currentMessages.length + (isWaiting ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (isWaiting && index == currentMessages.length) {
                          return const TypingIndicator();
                        }
                        return MessageBubble(message: currentMessages[index]);
                      },
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    return BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, state) {
                        List<ChatAttachment> drafts = [];
                        if (state is ChatUpdated) drafts = state.draftAttachments;

                        return ChatInputBar(
                          controller: _controller,
                          draftAttachments: drafts,
                          onSendPressed: () async {
                            final text = _controller.text;
                            if (text.trim().isEmpty) return;

                            // Ensure we have a conversation before sending
                            await _ensureConversation();

                            context.read<ChatCubit>().sendMessage(text);
                            _controller.clear();

                            // Refresh sidebar to show updated title
                            context.read<ChatHistoryCubit>().loadConversations();
                          },
                          onAddAttachmentPressed: () async {
                            FilePickerResult? result = await FilePicker.pickFiles(
                              allowMultiple: true,
                              type: FileType.custom,
                              allowedExtensions: [
                                'jpg',
                                'png',
                                'pdf',
                                'mp3',
                                'txt',
                                'docx',
                                'doc',
                                'ogg',
                                'mp4',
                              ],
                            );

                            if (!context.mounted) return;

                            if (result != null) {
                              for (var file in result.files) {
                                if (file.path != null) {
                                  // Eagerly read bytes NOW before cache is cleaned
                                  final fileBytes = await File(file.path!).readAsBytes();
                                  if (!context.mounted) return;

                                  context.read<ChatCubit>().addAttachment(
                                    ChatAttachment(
                                      path: file.path!,
                                      name: file.name,
                                      size: file.size,
                                      bytes: fileBytes,
                                      mimeType:
                                          file.extension == 'jpg' || file.extension == 'png'
                                          ? 'image/${file.extension}'
                                          : file.extension == 'mp3' ||
                                                file.extension == 'ogg' ||
                                                file.extension == 'mp4'
                                          ? 'audio/${file.extension}'
                                          : file.extension == 'pdf' ||
                                                file.extension == 'doc' ||
                                                file.extension == 'docx'
                                          ? 'application/${file.extension}'
                                          : 'text/plain',
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          onRemoveAttachment: (index) {
                            context.read<ChatCubit>().removeAttachment(index);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

