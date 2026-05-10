"""Chat API router — defines all chat-related endpoints."""

import os
from typing import Optional
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, Request

from app.auth.supabase_auth import get_current_user
from app.chat.models import ChatRequest, ChatResponse, DocumentInfo, HistoryMessage
from app.chat.service import generate_response
from app.history.chat_history import save_message, get_chat_history, get_recent_context
from app.uploads.file_handler import (
    save_uploaded_file,
    save_to_knowledge_base,
    cleanup_temp_files,
    get_file_mime_type,
)
from app.rag.vector_store import add_document_to_store
from app.config import settings


router = APIRouter()


# ──────────────────────────────────────────────
#  POST /api/chat — Main chat endpoint
# ──────────────────────────────────────────────

@router.post("/api/chat", response_model=ChatResponse)
async def chat(
    request: Request,
    user: dict = Depends(get_current_user),
):
    """
    Main chat endpoint. Auto-detects content type:
    - JSON body with {"message": "..."} 
    - Multipart form with message + files
    
    This matches the contract expected by Flutter's BackendDataSource.
    """
    content_type = request.headers.get("content-type", "")
    message = ""
    temp_file_paths = []
    attachment_metadata = []

    if "application/json" in content_type:
        # --- JSON mode (no files) ---
        body = await request.json()
        message = body.get("message", "")
    elif "multipart/form-data" in content_type:
        # --- Multipart mode (with files) ---
        form = await request.form()
        message = form.get("message", "")
        
        files = form.getlist("files")
        for file in files:
            if hasattr(file, 'filename') and file.filename:
                path = await save_uploaded_file(file)
                temp_file_paths.append(path)
                attachment_metadata.append({
                    "name": file.filename,
                    "mime_type": get_file_mime_type(file.filename),
                })
    else:
        # Try JSON as fallback
        try:
            body = await request.json()
            message = body.get("message", "")
        except Exception:
            raise HTTPException(status_code=400, detail="Unsupported content type")

    if not message and not temp_file_paths:
        raise HTTPException(status_code=400, detail="Message or files required")

    user_id = user.get("sub", "anonymous")

    # Save user message to history
    await save_message(user_id, message, "user", attachment_metadata)

    # Get recent conversation context
    recent_history = await get_recent_context(user_id)

    # Generate AI response using RAG + Gemini
    reply = await generate_response(
        user_message=message,
        file_paths=temp_file_paths,
        conversation_history=recent_history,
    )

    # Save assistant response to history
    await save_message(user_id, reply, "assistant")

    # Cleanup temp files
    cleanup_temp_files(temp_file_paths)

    return ChatResponse(reply=reply)


# ──────────────────────────────────────────────
#  Document management endpoints
# ──────────────────────────────────────────────

@router.post("/api/documents/upload")
async def upload_document(
    file: UploadFile = File(...),
    user: dict = Depends(get_current_user),
):
    """
    Upload a document (PDF, TXT) to the RAG knowledge base.
    The document is saved and indexed into ChromaDB.
    """
    allowed_extensions = {".pdf", ".txt", ".md"}
    ext = os.path.splitext(file.filename)[1].lower()

    if ext not in allowed_extensions:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported file type: {ext}. Allowed: {', '.join(allowed_extensions)}",
        )

    # Save to knowledge base directory
    file_path = await save_to_knowledge_base(file)

    # Index into ChromaDB
    try:
        chunks_count = add_document_to_store(file_path)
        return {
            "message": f"Document '{file.filename}' uploaded and indexed successfully",
            "chunks_indexed": chunks_count,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to index document: {str(e)}")


@router.get("/api/documents")
async def list_documents(user: dict = Depends(get_current_user)):
    """List all documents in the knowledge base."""
    docs_dir = settings.DOCUMENTS_DIR
    if not os.path.exists(docs_dir):
        return {"documents": []}

    documents = []
    for filename in os.listdir(docs_dir):
        file_path = os.path.join(docs_dir, filename)
        if os.path.isfile(file_path):
            documents.append(
                DocumentInfo(
                    filename=filename,
                    size_bytes=os.path.getsize(file_path),
                    mime_type=get_file_mime_type(filename),
                )
            )

    return {"documents": documents}


# ──────────────────────────────────────────────
#  Chat history endpoint
# ──────────────────────────────────────────────

@router.get("/api/history")
async def get_history(user: dict = Depends(get_current_user)):
    """Get chat history for the authenticated user."""
    user_id = user.get("sub", "anonymous")
    messages = await get_chat_history(user_id)
    return {"messages": messages}
