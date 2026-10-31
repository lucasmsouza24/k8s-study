#!/bin/sh
echo "[start] iniciando api na porta 8000"
uvicorn app:app --host 0.0.0.0 --port 8000
echo "[start] api finalizada"
