"""Vector store — ChromaDB operations for document storage and retrieval."""

import os
from collections import defaultdict
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings
from app.config import settings
from app.rag.document_loader import load_all_documents, split_documents, load_single_document


# Singleton embedding model
_embeddings = None
_vector_store = None


def get_embeddings():
    """Get or create the HuggingFace local embeddings model."""
    global _embeddings
    if _embeddings is None:
        # Using a fast, local embedding model that runs entirely offline
        # with no rate limits.
        _embeddings = HuggingFaceEmbeddings(
            model_name="sentence-transformers/all-MiniLM-L6-v2"
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

    if chunks:
        # Local embeddings have no API limits, so we can index everything in one go,
        # but batching is still good practice for memory.
        batch_size = 100
        total_batches = (len(chunks) - 1) // batch_size + 1
        print(f"   ⏳ Starting local indexing in {total_batches} batches...")
        
        for i in range(0, len(chunks), batch_size):
            batch = chunks[i:i+batch_size]
            print(f"   ➡️ Indexing batch {i//batch_size + 1}/{total_batches} ({len(batch)} chunks)...")
            try:
                store.add_documents(batch)
            except Exception as e:
                print(f"   ⚠️ Error indexing batch: {e}")

        print(f"✅ Successfully indexed {len(chunks)} chunks into ChromaDB")

    return store


def add_document_to_store(file_path: str):
    """Add a single document to the vector store (used for uploads)."""
    store = get_vector_store()
    documents = load_single_document(file_path, base_dir=settings.DOCUMENTS_DIR)
    chunks = split_documents(documents)

    if chunks:
        store.add_documents(chunks)
        print(f"✅ Added {len(chunks)} chunks from {os.path.basename(file_path)}")

    return len(chunks)


# ── Minimum relevance score: chunks below this are discarded ──
MIN_RELEVANCE_SCORE = 0.25

# ── Maximum results per subject to ensure diversity ──
MAX_PER_SUBJECT = 5


def search_similar(query: str, top_k: int = None) -> list:
    """
    Search the vector store for documents similar to the query.
    
    Applies two post-processing steps:
      1. **Relevance filter** — discards chunks with score < MIN_RELEVANCE_SCORE
      2. **Subject diversity** — caps results per subject so one subject
         can't dominate the entire context window.
    
    Returns a list of (document, score) tuples.
    """
    top_k = top_k or settings.TOP_K_RESULTS
    store = get_vector_store()

    if store._collection.count() == 0:
        return []

    # Fetch more candidates than needed, then filter/diversify
    fetch_k = top_k * 4  # e.g. if top_k=8, fetch 32 candidates
    raw_results = store.similarity_search_with_relevance_scores(query, k=fetch_k)

    # Step 1: Filter by minimum relevance score
    filtered = [
        (doc, score) for doc, score in raw_results
        if score >= MIN_RELEVANCE_SCORE
    ]

    if not filtered:
        # If nothing passes the threshold, return the best 2 results anyway
        # so the AI at least has something to work with
        return raw_results[:2] if raw_results else []

    # Step 2: Diversify across subjects — round-robin pick from each subject
    subject_buckets = defaultdict(list)
    for doc, score in filtered:
        subject = doc.metadata.get("subject", doc.metadata.get("category", "_general"))
        subject_buckets[subject].append((doc, score))

    # Round-robin: pick from each subject in order of best score
    diverse_results = []
    round_idx = 0
    while len(diverse_results) < top_k:
        added_this_round = False
        for subject in sorted(subject_buckets.keys()):
            bucket = subject_buckets[subject]
            if round_idx < len(bucket) and round_idx < MAX_PER_SUBJECT:
                diverse_results.append(bucket[round_idx])
                added_this_round = True
                if len(diverse_results) >= top_k:
                    break
        if not added_this_round:
            break
        round_idx += 1

    # Sort final results by score (highest first)
    diverse_results.sort(key=lambda x: x[1], reverse=True)

    return diverse_results
