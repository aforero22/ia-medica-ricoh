#!/usr/bin/env python3
"""
RICOH España - Servidor Local de GPT-OSS
Ejecuta el modelo GPT-OSS oficial de OpenAI localmente
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import logging
import os
import time
from typing import Optional, Dict, Any
import json

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="RICOH España - Servidor Local de GPT-OSS",
    description="API local para ejecutar GPT-OSS de OpenAI",
    version="1.0.0"
)

# Modelo global
model = None
model_path = None

class ModelRequest(BaseModel):
    prompt: str
    max_tokens: Optional[int] = 1000
    temperature: Optional[float] = 0.1
    reasoning_level: Optional[str] = "medium"  # low, medium, high

class ModelResponse(BaseModel):
    response: str
    model_used: str
    reasoning_level: str
    processing_time: float

def load_gpt_oss_model():
    """Cargar modelo GPT-OSS"""
    global model, model_path
    
    try:
        # Intentar importar gpt-oss
        from gpt_oss import GPTOSS
        logger.info("✅ Librería GPT-OSS encontrada")
    except ImportError:
        logger.error("❌ Librería GPT-OSS no encontrada")
        logger.info("💡 Instala con: pip install gpt-oss")
        return False
    
    # Buscar modelo GPT-OSS en directorios
    possible_paths = [
        "medical-service-advanced/models/gpt-oss-20b",
        "medical-service-advanced/models/gpt-oss-120b",
        "models/gpt-oss-20b",
        "models/gpt-oss-120b"
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            model_path = path
            break
    
    if not model_path:
        logger.error("❌ Modelo GPT-OSS no encontrado")
        logger.info("💡 Descarga con: .\download-gpt-oss-real.ps1")
        return False
    
    try:
        logger.info(f"🔄 Cargando GPT-OSS desde: {model_path}")
        
        # Cargar modelo GPT-OSS
        model = GPTOSS.from_pretrained(model_path)
        logger.info("✅ Modelo GPT-OSS cargado exitosamente")
        return True
        
    except Exception as e:
        logger.error(f"❌ Error cargando GPT-OSS: {str(e)}")
        return False

@app.on_event("startup")
async def startup_event():
    """Inicializar modelo al startup"""
    if not load_gpt_oss_model():
        logger.error("No se pudo cargar GPT-OSS")
    else:
        logger.info("🚀 Servidor GPT-OSS iniciado")

@app.get("/health")
async def health_check():
    """Check de salud del servidor GPT-OSS"""
    return {
        "status": "healthy" if model else "error",
        "model_loaded": model is not None,
        "model_path": model_path,
        "model_type": "gpt-oss",
        "timestamp": time.time()
    }

@app.post("/generate", response_model=ModelResponse)
async def generate_response(request: ModelRequest):
    """Generar respuesta usando GPT-OSS"""
    if not model:
        raise HTTPException(
            status_code=503, 
            detail="Modelo GPT-OSS no está cargado"
        )
    
    start_time = time.time()
    
    try:
        # Configurar mensajes para GPT-OSS
        messages = [
            {
                "role": "system", 
                "content": f"Reasoning: {request.reasoning_level}. Eres un codificador médico experto en CIE-10-ES."
            },
            {
                "role": "user", 
                "content": request.prompt
            }
        ]
        
        # Generar respuesta con GPT-OSS
        response = model.chat(
            messages=messages,
            max_tokens=request.max_tokens,
            temperature=request.temperature
        )
        
        # Extraer respuesta
        if hasattr(response, 'choices') and len(response.choices) > 0:
            generated_text = response.choices[0].message.content
        elif hasattr(response, 'content'):
            generated_text = response.content
        else:
            generated_text = str(response)
        
        processing_time = time.time() - start_time
        
        return ModelResponse(
            response=generated_text.strip(),
            model_used="gpt-oss",
            reasoning_level=request.reasoning_level,
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
    """Información del modelo GPT-OSS"""
    return {
        "model_loaded": model is not None,
        "model_path": model_path,
        "model_type": "gpt-oss",
        "reasoning_levels": ["low", "medium", "high"],
        "features": [
            "Apache 2.0 License",
            "Configurable Reasoning",
            "Full Chain-of-Thought",
            "Fine-tunable",
            "Agentic Capabilities"
        ]
    }

@app.get("/chat")
async def chat_endpoint():
    """Endpoint de chat para GPT-OSS"""
    return {
        "message": "GPT-OSS Chat endpoint",
        "usage": "POST /generate con prompt y parámetros"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
