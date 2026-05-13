import 'chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_message.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';
import 'package:itc_chat/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:itc_chat/features/chat/data/datasources/chat_history_datasource.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final ChatHistoryDataSource _historyDataSource;

  ChatCubit(this._sendMessageUseCase, this._historyDataSource) : super(ChatInitial());

  // البيانات مخزنة هنا، وليس في الشاشة
  final List<ChatMessage> _messages = [];
  final List<ChatAttachment> _draftAttachments = [];
  String? _conversationId;
  bool _isFirstMessage = true;

  String? get conversationId => _conversationId;

  /// Loads messages for a given conversation from DB.
  Future<void> loadConversation(String conversationId) async {
    _conversationId = conversationId;
    _messages.clear();
    _draftAttachments.clear();

    try {
      final rows = await _historyDataSource.getMessages(conversationId);
      for (final row in rows) {
        _messages.add(ChatMessage(
          text: row['text'] as String,
          isUser: row['is_user'] as bool,
        ));
      }
      _isFirstMessage = _messages.where((m) => m.isUser).isEmpty;
    } catch (_) {
      // If loading fails, just start with empty messages
    }

    emit(ChatUpdated(List.from(_messages)));
  }

  /// Clears the current conversation (for "New Chat" scenario).
  void clearMessages() {
    _messages.clear();
    _draftAttachments.clear();
    _conversationId = null;
    _isFirstMessage = true;
    emit(ChatInitial());
  }

  void addAttachment(ChatAttachment attachment) {
    _draftAttachments.add(attachment);
    emit(ChatUpdated(List.from(_messages), draftAttachments: List.from(_draftAttachments)));
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < _draftAttachments.length) {
      _draftAttachments.removeAt(index);
      emit(ChatUpdated(List.from(_messages), draftAttachments: List.from(_draftAttachments)));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty && _draftAttachments.isEmpty) return;

    final attachments = List<ChatAttachment>.from(_draftAttachments);
    _draftAttachments.clear();

    _messages.add(ChatMessage(text: text, isUser: true, attachments: attachments));

    // إشعار الشاشة بتحديث القائمة (تظهر رسالة الطالب فوراً)
    emit(ChatWaitingForBot(List.from(_messages)));

    // Save user message to DB
    if (_conversationId != null) {
      try {
        await _historyDataSource.saveMessage(
          conversationId: _conversationId!,
          text: text,
          isUser: true,
        );

        // Auto-generate title from first user message
        if (_isFirstMessage && text.trim().isNotEmpty) {
          _isFirstMessage = false;
          final title = text.trim().length > 40
              ? '${text.trim().substring(0, 40)}...'
              : text.trim();
          await _historyDataSource.updateConversationTitle(_conversationId!, title);
        }

        // Touch conversation so it floats to top
        await _historyDataSource.touchConversation(_conversationId!);
      } catch (_) {
        // Don't block the chat if DB save fails
      }
    }

    // استدعاء الذكاء الاصطناعي
    final botResponse = await _sendMessageUseCase(text, attachments: attachments);

    _messages.add(ChatMessage(text: botResponse, isUser: false));

    // Save bot response to DB
    if (_conversationId != null) {
      try {
        await _historyDataSource.saveMessage(
          conversationId: _conversationId!,
          text: botResponse,
          isUser: false,
        );
      } catch (_) {
        // Don't block the chat if DB save fails
      }
    }

    // إشعار الشاشة بالحالة الجديدة
    emit(ChatUpdated(List.from(_messages)));
  }
}

