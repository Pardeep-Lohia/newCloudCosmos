import google.generativeai as genai
import os

# ✅ Configure Gemini API
genai.configure(api_key="AIzaSyCa6FkvYlzsBPduzIXQ2fG-sHwuPLqxi4k")

# ✅ Initialize Gemini model
model = genai.GenerativeModel("gemini-2.5-flash")

def retrieve_all_chunks(user_id):
    """
    Retrieve all chunks for a user to generate quiz from entire context.
    """
    from databases.chromadb_setup import get_chroma_client, get_or_create_collection
    client = get_chroma_client()
    collection = get_or_create_collection(client, f"user_{user_id}")

    # Get all documents
    results = collection.get()
    return results['documents'] if results['documents'] else []


def generate_quiz(context):
    """
    Use Gemini to generate 2 multiple-choice questions (MCQs) based on context.
    """
    prompt = f"""
    Based on the following context, generate exactly 2 multiple-choice questions (MCQs).
    Each question must have exactly 4 options labeled A, B, C, D.
    Only one option should be correct for each question.
    Do not generate subjective or open-ended questions. Ensure questions are factual and based directly on the context.

    Context:
    {context}

    Output format strictly:
    Question 1: [Question text here]
    A) [Option 1]
    B) [Option 2]
    C) [Option 3]
    D) [Option 4]
    Correct: [Single letter A/B/C/D]

    Question 2: [Question text here]
    A) [Option 1]
    B) [Option 2]
    C) [Option 3]
    D) [Option 4]
    Correct: [Single letter A/B/C/D]
    """

    try:
        # ✅ Generate content with Gemini
        response = model.generate_content(prompt)
        return response.text.strip()

    except Exception as e:
        # Handle possible API or network errors gracefully
        return f"Error generating quiz: {str(e)}"


def quiz_agent(user_id):
    """
    Main quiz generation function.
    """
    context_chunks = retrieve_all_chunks(user_id)
    context = " ".join(context_chunks)

    if not context:
        return {"quiz": "No notes found to generate quiz."}

    quiz = generate_quiz(context)
    return {"quiz": quiz}

# def func():
#     for m in genai.list_models():
#        print(m.name, m.supported_generation_methods)

# func()