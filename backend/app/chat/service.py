"""Chat service — orchestrates the RAG pipeline and OpenRouter API calls."""

import os
import google.generativeai as genai
from app.config import settings
from app.rag.vector_store import search_similar


# Configure Gemini
genai.configure(api_key=settings.GEMINI_API_KEY)

# System prompt for the AI assistant
SYSTEM_PROMPT = """أنت مساعد ذكي لطلاب كلية تكنولوجيا المعلومات (ITC).
مهمتك هي مساعدة الطلاب بالإجابة على أسئلتهم المتعلقة بالمواد الدراسية والمحاضرات.

المواد المتاحة في قاعدة البيانات:
- Advanced Cpp (البرمجة المتقدمة بلغة C++)
- Algorithms (الخوارزميات)
- Embedded Systems (الأنظمة المدمجة — Arduino, ADC, sensors, microcontrollers)
- Mobile App (تطبيقات الهاتف — Flutter, Dart)
- Network Programming (برمجة الشبكات — TCP, UDP, Sockets, Java)
- Software Engineering (هندسة البرمجيات — SDLC, UML, Design Patterns)

قواعد مهمة:
1. أجب بلغة الطالب (عربي أو إنجليزي).
2. عند وجود سياق من عدة مواد، ركز على المادة **الأكثر صلة** بالسؤال. انظر لعلامة [مادة: ...] في كل مصدر.
3. إذا وجدت الإجابة في السياق، استخدمها واذكر المصدر (اسم المادة + رقم المحاضرة/الشيت).
4. إذا كان السياق المتوفر من مادة غير متعلقة بالسؤال، تجاهله وأجب من معرفتك العامة مع التنويه.
5. كن دقيقاً ومفيداً واستخدم تنسيق Markdown.
"""


def _build_rag_prompt(user_message: str, context_chunks: list) -> str:
    """
    Build a prompt that includes retrieved context from the knowledge base.
    Uses hierarchical metadata (subject, level, semester) for richer context.
    """
    if not context_chunks:
        return user_message

    context_parts = []
    for doc, score in context_chunks:
        meta = doc.metadata
        # Build a descriptive source label from metadata
        source_parts = []
        if meta.get("subject"):
            source_parts.append(f"مادة: {meta['subject']}")
        if meta.get("level"):
            source_parts.append(meta["level"])
        if meta.get("semester"):
            source_parts.append(meta["semester"])
        if meta.get("doc_type"):
            type_labels = {
                "lecture": "محاضرة",
                "sheet": "شيت",
                "sheet_answer": "إجابة شيت",
                "lab": "لاب",
                "lab_answer": "إجابة لاب",
                "revision": "مراجعة",
                "project": "مشروع",
                "schedule": "جدول",
            }
            source_parts.append(type_labels.get(meta["doc_type"], meta["doc_type"]))

        source_label = " | ".join(source_parts) if source_parts else meta.get("source", "Unknown")
        page = meta.get("page", "?")
        filename = meta.get("filename", meta.get("source", "Unknown"))

        context_parts.append(
            f"📄 **{filename}** [{source_label}] (صفحة {page}):\n{doc.page_content}"
        )

    context_text = "\n\n---\n\n".join(context_parts)

    if not context_text:
        return user_message

    return f"""السؤال: {user_message}

--- السياق من المحاضرات والمراجع ---
{context_text}
--- نهاية السياق ---

أجب على السؤال بناءً على السياق المتوفر أعلاه. إذا وجدت الإجابة في السياق اذكر المصدر (اسم المادة والمحاضرة). إذا لم يكن السياق كافياً، أجب من معرفتك العامة مع التنويه."""


async def generate_response(
    user_message: str,
    file_paths: list = None,
    conversation_history: list = None,
) -> str:
    """
    Generate an AI response using RAG + Gemini.
    
    1. Search ChromaDB for relevant context
    2. Build augmented prompt
    3. Send to Gemini with conversation history
    4. Return the response
    
    Args:
        user_message: The user's question text
        file_paths: Optional list of file paths for multimodal input
        conversation_history: Optional list of previous messages for context
        
    Returns:
        The AI assistant's response text
    """
    # Step 1: Search for relevant context in the knowledge base
    context_chunks = search_similar(user_message)

    # Step 2: Build the augmented prompt
    augmented_prompt = _build_rag_prompt(user_message, context_chunks)

    # Step 3: Build the Gemini content
    model = genai.GenerativeModel(
        model_name=settings.GEMINI_MODEL,
        system_instruction=SYSTEM_PROMPT,
    )

    # Build conversation history for context
    history = []
    if conversation_history:
        for msg in conversation_history:
            role = "user" if msg.get("role") == "user" else "model"
            history.append({"role": role, "parts": [msg["message"]]})

    # Start chat with history
    chat = model.start_chat(history=history)

    # Step 4: Build the message parts
    parts = []

    # Add file contents for multimodal (images, audio, etc.)
    if file_paths:
        for file_path in file_paths:
            if os.path.exists(file_path):
                ext = os.path.splitext(file_path)[1].lower()
                mime_map = {
                    ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
                    ".png": "image/png", ".mp3": "audio/mpeg",
                    ".pdf": "application/pdf", ".mp4": "video/mp4",
                }
                mime_type = mime_map.get(ext, "application/octet-stream")

                with open(file_path, "rb") as f:
                    file_data = f.read()

                parts.append({
                    "mime_type": mime_type,
                    "data": file_data,
                })

    # Add the text prompt
    parts.append(augmented_prompt)

    # Step 5: Send to Gemini and get response
    try:
        response = chat.send_message(parts)
        return response.text
    except Exception as e:
        print(f"❌ Gemini API error: {e}")
        return f"حدث خطأ أثناء الاتصال بالمساعد الذكي: {str(e)}"

