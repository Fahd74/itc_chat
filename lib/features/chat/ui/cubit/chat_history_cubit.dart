import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/features/chat/data/datasources/chat_history_datasource.dart';
import 'chat_history_state.dart';

/// Manages the list of conversations and which one is currently active.
/// This cubit is provided at the app level so both the sidebar and
/// the chat screen can access it.
class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  final ChatHistoryDataSource _dataSource;

  ChatHistoryCubit(this._dataSource) : super(ChatHistoryInitial());

  String? get activeConversationId {
    final s = state;
    if (s is ChatHistoryLoaded) return s.activeConversationId;
    return null;
  }

  List<Conversation> get conversations {
    final s = state;
    if (s is ChatHistoryLoaded) return s.conversations;
    return [];
  }

  // ─── Load all conversations ──────────────────────────────────

  Future<void> loadConversations() async {
    try {
      final rows = await _dataSource.getConversations();
      final list = rows.map((r) => Conversation.fromMap(r)).toList();

      // Preserve active conversation if it still exists
      String? activeId = activeConversationId;
      if (activeId != null && !list.any((c) => c.id == activeId)) {
        activeId = null;
      }

      emit(ChatHistoryLoaded(
        conversations: list,
        activeConversationId: activeId,
      ));
    } catch (e) {
      // On error, emit empty state so the UI doesn't break
      emit(ChatHistoryLoaded(conversations: [], activeConversationId: null));
    }
  }

  // ─── Create a new conversation ───────────────────────────────

  /// Creates a new conversation and sets it as active.
  /// Returns the new conversation ID.
  Future<String> createNewConversation() async {
    final row = await _dataSource.createConversation(title: 'New Chat');
    final newConv = Conversation.fromMap(row);

    // Reload the full list so ordering is correct
    await loadConversations();

    // Set the new one as active
    final s = state;
    if (s is ChatHistoryLoaded) {
      emit(ChatHistoryLoaded(
        conversations: s.conversations,
        activeConversationId: newConv.id,
      ));
    }

    return newConv.id;
  }

  // ─── Select an existing conversation ─────────────────────────

  void selectConversation(String conversationId) {
    final s = state;
    if (s is ChatHistoryLoaded) {
      emit(ChatHistoryLoaded(
        conversations: s.conversations,
        activeConversationId: conversationId,
      ));
    }
  }

  // ─── Delete a single conversation ────────────────────────────

  Future<void> deleteConversation(String conversationId) async {
    await _dataSource.deleteConversation(conversationId);
    await loadConversations();

    // If we deleted the active conversation, clear the selection
    final s = state;
    if (s is ChatHistoryLoaded && s.activeConversationId == conversationId) {
      emit(ChatHistoryLoaded(
        conversations: s.conversations,
        activeConversationId: null,
      ));
    }
  }

  // ─── Delete all conversations ────────────────────────────────

  Future<void> clearAllHistory() async {
    await _dataSource.deleteAllConversations();
    emit(ChatHistoryLoaded(conversations: [], activeConversationId: null));
  }

  // ─── Update conversation title ───────────────────────────────

  Future<void> updateTitle(String conversationId, String title) async {
    await _dataSource.updateConversationTitle(conversationId, title);
    await loadConversations();
  }
}
