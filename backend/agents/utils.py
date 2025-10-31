def chunk_text(text, chunk_size=500, overlap=50):
    """
    Split text into chunks with overlap for better retrieval.
    """
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunk = text[start:end]
        chunks.append(chunk)
        start = end - overlap
        if start >= len(text):
            break
    return chunks
