import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for managing chat history persistence in Supabase.
/// Handles CRUD operations for conversations and messages tables.
class ChatHistoryDataSource {
  final SupabaseClient _client;

  ChatHistoryDataSource({required SupabaseClient client}) : _client = client;

  // ─── Conversations ─────────────────────────────────────────────

  /// Fetches all conversations for the current user, newest first.
  Future<List<Map<String, dynamic>>> getConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('conversations')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Creates a new conversation and returns the inserted row.
  Future<Map<String, dynamic>> createConversation({String title = 'New Chat'}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('conversations')
        .insert({'user_id': userId, 'title': title})
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  /// Updates the title of a conversation.
  Future<void> updateConversationTitle(String conversationId, String title) async {
    await _client
        .from('conversations')
        .update({'title': title, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', conversationId);
  }

  /// Touches `updated_at` so the conversation floats to top of sidebar.
  Future<void> touchConversation(String conversationId) async {
    await _client
        .from('conversations')
        .update({'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', conversationId);
  }

  /// Deletes a single conversation (cascade deletes its messages via FK).
  Future<void> deleteConversation(String conversationId) async {
    await _client.from('conversations').delete().eq('id', conversationId);
  }

  /// Deletes ALL conversations for the current user.
  Future<void> deleteAllConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('conversations').delete().eq('user_id', userId);
  }

  // ─── Messages ──────────────────────────────────────────────────

  /// Fetches all messages for a given conversation, oldest first.
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Saves a single message to a conversation.
  Future<void> saveMessage({
    required String conversationId,
    required String text,
    required bool isUser,
  }) async {
    await _client.from('messages').insert({
      'conversation_id': conversationId,
      'text': text,
      'is_user': isUser,
    });
  }
}
