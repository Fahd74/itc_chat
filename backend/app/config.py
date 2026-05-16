import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    """Application configuration loaded from environment variables."""

    # Gemini
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    GEMINI_MODEL: str = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")

    # Supabase
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_ANON_KEY: str = os.getenv("SUPABASE_ANON_KEY", "")
    SUPABASE_JWT_SECRET: str = os.getenv("SUPABASE_JWT_SECRET", "")

    # Server
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))

    # Paths
    DOCUMENTS_DIR: str = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "documents")
    CHROMA_DIR: str = os.path.join(os.path.dirname(os.path.dirname(__file__)), "chroma_db")
    UPLOADS_DIR: str = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads_temp")

    # RAG
    CHUNK_SIZE: int = 1000
    CHUNK_OVERLAP: int = 200
    TOP_K_RESULTS: int = 20


settings = Settings()
