from fastapi import FastAPI

app = FastAPI()

@app.get('/')
def read_root():
    return {
        'hello': 'world!!!'
    }

@app.get('/calc/{value}')
def calc(value: int):
    return {
        'value': 1024 ** value
    }
