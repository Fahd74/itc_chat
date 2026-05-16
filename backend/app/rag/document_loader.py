"""Document loader — reads PDF and text files recursively, splits them into chunks.

Directory structure convention:
  documents/                          → General institution/university info
  documents/Level X/                  → Year-level info
  documents/Level X/Semester Y/       → Semester-level info (e.g. schedules)
  documents/Level X/Semester Y/Subject/ → Course materials (lectures, sheets, labs)

Metadata is automatically extracted from the folder hierarchy.
"""

import os
from langchain_community.document_loaders import PyPDFLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from app.config import settings


def _extract_metadata_from_path(file_path: str, base_dir: str) -> dict:
    """
    Extract structured metadata from a file's path relative to the documents root.

    Examples:
      documents/README.txt                         → category=general
      documents/Level 3/Semester 2/schedule.pdf     → level=Level 3, semester=Semester 2, category=semester_info
      documents/Level 3/Semester 2/Algorithms/Lec-1-Alg.pdf
                                                    → level=Level 3, semester=Semester 2, subject=Algorithms,
                                                      category=course_material, doc_type=lecture
    """
    rel_path = os.path.relpath(file_path, base_dir)
    parts = rel_path.replace("\\", "/").split("/")  # normalize separators
    filename = parts[-1]
    folder_parts = parts[:-1]  # everything except the filename

    meta = {
        "source": rel_path,
        "filename": filename,
    }

    # Determine depth: 0 = root, 1 = Level, 2 = Semester, 3+ = Subject
    if len(folder_parts) == 0:
        # File sits directly in documents/ → general info
        meta["category"] = "general"

    elif len(folder_parts) == 1:
        # documents/Level X/file → level-wide info
        meta["level"] = folder_parts[0]
        meta["category"] = "level_info"

    elif len(folder_parts) == 2:
        # documents/Level X/Semester Y/file → semester info (e.g. schedule)
        meta["level"] = folder_parts[0]
        meta["semester"] = folder_parts[1]
        meta["category"] = "semester_info"

    elif len(folder_parts) >= 3:
        # documents/Level X/Semester Y/Subject/file → course material
        meta["level"] = folder_parts[0]
        meta["semester"] = folder_parts[1]
        meta["subject"] = folder_parts[2]
        meta["category"] = "course_material"

    # Try to detect document type from filename patterns
    fname_lower = filename.lower()
    if "lec" in fname_lower or "lecture" in fname_lower:
        meta["doc_type"] = "lecture"
    elif "sheet" in fname_lower:
        meta["doc_type"] = "sheet"
        if "answer" in fname_lower:
            meta["doc_type"] = "sheet_answer"
    elif "lab" in fname_lower:
        meta["doc_type"] = "lab"
        if "answer" in fname_lower:
            meta["doc_type"] = "lab_answer"
    elif "revision" in fname_lower or "review" in fname_lower or "mid" in fname_lower:
        meta["doc_type"] = "revision"
    elif "req" in fname_lower or "project" in fname_lower:
        meta["doc_type"] = "project"
    elif "جدول" in fname_lower or "schedule" in fname_lower:
        meta["doc_type"] = "schedule"

    return meta


def load_single_document(file_path: str, base_dir: str = None):
    """Load a single document (PDF or text) and return LangChain Document objects.
    
    Injects hierarchical metadata into each document based on its path.
    """
    ext = os.path.splitext(file_path)[1].lower()

    if ext == ".pdf":
        loader = PyPDFLoader(file_path)
    elif ext in (".txt", ".md"):
        loader = TextLoader(file_path, encoding="utf-8")
    else:
        raise ValueError(f"Unsupported file type: {ext}")

    docs = loader.load()

    # Inject hierarchical metadata
    if base_dir:
        extra_meta = _extract_metadata_from_path(file_path, base_dir)
        for doc in docs:
            doc.metadata.update(extra_meta)

    return docs


def load_all_documents(directory: str = None):
    """
    Recursively load all supported documents from the given directory tree.
    Returns a list of LangChain Document objects with hierarchical metadata.
    """
    directory = directory or settings.DOCUMENTS_DIR
    all_docs = []

    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok=True)
        return all_docs

    supported_extensions = {".pdf", ".txt", ".md"}

    for root, dirs, files in os.walk(directory):
        # Sort for deterministic loading order
        dirs.sort()
        files.sort()

        for filename in files:
            ext = os.path.splitext(filename)[1].lower()
            if ext not in supported_extensions:
                print(f"  ⏭️  Skipped (unsupported): {filename}")
                continue

            file_path = os.path.join(root, filename)
            rel_path = os.path.relpath(file_path, directory)

            try:
                docs = load_single_document(file_path, base_dir=directory)
                all_docs.extend(docs)
                print(f"  ✅ Loaded: {rel_path} ({len(docs)} pages/chunks)")
            except Exception as e:
                print(f"  ❌ Error loading {rel_path}: {e}")

    print(f"\n  📊 Total documents loaded: {len(all_docs)} from {directory}")
    return all_docs


def split_documents(documents, chunk_size=None, chunk_overlap=None):
    """Split documents into smaller chunks for embedding."""
    chunk_size = chunk_size or settings.CHUNK_SIZE
    chunk_overlap = chunk_overlap or settings.CHUNK_OVERLAP

    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        length_function=len,
        separators=["\n\n", "\n", ". ", " ", ""],
    )

    chunks = splitter.split_documents(documents)
    print(f"  📄 Split into {len(chunks)} chunks")
    return chunks
