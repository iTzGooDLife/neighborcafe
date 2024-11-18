import firebase_admin
from firebase_admin import credentials

def init_credentials():
    cred = credentials.Certificate("neighbor-cafe-firebase-adminsdk.json")
    firebase_admin.initialize_app(cred)