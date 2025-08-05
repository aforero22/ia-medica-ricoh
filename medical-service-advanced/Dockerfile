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

# Copiar config.env como .env ANTES de copiar todo lo demás
COPY config.env .env

# Copiar el código de la aplicación
COPY . .
# Variable de entorno para la API key (se cargará desde config.env)
# ENV OPENAI_API_KEY=your-openai-api-key-here

# Exponer puerto
EXPOSE 8000

# Comando para ejecutar la aplicación
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]