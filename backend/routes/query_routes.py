from fastapi import APIRouter
from pydantic import BaseModel

from agents.qa_agent import qa_agent

router = APIRouter()

class QueryRequest(BaseModel):
    user_id: str
    query: str

@router.post("/ask")
async def ask_question(request: QueryRequest):
    """
    Endpoint to ask a question and get an answer based on user's notes.
    """
    result = qa_agent(request.user_id, request.query)
    return result
