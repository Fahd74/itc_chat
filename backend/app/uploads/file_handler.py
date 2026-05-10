"""File upload handler — saves uploaded files and processes them."""

import os
import shutil
from fastapi import UploadFile
from app.config import settings


async def save_uploaded_file(file: UploadFile, destination_dir: str = None) -> str:
    """
    Save an uploaded file to disk and return the saved path.
    
    Args:
        file: The FastAPI UploadFile object
        destination_dir: Where to save. Defaults to uploads_temp/
        
    Returns:
        The absolute path to the saved file.
    """
    destination_dir = destination_dir or settings.UPLOADS_DIR
    os.makedirs(destination_dir, exist_ok=True)

    file_path = os.path.join(destination_dir, file.filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return file_path


async def save_to_knowledge_base(file: UploadFile) -> str:
    """
    Save an uploaded file directly to the knowledge base documents folder.
    This is used by the /api/documents/upload endpoint.
    
    Returns:
        The absolute path to the saved file.
    """
    return await save_uploaded_file(file, settings.DOCUMENTS_DIR)


def cleanup_temp_files(file_paths: list):
    """Remove temporary uploaded files."""
    for path in file_paths:
        try:
            if os.path.exists(path):
                os.remove(path)
        except Exception as e:
            print(f"⚠️  Failed to cleanup {path}: {e}")


def get_file_mime_type(filename: str) -> str:
    """Guess the MIME type from the file extension."""
    ext = os.path.splitext(filename)[1].lower()
    mime_map = {
        ".pdf": "application/pdf",
        ".txt": "text/plain",
        ".md": "text/markdown",
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".png": "image/png",
        ".mp3": "audio/mpeg",
        ".ogg": "audio/ogg",
        ".mp4": "video/mp4",
        ".doc": "application/msword",
        ".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    }
    return mime_map.get(ext, "application/octet-stream")
