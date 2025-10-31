from sentence_transformers import SentenceTransformer

# Initialize the embedding model
model = SentenceTransformer('all-MiniLM-L6-v2')

def generate_embeddings(texts):
    """
    Generate embeddings for a list of text chunks using sentence-transformers.
    """
    embeddings = model.encode(texts, convert_to_tensor=False)
    return embeddings.tolist()
