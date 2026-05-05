import 'chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/features/chat/data/models/chat_message.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  // البيانات مخزنة هنا، وليس في الشاشة
  final List<ChatMessage> _messages = [];

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));

    // emit(ChatUpdated(List.from(_messages)));

    // إشعار الشاشة بتحديث القائمة (تظهر رسالة الطالب فوراً)
    // لاحظ أننا نرسل نسخة من القائمة List.from لضمان التحديث
    emit(ChatWaitingForBot(List.from(_messages)));

    // 3. محاكاة التأخير الزمني لانتظار رد الخادم/الذكاء الاصطناعي (ثانية ونصف)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 4. إضافة الرد الافتراضي للمساعد الأكاديمي
    final botResponse =
        "هذا رد افتراضي ومؤقت من المساعد الأكاديمي. أنا هنا لمساعدتك في المناهج الدراسية، وسيتم تفعيلي بالكامل قريباً لتقديم إجابات ذكية.";
    _messages.add(ChatMessage(text: botResponse, isUser: false));

    // emit تخبر الشاشة أن الحالة تغيرت، فيجب إعادة رسم الجزء المعتمد على البيانات
    emit(ChatUpdated(List.from(_messages)));
  }
}
