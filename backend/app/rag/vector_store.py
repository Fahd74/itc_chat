"""Vector store — ChromaDB operations for document storage and retrieval."""

import os
from langchain_chroma import Chroma
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from app.config import settings
from app.rag.document_loader import load_all_documents, split_documents, load_single_document


# Singleton embedding model
_embeddings = None
_vector_store = None


def get_embeddings():
    """Get or create the Google Generative AI embeddings model."""
    global _embeddings
    if _embeddings is None:
        _embeddings = GoogleGenerativeAIEmbeddings(
            model="models/gemini-embedding-001",
            google_api_key=settings.GEMINI_API_KEY,
        )
    return _embeddings


def get_vector_store() -> Chroma:
    """Get or create the ChromaDB vector store."""
    global _vector_store
    if _vector_store is None:
        os.makedirs(settings.CHROMA_DIR, exist_ok=True)
        _vector_store = Chroma(
            persist_directory=settings.CHROMA_DIR,
            embedding_function=get_embeddings(),
            collection_name="itc_knowledge_base",
        )
    return _vector_store


def initialize_vector_store():
    """
    Load all documents from the data/documents directory,
    split them into chunks, and add them to ChromaDB.
    
    Called once at server startup.
    """
    store = get_vector_store()
    existing_count = store._collection.count()

    if existing_count > 0:
        print(f"📚 Vector store already has {existing_count} documents. Skipping re-indexing.")
        print("   (Delete chroma_db/ folder to force re-indexing)")
        return store

    print("📚 Loading documents for RAG knowledge base...")
    documents = load_all_documents()

    if not documents:
        print("⚠️  No documents found in data/documents/. RAG will work without context.")
        return store

    chunks = split_documents(documents)

    import time
    if chunks:
        batch_size = 50
        total_batches = (len(chunks) - 1) // batch_size + 1
        print(f"   ⏳ Starting indexing in {total_batches} batches to respect API limits...")
        
        for i in range(0, len(chunks), batch_size):
            batch = chunks[i:i+batch_size]
            print(f"   ➡️ Indexing batch {i//batch_size + 1}/{total_batches} ({len(batch)} chunks)...")
            try:
                store.add_documents(batch)
            except Exception as e:
                print(f"   ⚠️ Error indexing batch: {e}. Retrying in 60s...")
                time.sleep(60)
                store.add_documents(batch) # Retry once
                
            # If not the last batch, sleep to avoid rate limiting
            if i + batch_size < len(chunks):
                print("   💤 Waiting 20 seconds to prevent rate limits...")
                time.sleep(20)

        print(f"✅ Successfully indexed {len(chunks)} chunks into ChromaDB")

    return store


def add_document_to_store(file_path: str):
    """Add a single document to the vector store (used for uploads)."""
    store = get_vector_store()
    documents = load_single_document(file_path)
    chunks = split_documents(documents)

    if chunks:
        store.add_documents(chunks)
        print(f"✅ Added {len(chunks)} chunks from {os.path.basename(file_path)}")

    return len(chunks)


def search_similar(query: str, top_k: int = None) -> list:
    """
    Search the vector store for documents similar to the query.
    Returns a list of (document, score) tuples.
    """
    top_k = top_k or settings.TOP_K_RESULTS
    store = get_vector_store()

    if store._collection.count() == 0:
        return []

    results = store.similarity_search_with_relevance_scores(query, k=top_k)
    return results
