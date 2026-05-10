import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:itc_chat/core/constants/constants.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final String text = message.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نستخدم Flexible لضمان عدم حدوث Overflow إذا كان النص طويلاً
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8, // أقصى عرض 80% من الشاشة
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // 1. رأس رسالة المساعد (يظهر فقط إذا لم يكن المستخدم)
                  if (!isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'assistant',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],

                  // 2. فقاعة النص
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.genoa700
                          : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.attachments.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: message.attachments.map((attachment) {
                              final isImage = attachment.mimeType?.startsWith('image/') == true;
                              if (isImage) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(attachment.path),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.insert_drive_file, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        attachment.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          if (text.isNotEmpty) const SizedBox(height: 8),
                        ],
                        if (text.isNotEmpty)
                          MarkdownBody(
                            data: text,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                              h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              h2: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              h3: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              h4: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              h5: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              h6: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              em: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                              strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              code: const TextStyle(
                                backgroundColor: Colors.black26,
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              blockquoteDecoration: const BoxDecoration(
                                border: Border(left: BorderSide(color: Colors.white54, width: 4)),
                              ),
                              blockquote: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                              listBullet: const TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 3. أزرار التفاعل السفلية (نسخ النص)
                  if (text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: text));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('تم نسخ النص', style: TextStyle(color: Colors.white)),
                              backgroundColor: AppColors.genoa700,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.copy,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
