import 'dart:typed_data';

class ChatAttachment {
  final String path;
  final String name;
  final String? mimeType;
  final int size;
  /// Pre-loaded file bytes. When set, data sources should use this
  /// instead of reading from [path] (which may point to a volatile cache).
  final Uint8List? bytes;

  ChatAttachment({
    required this.path,
    required this.name,
    this.mimeType,
    this.size = 0,
    this.bytes,
  });
}

