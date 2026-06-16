FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1  \
    NLTK_DATA=/usr/local/share/nltk_data \
    PORT=8080

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends libgomp1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt setup.py ./
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && python -m nltk.downloader -d "${NLTK_DATA}" stopwords wordnet omw-1.4

COPY flask_api ./flask_api
COPY artifacts ./artifacts

EXPOSE 8080

CMD gunicorn --bind 0.0.0.0:${PORT} --workers 1 --threads 4 --timeout 120 flask_api.app:app
