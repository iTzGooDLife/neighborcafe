from openai_api.model.chat import conversation
from fastapi import FastAPI
import uvicorn
from openai_api.api.routes import router

app = FastAPI()

app.include_router(router)

def main():
    uvicorn.run(app, host="127.0.0.1", port=5555)