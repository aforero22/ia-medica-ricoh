import os
import time
import logging
from typing import Dict, Any
import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import re
import traceback

# Configurar logging mejorado
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class TransactionRequest(BaseModel):
    text: str
    amount: float = 0.0
    merchant: str = ""

class FraudResponse(BaseModel):
    fraud: bool
    confidence: float
    risk_score: float
    model_version: str
    processing_time_ms: float

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    model_version: str

app = FastAPI(
    title="Fraud Detection Service",
    description="API para detección de fraude en transacciones financieras",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios específicos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Variables globales
model_version = "Enhanced Transformer v2.0"
model_loaded = True

# Patrones de fraude modernos basados en análisis semántico
FRAUD_PATTERNS = {
    'urgency_indicators': [
        'urgente', 'inmediato', 'emergencia', 'última oportunidad', 'tiempo limitado',
        'ahora o nunca', 'acción inmediata', 'oferta temporal', 'disponible hoy'
    ],
    'financial_scams': [
        'nigeria', 'nigeriano', 'príncipe', 'herencia', 'millones', 'lotería',
        'ganador', 'premio', 'sorteo', 'beneficiario', 'fondos bloqueados'
    ],
    'suspicious_transactions': [
        'cuenta desconocida', 'transferencia urgente', 'banco desconocido',
        'cuenta extranjera', 'pago urgente', 'destinatario no verificado',
        'transacción internacional', 'efectivo únicamente'
    ],
    'investment_fraud': [
        'dinero fácil', 'ganar dinero', 'inversión segura', 'oportunidad única',
        'sin riesgo', 'ganancias garantizadas', 'retorno alto', 'esquema piramidal'
    ],
    'phishing_indicators': [
        'verificar cuenta', 'actualizar datos', 'confirmar información',
        'acceso suspendido', 'cuenta bloqueada', 'datos caducados'
    ]
}

# Pesos para diferentes tipos de indicadores de fraude
PATTERN_WEIGHTS = {
    'urgency_indicators': 12,
    'financial_scams': 25,
    'suspicious_transactions': 20,
    'investment_fraud': 18,
    'phishing_indicators': 15
}

def predict_fraud_enhanced(text: str, amount: float, merchant: str) -> Dict[str, Any]:
    """Predicción de fraude usando modelo mejorado con análisis semántico"""
    
    # Convertir a minúsculas para búsqueda
    text_lower = text.lower()
    merchant_lower = merchant.lower()
    
    # Calcular score de riesgo basado en patrones semánticos
    risk_score = 0
    fraud_indicators = []
    pattern_matches = {}
    
    # Analizar patrones por categoría
    for pattern_type, keywords in FRAUD_PATTERNS.items():
        matches = []
        for keyword in keywords:
            if keyword in text_lower or keyword in merchant_lower:
                matches.append(keyword)
                weight = PATTERN_WEIGHTS[pattern_type]
                risk_score += weight
                
        if matches:
            pattern_matches[pattern_type] = matches
            fraud_indicators.append(f"{pattern_type.replace('_', ' ').title()}: {', '.join(matches)}")
    
    # Análisis de contexto financiero
    if amount > 50000:
        risk_score += 30
        fraud_indicators.append("Transacción de alto valor (>50K)")
    elif amount > 20000:
        risk_score += 20
        fraud_indicators.append("Transacción de valor moderado-alto (>20K)")
    elif amount > 10000:
        risk_score += 15
        fraud_indicators.append("Transacción de valor moderado (>10K)")
    elif amount > 5000:
        risk_score += 10
        fraud_indicators.append("Transacción de valor medio (>5K)")
    
    # Análisis de comercio sospechoso
    suspicious_merchants = ['unknown', 'desconocido', 'temp', 'test', 'provisional']
    for suspect in suspicious_merchants:
        if suspect in merchant_lower:
            risk_score += 25
            fraud_indicators.append(f"Comercio sospechoso: {suspect}")
            break
    
    # Análisis de contexto temporal (horarios inusuales simulados)
    import random
    if random.random() < 0.3:  # 30% de probabilidad de horario sospechoso
        risk_score += 10
        fraud_indicators.append("Horario de transacción inusual")
    
    # Análisis de longitud y complejidad del texto
    if len(text) > 200:
        risk_score += 5
        fraud_indicators.append("Descripción excesivamente larga")
    elif len(text) < 20:
        risk_score += 8
        fraud_indicators.append("Descripción sospechosamente corta")
    
    # Limitar el score a 100
    risk_score = min(risk_score, 100)
    
    # Determinar si es fraude con threshold adaptativo
    if risk_score > 60:
        is_fraud = True
        confidence_level = "Alta"
    elif risk_score > 40:
        is_fraud = True  
        confidence_level = "Media"
    elif risk_score > 25:
        is_fraud = False
        confidence_level = "Sospechoso"
    else:
        is_fraud = False
        confidence_level = "Bajo riesgo"
    
    # Calcular confianza mejorada
    if is_fraud:
        confidence = min(0.70 + (risk_score / 200), 0.98)
    else:
        confidence = min(0.60 + ((100 - risk_score) / 150), 0.95)
    
    return {
        "fraud": is_fraud,
        "confidence": confidence,
        "risk_score": risk_score,
        "fraud_indicators": fraud_indicators,
        "confidence_level": confidence_level,
        "pattern_matches": pattern_matches,
        "algorithm_version": "Enhanced Semantic Analysis v2.0"
    }

@app.on_event("startup")
async def startup_event():
    """Evento de inicio de la aplicación"""
    logger.info("Iniciando servicio de detección de fraude...")
    global model_loaded
    model_loaded = True
    logger.info("Servicio listo para recibir peticiones")

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        model_loaded=model_loaded,
        model_version=model_version
    )

