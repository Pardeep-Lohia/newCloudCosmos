import google.generativeai as genai
import os
from databases.chromadb_setup import get_chroma_client, get_or_create_collection
from databases.embeddings import generate_embeddings

# ✅ Configure Gemini API
genai.configure(api_key=os.getenv("AIzaSyCa6FkvYlzsBPduzIXQ2fG-sHwuPLqxi4k"))

# ✅ Initialize Gemini model
model = genai.GenerativeModel("gemini-2.5-flash")

def retrieve_relevant_chunks(user_id, query, top_k=5):
    """
    Retrieve top-k relevant chunks for a user query using ChromaDB.
    """
    client_chroma = get_chroma_client()
    collection = get_or_create_collection(client_chroma, f"user_{user_id}")

    # Generate embedding for the query
    query_embedding = generate_embeddings([query])[0]

    # Query the collection
    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=top_k
    )

    return results['documents'][0] if results['documents'] else []


def generate_answer(query, context):
    """
    Use Gemini to generate an answer based on the retrieved context.
    """
    prompt = f"""
    You are a helpful AI assistant. Use the following context to answer the question.

    Question: {query}

    Context:
    {context}

    Answer:
    """

    try:
        # ✅ Generate answer using Gemini
        response = model.generate_content(prompt)
        return response.text.strip()

    except Exception as e:
        # Handle possible API or network errors gracefully
        return f"Error generating answer: {str(e)}"


def qa_agent(user_id, query):
    """
    Main QA function: retrieve context and generate answer.
    """
    context_chunks = retrieve_relevant_chunks(user_id, query)
    context = " ".join(context_chunks)

    if not context:
        return {"answer": "No relevant information found in your notes."}

    answer = generate_answer(query, context)
    return {"answer": answer, "context": context}
