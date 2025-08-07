FROM python:3.9-slim

WORKDIR /app

# Instalar dependencias del sistema para modelos de IA
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias Python
COPY requirements.txt .
RUN pip install --no-cache-dir \
    fastapi==0.104.1 \
    uvicorn==0.24.0 \
    pydantic==2.5.0 \
    openai>=1.50.0 \
    python-dotenv==1.0.0 \
    requests==2.32.4 \
    llama-cpp-python==0.2.11 \
    vllm==0.2.5 \
    transformers==4.36.0 \
    torch==2.1.0 \
    accelerate==0.24.0

# Crear directorio para modelos locales
RUN mkdir -p /app/models

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