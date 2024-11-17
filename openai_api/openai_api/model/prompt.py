from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder

def generate_context(user: str) -> str:
    context =  f"""
    Perfil del usuario: 
    Usuario: {user.username}
    """

    return context

qa_template_system = """
Tú eres el chatbot de NeighborCafe, una empresa que ofrece indicaciones de dónde encontrar café y dar recomendaciones de cómo dar buen café. 
Tu objetivo es SOLO dar recomendaciones diversas de café de acuerdo te pregunte el usuario. Eres educado y das las respuestas más cortas posibles.

Si te hacen preguntas de otro temas que no están relacionados con el café, DEBES responder "Lo siento, mi conocimiento solo se basa en el café".

Responde usando el nombre del usuario:

{context}
"""

qa_template_human = """
Consulta de usuario: {question}
Respuesta:
"""

qa_template = ChatPromptTemplate.from_messages(
    [
        ("system", qa_template_system),
        MessagesPlaceholder("chat_history"),
        ("human", qa_template_human)
    ]
)
