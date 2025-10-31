import chromadb

def get_chroma_client():
    """
    Initialize and return a ChromaDB client.
    Uses persistent storage for data persistence across sessions.
    """
    client = chromadb.PersistentClient(path="./chroma_db")
    return client

def get_or_create_collection(client, collection_name):
    """
    Get or create a collection in ChromaDB.
    Each user will have their own collection based on user_id.
    """
    collection = client.get_or_create_collection(name=collection_name)
    return collection