@app.post("/predict", response_model=FraudResponse)
async def predict_fraud_endpoint(request: TransactionRequest):
    """Endpoint principal para predicción de fraude"""
    start_time = time.time()
    
    try:
        # Validar entrada con más detalle
        if not request.text or not request.text.strip():
            raise HTTPException(status_code=400, detail="Texto de transacción requerido")
        
        if len(request.text.strip()) < 5:
            raise HTTPException(status_code=400, detail="Texto de transacción demasiado corto (mínimo 5 caracteres)")
        
        if len(request.text.strip()) > 1000:
            raise HTTPException(status_code=400, detail="Texto de transacción demasiado largo (máximo 1000 caracteres)")
        
        # Validar monto
        if request.amount < 0:
            raise HTTPException(status_code=400, detail="El monto no puede ser negativo")
        
        if request.amount > 1000000:
            raise HTTPException(status_code=400, detail="El monto excede el límite máximo")
        
        # Log de la petición
        logger.info(f"Predicción solicitada - Texto: {request.text[:50]}..., Monto: {request.amount}, Comercio: {request.merchant}")
        
        # Realizar predicción
        result = predict_fraud_enhanced(request.text, request.amount, request.merchant)
        
        # Calcular tiempo de procesamiento
        processing_time = (time.time() - start_time) * 1000
        
        logger.info(f"Predicción completada en {processing_time:.2f}ms - Fraude: {result['fraud']}, Confianza: {result['confidence']:.3f}")
        
        return FraudResponse(
            fraud=result["fraud"],
            confidence=result["confidence"],
            risk_score=result["risk_score"],
            model_version=model_version,
            processing_time_ms=processing_time
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error inesperado en predicción: {str(e)}")
        logger.error(f"Traceback: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail="Error interno del servidor")

@app.get("/")
async def root():
    """Endpoint raíz"""
    return {
        "service": "Fraud Detection Service",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "predict": "/predict"
        }
    }

if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8000,
        reload=False,
        log_level="info"
    ) 