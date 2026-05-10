"""
ITC Chat Backend — FastAPI RAG Server
======================================
A backend server that provides:
  - RAG-powered chat using Gemini + ChromaDB
  - Document upload and indexing
  - Chat history storage via Supabase
  - Supabase JWT authentication

Run with: python main.py
Or:       uvicorn main:app --reload --port 8000
"""

import sys
import io

# Force UTF-8 output on Windows to support emojis and Arabic text
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace', line_buffering=True)
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace', line_buffering=True)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.config import settings
from app.chat.router import router as chat_router
from app.rag.vector_store import initialize_vector_store


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    # ── Startup ──
    print("[*] Starting ITC Chat Backend...")
    print(f"    Gemini Model: {settings.GEMINI_MODEL}")
    print(f"    Documents Dir: {settings.DOCUMENTS_DIR}")
    print(f"    ChromaDB Dir: {settings.CHROMA_DIR}")
    print()

    # Initialize the RAG vector store
    initialize_vector_store()
    print()
    print("[OK] Server ready!")
    print(f"    API Docs: http://localhost:{settings.PORT}/docs")
    print()

    yield

    # -- Shutdown --
    print("[*] Shutting down...")


# ── Create FastAPI app ──
app = FastAPI(
    title="ITC Chat Backend",
    description="RAG-powered AI assistant for ITC students",
    version="1.0.0",
    lifespan=lifespan,
)

# ── CORS ──
# Allow Flutter app to connect from any origin (for development)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Register routes ──
app.include_router(chat_router)


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "ok", "service": "itc-chat-backend"}


# ── Entry point ──
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=True,
    )
