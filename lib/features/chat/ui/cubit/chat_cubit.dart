import 'chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_message.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';
import 'package:itc_chat/features/chat/domain/usecases/send_message_usecase.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;

  ChatCubit(this._sendMessageUseCase) : super(ChatInitial());

  // البيانات مخزنة هنا، وليس في الشاشة
  final List<ChatMessage> _messages = [];
  final List<ChatAttachment> _draftAttachments = [];

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

    // استدعاء الذكاء الاصطناعي
    final botResponse = await _sendMessageUseCase(text, attachments: attachments);

    _messages.add(ChatMessage(text: botResponse, isUser: false));

    // إشعار الشاشة بالحالة الجديدة
    emit(ChatUpdated(List.from(_messages)));
  }
}
