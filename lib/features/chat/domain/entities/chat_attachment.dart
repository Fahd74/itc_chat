class ChatAttachment {
  final String path;
  final String name;
  final String? mimeType;
  final int size;

  ChatAttachment({
    required this.path,
    required this.name,
    this.mimeType,
    this.size = 0,
  });
}
