"""Chat history storage using Supabase."""

import json
from datetime import datetime, timezone
from supabase import create_client, Client
from app.config import settings


_supabase_client: Client = None


def get_supabase_client() -> Client:
    """Get or create Supabase client."""
    global _supabase_client
    if _supabase_client is None:
        if settings.SUPABASE_URL and settings.SUPABASE_ANON_KEY:
            try:
                _supabase_client = create_client(
                    settings.SUPABASE_URL,
                    settings.SUPABASE_ANON_KEY,
                )
            except Exception as e:
                print(f"[WARN] Supabase client init failed: {e}. Chat history disabled.")
                return None
    return _supabase_client


async def save_message(user_id: str, message: str, role: str, attachments: list = None):
    """
    Save a chat message to Supabase.
    
    Args:
        user_id: The user's UUID from Supabase auth
        message: The message text
        role: 'user' or 'assistant'
        attachments: Optional list of attachment metadata dicts
    """
    client = get_supabase_client()
    if client is None:
        return  # Supabase not configured, skip saving

    try:
        data = {
            "user_id": user_id,
            "message": message,
            "role": role,
            "attachments": json.dumps(attachments or []),
            "created_at": datetime.now(timezone.utc).isoformat(),
        }

        client.table("messages").insert(data).execute()
    except Exception as e:
        print(f"⚠️  Failed to save message to Supabase: {e}")


async def get_chat_history(user_id: str, limit: int = 50) -> list:
    """
    Retrieve chat history for a user from Supabase.
    
    Returns a list of message dicts ordered by creation time.
    """
    client = get_supabase_client()
    if client is None:
        return []

    try:
        response = (
            client.table("messages")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=False)
            .limit(limit)
            .execute()
        )
        return response.data
    except Exception as e:
        print(f"⚠️  Failed to fetch chat history: {e}")
        return []


async def get_recent_context(user_id: str, count: int = 6) -> list:
    """
    Get the last N messages for a user to provide conversation context
    to the AI model. Returns list of {"role": ..., "message": ...} dicts.
    """
    client = get_supabase_client()
    if client is None:
        return []

    try:
        response = (
            client.table("messages")
            .select("role, message")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(count)
            .execute()
        )
        # Reverse so oldest comes first
        return list(reversed(response.data))
    except Exception as e:
        print(f"⚠️  Failed to fetch recent context: {e}")
        return []
