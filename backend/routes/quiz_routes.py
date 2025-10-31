from fastapi import APIRouter
from pydantic import BaseModel

from agents.quiz_agent import quiz_agent

router = APIRouter()

class QuizRequest(BaseModel):
    user_id: str

@router.post("/generate_quiz")
async def generate_quiz_endpoint(request: QuizRequest):
    """
    Endpoint to generate a quiz based on user's notes.
    """
    result = quiz_agent(request.user_id)
    return result
