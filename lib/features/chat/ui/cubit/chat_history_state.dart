/// Represents a single conversation in the sidebar.
class Conversation {
  final String id;
  final String title;
  final DateTime updatedAt;

  Conversation({required this.id, required this.title, required this.updatedAt});

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'New Chat',
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

// ─── States ───────────────────────────────────────────────────────

abstract class ChatHistoryState {}

class ChatHistoryInitial extends ChatHistoryState {}

class ChatHistoryLoading extends ChatHistoryState {}

class ChatHistoryLoaded extends ChatHistoryState {
  final List<Conversation> conversations;
  final String? activeConversationId;

  ChatHistoryLoaded({required this.conversations, this.activeConversationId});
}
