from fastapi import FastAPI
from pydantic_settings import BaseSettings
from dotenv import load_dotenv
import os
load_dotenv()

class Settings(BaseSettings):
    app_name: str = 'Awesome API'
    admin_email: str = 'admin@email.com'
    stage: str = os.getenv('STAGE', 'unknow')

settings = Settings()
app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get('/info')
def info():
    return {
        'stage': settings.stage,
        'app_name': settings.app_name,
        'admin_email': settings.admin_email,
    }
