from fastapi import FastAPI
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI()

@app.get('/')
def read_root():
    return {
        'hello': 'world!!!',
        'env': os.getenv('API2_ENVIRONMENT', 'unknow')
    }

@app.get('/calc/{value}')
def calc(value: int):
    return {
        'value': 1024 ** value
    }
