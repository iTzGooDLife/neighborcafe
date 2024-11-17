from fastapi import APIRouter, HTTPException
from openai_api.model.chat import conversation
from typing import List
from pydantic import BaseModel

router = APIRouter()

class ChatRequest(BaseModel):
    user: str
    query: str
    chat_history: List[str]

@router.post("/chatbot", response_model=dict)
async def chatbot(request: ChatRequest):

    result = conversation(request.user, request.query, request.chat_history)

    return {"response": result}