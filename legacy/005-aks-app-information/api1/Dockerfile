FROM python:3.14-slim

ARG API2_ENVIRONMENT=dev

ENV API2_ENVIRONMENT=$API2_ENVIRONMENT

WORKDIR /app

RUN pip install uv

COPY pyproject.toml uv.lock ./

RUN uv pip install --system .

COPY . .

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
