FROM python:3.9-slim

WORKDIR /app

# Instalar solo las dependencias necesarias para GPT-4
COPY requirements.txt .
RUN pip install --no-cache-dir \
    fastapi==0.104.1 \
    uvicorn==0.24.0 \
    pydantic==2.5.0 \
    openai>=1.50.0 \
    python-dotenv==1.0.0 \
    requests==2.32.4

# Copiar el código de la aplicación
COPY . .

# Variable de entorno para la API key
ENV OPENAI_API_KEY=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

# Exponer puerto
EXPOSE 8000

# Comando para ejecutar la aplicación
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]