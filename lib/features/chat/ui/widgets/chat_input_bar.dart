import 'package:flutter/material.dart';
import 'package:itc_chat/core/widgets/widgets.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';

class ChatModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const ChatModel(this.id, this.title, this.subtitle, this.icon);
}

const List<ChatModel> availableModels = [
  ChatModel('gemini-2.5-flash', 'gemini-2.5-flash', 'Balanced responses', Icons.bolt),
  ChatModel('gemini-1.5-flash', 'gemini-1.5-flash', 'Quick responses', Icons.rocket_launch),
  ChatModel('llama-3.3-70b-versatile', 'Llama 3.3 70B', 'Versatile & Powerful', Icons.psychology),
  ChatModel('llama-3.2-11b-vision-preview', 'Llama Vision', 'Supports Images', Icons.image_search),
];

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String modelId) onSendPressed;
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
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  ChatModel _selectedModel = availableModels[0];

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _closeMenu();
    } else {
      _showMenu();
    }
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showMenu() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Stack(
          children: [
            // Dismiss area
            Positioned.fill(
              child: GestureDetector(onTap: _closeMenu, behavior: HitTestBehavior.opaque),
            ),
            Positioned(
              width: 280,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, -290), // Adjust to pop above the input
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 12, top: 4),
                          child: Text(
                            'Choose Your Assist',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...availableModels.map((model) {
                          final isSelected = _selectedModel.id == model.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedModel = model;
                              });
                              _closeMenu();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    model.icon,
                                    color: isSelected
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          model.title,
                                          style: TextStyle(
                                            color: isSelected
                                                ? colorScheme.onPrimaryContainer
                                                : colorScheme.onSurface,
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          model.subtitle,
                                          style: TextStyle(
                                            color: isSelected
                                                ? colorScheme.onPrimaryContainer.withValues(
                                                    alpha: 0.8,
                                                  )
                                                : colorScheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.draftAttachments.isNotEmpty)
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.draftAttachments.length,
                itemBuilder: (context, index) {
                  final attachment = widget.draftAttachments[index];
                  final isImage = attachment.mimeType?.startsWith('image/') == true;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isImage ? Icons.image : Icons.insert_drive_file,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          attachment.name.length > 15
                              ? '${attachment.name.substring(0, 15)}...'
                              : attachment.name,
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => widget.onRemoveAttachment(index),
                          child: Icon(Icons.close, size: 16, color: colorScheme.error),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Theme(
            data: Theme.of(
              context,
            ).copyWith(inputDecorationTheme: const InputDecorationTheme()),
            child: GlassEffect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Column(
                  children: [
                    TextField(
                      controller: widget.controller,
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                      minLines: 1,
                      maxLines: 4,
                      cursorColor: colorScheme.primary,
                      decoration: InputDecoration(
                        hintText: 'Ask anything',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 12,
                          bottom: 8,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: widget.onAddAttachmentPressed,
                          icon: Icon(Icons.add, color: colorScheme.onSurface),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 24,
                        ),
                        const SizedBox(width: 8),
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: GestureDetector(
                            onTap: _toggleMenu,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _selectedModel.icon,
                                    color: colorScheme.onSurface,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedModel.title,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => widget.onSendPressed(_selectedModel.id),
                          child: Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.send, color: colorScheme.onPrimary, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
