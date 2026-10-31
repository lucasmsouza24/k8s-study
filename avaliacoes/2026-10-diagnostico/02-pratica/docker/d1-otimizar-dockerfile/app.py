import os

from fastapi import FastAPI

app = FastAPI()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/")
def root():
    return {"app": "d1", "token_configured": bool(os.getenv("API_TOKEN"))}
