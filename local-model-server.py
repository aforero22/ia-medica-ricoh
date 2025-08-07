#!/usr/bin/env python3
"""
RICOH España - Servidor Local de Modelo de IA
Ejecuta el modelo localmente y expone una API REST
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import logging
import os
import time
from typing import Optional, Dict, Any
from llama_cpp import Llama

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="RICOH España - Servidor Local de Modelo de IA",
    description="API local para ejecutar modelos de IA",
    version="1.0.0"
)

# Modelo global
model = None
model_path = None

class ModelRequest(BaseModel):
    prompt: str
    max_tokens: Optional[int] = 1000
    temperature: Optional[float] = 0.1
    top_p: Optional[float] = 0.9

class ModelResponse(BaseModel):
    response: str
    model_used: str
    tokens_generated: Optional[int] = None
    processing_time: float

def load_model():
    """Cargar el modelo local"""
    global model, model_path
    
    # Buscar modelo en el directorio actual
    model_path = "medical-service-advanced/models/llama2-7b-chat.gguf"
    
    if not os.path.exists(model_path):
        logger.error(f"Modelo no encontrado en: {model_path}")
        return False
    
    try:
        logger.info(f"Cargando modelo: {model_path}")
        model = Llama(
            model_path=model_path,
            n_ctx=4096,  # Contexto de 4K tokens
            n_threads=8,  # 8 threads para mejor rendimiento
            n_gpu_layers=0,  # CPU only por defecto
            verbose=False
        )
        logger.info("✅ Modelo cargado exitosamente")
        return True
    except Exception as e:
        logger.error(f"❌ Error cargando modelo: {str(e)}")
        return False

@app.on_event("startup")
async def startup_event():
    """Inicializar modelo al startup"""
    if not load_model():
        logger.error("No se pudo cargar el modelo")
    else:
        logger.info("🚀 Servidor de modelo local iniciado")

@app.get("/health")
async def health_check():
    """Check de salud del servidor de modelo"""
    return {
        "status": "healthy" if model else "error",
        "model_loaded": model is not None,
        "model_path": model_path,
        "timestamp": time.time()
    }

@app.post("/generate", response_model=ModelResponse)
async def generate_response(request: ModelRequest):
    """Generar respuesta usando modelo local"""
    if not model:
        raise HTTPException(
            status_code=503, 
            detail="Modelo no está cargado"
        )
    
    start_time = time.time()
    
    try:
        # Generar respuesta con modelo local
        response = model(
            request.prompt,
            max_tokens=request.max_tokens,
            temperature=request.temperature,
            top_p=request.top_p,
            stop=["```", "\n\n\n"]  # Detener en ciertos tokens
        )
        
        # Extraer texto de la respuesta
        if isinstance(response, dict) and 'choices' in response:
            generated_text = response['choices'][0]['text'].strip()
        elif isinstance(response, str):
            generated_text = response.strip()
        else:
            generated_text = str(response).strip()
        
        processing_time = time.time() - start_time
        
        return ModelResponse(
            response=generated_text,
            model_used="llama2-7b-chat",
            processing_time=processing_time
        )
        
    except Exception as e:
        logger.error(f"Error generando respuesta: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error generando respuesta: {str(e)}"
        )

@app.get("/info")
async def model_info():
    """Información del modelo"""
    return {
        "model_loaded": model is not None,
        "model_path": model_path,
        "model_type": "llama2-7b-chat",
        "context_size": 4096,
        "threads": 8
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
