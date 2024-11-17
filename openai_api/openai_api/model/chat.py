import os
from dotenv import load_dotenv 
from langchain_openai import ChatOpenAI
from openai_api.model.prompt import generate_context, qa_template
from langchain.schema.output_parser import StrOutputParser
from langchain_core.messages import HumanMessage, SystemMessage

load_dotenv() 
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

def conversation(username, question, chat_history):

    model = ChatOpenAI(model="gpt-4o")
    context = generate_context(username)

    chain = qa_template | model | StrOutputParser()
    result = chain.invoke({"context": context, "chat_history": chat_history ,"question": question})

    return result
    