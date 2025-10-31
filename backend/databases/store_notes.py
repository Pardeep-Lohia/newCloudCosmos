import os
from PyPDF2 import PdfReader
from .chromadb_setup import get_chroma_client, get_or_create_collection
from .embeddings import generate_embeddings
from agents.utils import chunk_text

def extract_text_from_pdf(file_path):
    """
    Extract text from a PDF file.
    """
    reader = PdfReader(file_path)
    text = ""
    for page in reader.pages:
        text += page.extract_text()
    return text

def store_notes(user_id, file_path):
    """
    Process uploaded PDF, chunk text, generate embeddings, and store in ChromaDB.
    """
    # Extract text
    text = extract_text_from_pdf(file_path)

    # Chunk text
    chunks = chunk_text(text)

    # Generate embeddings
    embeddings = generate_embeddings(chunks)

    # Store in ChromaDB
    client = get_chroma_client()
    collection = get_or_create_collection(client, f"user_{user_id}")

    # Prepare data for ChromaDB
    ids = [f"chunk_{i}" for i in range(len(chunks))]
    metadatas = [{"chunk_id": i, "user_id": user_id} for i in range(len(chunks))]

    collection.add(
        embeddings=embeddings,
        documents=chunks,
        metadatas=metadatas,
        ids=ids
    )

    # Clean up uploaded file
    os.remove(file_path)

    return {"message": "Notes stored successfully", "chunks_count": len(chunks)}
