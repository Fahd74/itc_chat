"""Pydantic models for chat API request/response validation."""

from pydantic import BaseModel
from typing import Optional


class ChatRequest(BaseModel):
    """Request body for POST /api/chat (JSON mode, no files)."""
    message: str


class ChatResponse(BaseModel):
    """Response body for POST /api/chat."""
    reply: str


class DocumentInfo(BaseModel):
    """Info about a document in the knowledge base."""
    filename: str
    size_bytes: int
    mime_type: str


class HistoryMessage(BaseModel):
    """A single message from chat history."""
    id: Optional[str] = None
    user_id: Optional[str] = None
    message: str
    role: str
    attachments: Optional[list] = []
    created_at: Optional[str] = None
