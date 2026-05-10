import 'package:flutter/material.dart';
import 'package:itc_chat/core/widgets/widgets.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onAddAttachmentPressed;
  final List<ChatAttachment> draftAttachments;
  final Function(int) onRemoveAttachment;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.onAddAttachmentPressed,
    this.draftAttachments = const [],
    required this.onRemoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (draftAttachments.isNotEmpty)
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: draftAttachments.length,
                itemBuilder: (context, index) {
                  final attachment = draftAttachments[index];
                  final isImage = attachment.mimeType?.startsWith('image/') == true;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isImage ? Icons.image : Icons.insert_drive_file,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          attachment.name.length > 15 
                              ? '${attachment.name.substring(0, 15)}...' 
                              : attachment.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onRemoveAttachment(index),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Theme(
            data: Theme.of(context).copyWith(inputDecorationTheme: const InputDecorationTheme()),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onAddAttachmentPressed,
                  child: GlassEffect(
                    borderRadius: BorderRadiusGeometry.circular(30),
                    child: const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 26,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GlassEffect(
                    borderRadius: BorderRadius.circular(20),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      minLines: 1,
                      maxLines: 4,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Ask AI',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(left: 20, right: 10, top: 14, bottom: 14),
                        suffixIcon: GestureDetector(
                          onTap: onSendPressed,
                          child: const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(Icons.send_outlined, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
