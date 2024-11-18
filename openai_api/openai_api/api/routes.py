from fastapi import APIRouter, HTTPException, Depends
from openai_api.model.chat import conversation
from typing import List
from pydantic import BaseModel
from openai_api.api.token import verify_token

router = APIRouter()

class ChatRequest(BaseModel):
    user: str
    query: str
    chat_history: List[str]

@router.post("/chatbot", response_model=dict)
async def chatbot(request: ChatRequest, token_data: dict = Depends(verify_token)):
    result = conversation(request.user, request.query, request.chat_history)
    
    return {"response": result}