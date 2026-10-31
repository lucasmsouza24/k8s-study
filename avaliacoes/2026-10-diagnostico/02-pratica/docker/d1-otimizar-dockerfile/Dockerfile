FROM python:3.12

ENV API_TOKEN=supersecret123

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

RUN chmod +x start.sh

EXPOSE 8000

CMD ./start.sh
