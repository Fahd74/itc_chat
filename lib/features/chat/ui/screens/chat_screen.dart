import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:itc_chat/features/chat/data/datasources/gemini_datasource.dart';
import 'package:itc_chat/features/chat/data/datasources/chat_history_datasource.dart';
import 'package:itc_chat/features/chat/data/datasources/groq_datasource.dart';
import 'package:itc_chat/features/chat/data/datasources/hybrid_datasource.dart';
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
    // Always use HybridDataSource (direct Gemini + Groq) which includes
    // system prompts with subject catalog. The backend RAG server is only
    // used when explicitly enabled AND running.
    final geminiDs = GeminiDataSource(dotenv.env['GEMINI_API_KEY'] ?? '');
    final groqDs = GroqDataSource(dotenv.env['GROQ_API_KEY'] ?? '');
    final dataSource = HybridDataSource(
      geminiDataSource: geminiDs,
      groqDataSource: groqDs,
    );

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
    
    // Use setConversationId instead of loadConversation to avoid
    // emitting ChatUpdated([]) which would erase the user's message
    // and hide the typing indicator.
    _chatCubit.setConversationId(newId);
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

          drawer: const SidebarWidget(),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(10.0),
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

                    if (currentMessages.isEmpty && !isWaiting) {
                      return Center(
                        child: Opacity(
                          opacity: 0.5,
                          child: Image.asset('assets/Logo.png', width: 500, height: 500),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
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
                          onSendPressed: (model) async {
                            final text = _controller.text;
                            if (text.trim().isEmpty) return;

                            // Clear input immediately for instant feedback
                            _controller.clear();

                            // Ensure we have a conversation before sending
                            await _ensureConversation();

                            // Send message (don't await — let it run in background
                            // so the UI stays responsive with the typing indicator)
                            context.read<ChatCubit>().sendMessage(text, model: model);

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
