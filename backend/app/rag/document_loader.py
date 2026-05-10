"""Document loader — reads PDF and text files, splits them into chunks."""

import os
from langchain_community.document_loaders import PyPDFLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from app.config import settings


def load_single_document(file_path: str):
    """Load a single document (PDF or text) and return LangChain Document objects."""
    ext = os.path.splitext(file_path)[1].lower()

    if ext == ".pdf":
        loader = PyPDFLoader(file_path)
    elif ext in (".txt", ".md"):
        loader = TextLoader(file_path, encoding="utf-8")
    else:
        raise ValueError(f"Unsupported file type: {ext}")

    return loader.load()


def load_all_documents(directory: str = None):
    """
    Load all supported documents from the given directory.
    Returns a list of LangChain Document objects.
    """
    directory = directory or settings.DOCUMENTS_DIR
    all_docs = []

    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok=True)
        return all_docs

    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        if not os.path.isfile(file_path):
            continue
        try:
            docs = load_single_document(file_path)
            all_docs.extend(docs)
            print(f"  ✅ Loaded: {filename} ({len(docs)} pages/chunks)")
        except ValueError:
            print(f"  ⏭️  Skipped (unsupported): {filename}")
        except Exception as e:
            print(f"  ❌ Error loading {filename}: {e}")

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
