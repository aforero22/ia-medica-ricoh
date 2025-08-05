"""
RICOH España - IA de Codificación Médica CIE-10-ES
Backend API con OpenAI GPT-4 Turbo para codificación médica experta
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import logging
import os
import time
import json
from datetime import datetime

# Importar OpenAI y base de datos CIE-10
from openai import OpenAI
from models.cie10_database import CIE10Database
from dotenv import load_dotenv

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="RICOH España - IA Codificación Médica CIE-10-ES",
    description="API de codificación médica con GPT-4 Turbo y base CIE-10-ES oficial",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios exactos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modelos de datos según especificación
class SolicitudCodificacion(BaseModel):
    diagnostico: str
    edad: Optional[int] = None
    sintomas: Optional[List[str]] = []

class DiagnosticoPrincipal(BaseModel):
    codigo: str
    descripcion: str
    justificacion: str

class DiagnosticoSecundario(BaseModel):
    codigo: str
    descripcion: str
    justificacion: str

class RespuestaCodificacion(BaseModel):
    diagnostico_propuesto: str
    diagnostico_principal: DiagnosticoPrincipal
    diagnosticos_secundarios: List[DiagnosticoSecundario] = []
    tiempo_procesamiento: Optional[float] = None
    motor_ia: str = "OpenAI GPT-4 Turbo"
    base_datos: str = "CIE-10-ES Ministerio Sanidad"

class HealthResponse(BaseModel):
    status: str
    motor_ia: str
    base_datos: str
    version: str
    timestamp: str

# Cargar variables de entorno desde archivo local
load_dotenv('config.env')

# Instancias globales
client = None
cie10_db = None

# Prompt médico experto según especificación exacta
PROMPT_MEDICO_EXPERTO = """Actúa como un codificador médico experto en CIE‑10‑ES (versión española oficial del Ministerio de Sanidad).

Se te proporcionará:
- Un diagnóstico clínico en lenguaje natural
- La edad del paciente
- Síntomas relevantes

Tu tarea es:
1. Proponer un diagnóstico estructurado breve basado en la información.
2. Identificar el diagnóstico principal más probable.
3. Listar diagnósticos secundarios clínicamente relevantes.
4. Para cada uno, entregar:
   - Código CIE‑10‑ES
   - Descripción en español
   - Justificación médica basada en los datos (edad, síntomas, diagnóstico)

Formato de respuesta (JSON):

{
  "diagnóstico_propuesto": "[resumen breve]",
  "diagnóstico_principal": {
    "código": "Jxx.xx",
    "descripción": "[nombre oficial en español]",
    "justificación": "[por qué aplica este código al caso]"
  },
  "diagnósticos_secundarios": [
    {
      "código": "Jyy.yy",
      "descripción": "[nombre oficial]",
      "justificación": "[motivo clínico]"
    }
  ]
}

Responde ÚNICAMENTE con el JSON válido, sin texto adicional."""

@app.on_event("startup")
async def startup_event():
    """Inicializar OpenAI y base de datos CIE-10-ES al startup"""
    global client, cie10_db
    try:
        # Inicializar base de datos CIE-10-ES
        cie10_db = CIE10Database()
        stats = cie10_db.get_stats()
        logger.info(f"✅ Base de datos CIE-10-ES cargada: {stats['codigos_totales']} códigos")
        
        # Verificar API key
        api_key = os.getenv('OPENAI_API_KEY')
        if not api_key:
            logger.error("❌ OPENAI_API_KEY no encontrado en variables de entorno")
            logger.error("💡 Para configurar: export OPENAI_API_KEY=sk-your-key-here")
            return
        
        # Inicializar cliente OpenAI
        client = OpenAI(api_key=api_key)
        logger.info("✅ RICOH España - Motor GPT-4 Turbo inicializado correctamente")
        
    except Exception as e:
        logger.error(f"❌ Error inicializando sistema: {str(e)}")

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Check de salud del servicio RICOH"""
    return HealthResponse(
        status="healthy" if client else "error",
        motor_ia="OpenAI GPT-4 Turbo" if client else "No disponible",
        base_datos="CIE-10-ES Ministerio de Sanidad",
        version="RICOH España v1.0.0",
        timestamp=datetime.now().isoformat()
    )

@app.post("/codificar", response_model=RespuestaCodificacion)
async def codificar_diagnostico(solicitud: SolicitudCodificacion):
    """
    Endpoint principal para codificación CIE-10-ES
    Según especificación RICOH España
    """
    if not client:
        raise HTTPException(
            status_code=503, 
            detail="Servicio no disponible - GPT-4 no inicializado. Verifique OPENAI_API_KEY."
        )
    
    # Validar entrada
    if not solicitud.diagnostico.strip():
        raise HTTPException(
            status_code=400, 
            detail="El diagnóstico clínico es requerido"
        )
    
    start_time = time.time()
    
    try:
        # Buscar códigos relevantes en la base de datos CIE-10-ES
        codigos_relevantes = []
        if solicitud.sintomas:
            codigos_relevantes = cie10_db.buscar_por_sintomas(solicitud.sintomas)
        
        # Buscar códigos adicionales basados en el diagnóstico
        codigos_diagnostico = cie10_db.buscar_codigos_similares(solicitud.diagnostico, limite=3)
        codigos_relevantes.extend([codigo for codigo, desc in codigos_diagnostico])
        
        # Generar contexto CIE-10-ES para GPT-4
        contexto_cie10 = cie10_db.obtener_contexto_medico(list(set(codigos_relevantes)))
        
        # Construir el prompt con los datos del paciente y contexto CIE-10
        prompt_usuario = f"""DATOS DEL PACIENTE:

Diagnóstico clínico: {solicitud.diagnostico}
Edad del paciente: {solicitud.edad if solicitud.edad else 'No especificada'}
Síntomas relevantes: {', '.join(solicitud.sintomas) if solicitud.sintomas else 'No especificados'}

{contexto_cie10}

Analiza estos datos y proporciona la codificación CIE-10-ES según las instrucciones, utilizando preferentemente los códigos del contexto cuando sean apropiados."""

        # Llamada a GPT-4 Turbo
        response = client.chat.completions.create(
            model="gpt-4o",  # GPT-4 Omni (modelo actual disponible)
            messages=[
                {
                    "role": "system", 
                    "content": PROMPT_MEDICO_EXPERTO
                },
                {
                    "role": "user", 
                    "content": prompt_usuario
                }
            ],
            temperature=0.1,  # Baja creatividad para precisión médica
            max_tokens=1200,
            response_format={"type": "json_object"}
        )
        
        # Procesar respuesta de GPT-4
        resultado_json = json.loads(response.choices[0].message.content)
        
        # Validar y estructurar respuesta según el modelo
        diagnostico_principal = DiagnosticoPrincipal(
            codigo=resultado_json["diagnóstico_principal"]["código"],
            descripcion=resultado_json["diagnóstico_principal"]["descripción"],
            justificacion=resultado_json["diagnóstico_principal"]["justificación"]
        )
        
        # Procesar diagnósticos secundarios
        diagnosticos_secundarios = []
        if "diagnósticos_secundarios" in resultado_json:
            for diag_sec in resultado_json["diagnósticos_secundarios"]:
                diagnosticos_secundarios.append(DiagnosticoSecundario(
                    codigo=diag_sec["código"],
                    descripcion=diag_sec["descripción"],
                    justificacion=diag_sec["justificación"]
                ))
        
        tiempo_procesamiento = time.time() - start_time
        
        # Respuesta final según especificación RICOH
        return RespuestaCodificacion(
            diagnostico_propuesto=resultado_json["diagnóstico_propuesto"],
            diagnostico_principal=diagnostico_principal,
            diagnosticos_secundarios=diagnosticos_secundarios,
            tiempo_procesamiento=round(tiempo_procesamiento, 2)
        )
        
    except json.JSONDecodeError as e:
        logger.error(f"Error decodificando JSON de GPT-4: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail="Error en el formato de respuesta del motor de IA"
        )
    except Exception as e:
        logger.error(f"Error en codificación GPT-4: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail=f"Error en codificación médica: {str(e)}"
        )

@app.get("/status")
async def status_detallado():
    """Estado detallado del sistema RICOH"""
    cie10_stats = cie10_db.get_stats() if cie10_db else {}
    
    return {
        "servicio": "RICOH España - IA Codificación Médica CIE-10-ES",
        "version": "1.0.0",
        "motor_ia": {
            "proveedor": "OpenAI",
            "modelo": "gpt-4o (GPT-4 Omni)",
            "disponible": client is not None
        },
        "base_datos": {
            "fuente": cie10_stats.get('fuente', 'CIE-10-ES Ministerio de Sanidad España'),
            "version": cie10_stats.get('version', 'N/A'),
            "categorias": cie10_stats.get('categorias', 0),
            "codigos_totales": cie10_stats.get('codigos_totales', 0),
            "sintomas_indexados": cie10_stats.get('sintomas_indexados', 0),
            "url_oficial": "https://eciemaps.mscbs.gob.es/ecieMaps/browser/index_10_mc.html",
            "disponible": cie10_db is not None
        },
        "api_key_configurada": bool(os.getenv('OPENAI_API_KEY')),
        "endpoints": {
            "codificacion": "/codificar",
            "salud": "/health",
            "estado": "/status",
            "cie10": "/cie10/buscar"
        },
        "timestamp": datetime.now().isoformat()
    }

@app.get("/cie10/buscar")
async def buscar_cie10(q: str = "", limite: int = 5):
    """
    Buscar códigos CIE-10 por término de búsqueda
    """
    try:
        if not cie10_db:
            raise HTTPException(status_code=500, detail="Base de datos CIE-10 no disponible")
        
        resultados = cie10_db.buscar_codigos_similares(q, limite)
        return {
            "busqueda": q,
            "resultados": resultados,
            "total": len(resultados)
        }
    except Exception as e:
        logger.error(f"Error en búsqueda CIE-10: {e}")
        raise HTTPException(status_code=500, detail=f"Error en búsqueda: {str(e)}")

@app.get("/ejemplos-clinicos/aleatorio")
async def obtener_ejemplo_clinico_aleatorio():
    """
    Obtener un ejemplo clínico aleatorio de los 50 ejemplos integrados
    """
    ejemplos_clinicos = [
        {
            "diagnostico": "Paciente de 45 años con presión arterial 160/100 mmHg",
            "edad": 45,
            "sintomas": ["Presión arterial elevada", "Dolor de cabeza", "Mareos"],
            "codigo_esperado": "I10",
            "descripcion": "Hipertensión esencial (primaria)"
        },
        {
            "diagnostico": "Paciente de 55 años con glucemia en ayunas de 180 mg/dL",
            "edad": 55,
            "sintomas": ["Poliuria", "Polidipsia", "Pérdida de peso"],
            "codigo_esperado": "E11.9",
            "descripcion": "Diabetes mellitus no insulinodependiente sin mención de complicación"
        },
        {
            "diagnostico": "Paciente de 65 años con dolor precordial de 2 horas de evolución",
            "edad": 65,
            "sintomas": ["Dolor torácico", "Disnea", "Sudoración"],
            "codigo_esperado": "I21.4",
            "descripcion": "Infarto agudo de miocardio no transmural"
        },
        {
            "diagnostico": "Paciente de 30 años con cefalea pulsátil de 4 horas",
            "edad": 30,
            "sintomas": ["Cefalea unilateral", "Fotofobia", "Náuseas"],
            "codigo_esperado": "G43.0",
            "descripcion": "Migraña sin aura"
        },
        {
            "diagnostico": "Paciente fumador de 70 años con exacerbación de EPOC",
            "edad": 70,
            "sintomas": ["Disnea", "Tos productiva", "Sibilancias"],
            "codigo_esperado": "J44.0",
            "descripcion": "EPOC con infección aguda de las vías respiratorias inferiores"
        },
        {
            "diagnostico": "Paciente de 40 años con dolor abdominal superior",
            "edad": 40,
            "sintomas": ["Dolor epigástrico", "Náuseas", "Pérdida de apetito"],
            "codigo_esperado": "K29.3",
            "descripcion": "Gastritis crónica superficial"
        },
        {
            "diagnostico": "Paciente de 45 años con lumbalgia de 3 días",
            "edad": 45,
            "sintomas": ["Dolor lumbar", "Limitación de movimientos", "Rigidez"],
            "codigo_esperado": "M79.3",
            "descripcion": "Dolor en la región lumbar"
        },
        {
            "diagnostico": "Paciente de 35 años con temperatura de 38.5°C",
            "edad": 35,
            "sintomas": ["Fiebre", "Malestar general", "Escalofríos"],
            "codigo_esperado": "R50.9",
            "descripcion": "Fiebre no especificada"
        },
        {
            "diagnostico": "Paciente de 75 años con disnea de esfuerzo",
            "edad": 75,
            "sintomas": ["Disnea", "Edema periférico", "Fatiga"],
            "codigo_esperado": "I50.0",
            "descripcion": "Insuficiencia cardíaca congestiva"
        },
        {
            "diagnostico": "Paciente con glucemia de 450 mg/dL y cetonas positivas",
            "edad": 28,
            "sintomas": ["Poliuria", "Polidipsia", "Náuseas", "Dolor abdominal"],
            "codigo_esperado": "E11.1",
            "descripcion": "Diabetes mellitus no insulinodependiente con cetoacidosis"
        },
        {
            "diagnostico": "Paciente de 60 años con infiltrado pulmonar derecho",
            "edad": 60,
            "sintomas": ["Fiebre", "Tos", "Disnea", "Dolor torácico"],
            "codigo_esperado": "J18.9",
            "descripcion": "Neumonía no especificada"
        },
        {
            "diagnostico": "Paciente de 70 años con melena de 24 horas",
            "edad": 70,
            "sintomas": ["Melena", "Hematemesis", "Dolor abdominal"],
            "codigo_esperado": "K92.2",
            "descripcion": "Hemorragia gastrointestinal no especificada"
        },
        {
            "diagnostico": "Paciente de 25 años con crisis convulsiva tónico-clónica",
            "edad": 25,
            "sintomas": ["Convulsiones", "Pérdida de consciencia", "Confusión"],
            "codigo_esperado": "G40.9",
            "descripcion": "Epilepsia no especificada"
        },
        {
            "diagnostico": "Paciente de 68 años con hemiparesia izquierda súbita",
            "edad": 68,
            "sintomas": ["Hemiparesia", "Afasia", "Alteración de consciencia"],
            "codigo_esperado": "I63.4",
            "descripcion": "Infarto cerebral debido a embolia de arterias cerebrales"
        },
        {
            "diagnostico": "Paciente de 65 años con creatinina 3.2 mg/dL",
            "edad": 65,
            "sintomas": ["Fatiga", "Edema", "Anemia", "Hipertensión"],
            "codigo_esperado": "N18.9",
            "descripcion": "Insuficiencia renal crónica no especificada"
        },
        {
            "diagnostico": "Paciente de 70 años con artrosis de rodillas y caderas",
            "edad": 70,
            "sintomas": ["Dolor articular", "Rigidez", "Limitación de movimientos"],
            "codigo_esperado": "M15.0",
            "descripcion": "Artrosis primaria generalizada"
        },
        {
            "diagnostico": "Paciente de 40 años con cefalea tensional",
            "edad": 40,
            "sintomas": ["Dolor de cabeza", "Fotofobia", "Náuseas"],
            "codigo_esperado": "R51",
            "descripcion": "Cefalea"
        },
        {
            "diagnostico": "Paciente de 50 años con colesterol total 280 mg/dL",
            "edad": 50,
            "sintomas": ["Asintomático", "Xantomas", "Arco corneal"],
            "codigo_esperado": "E78.0",
            "descripcion": "Hipercolesterolemia pura"
        },
        {
            "diagnostico": "Paciente de 60 años con angina de esfuerzo",
            "edad": 60,
            "sintomas": ["Dolor torácico", "Disnea", "Fatiga"],
            "codigo_esperado": "I25.1",
            "descripcion": "Enfermedad aterosclerótica del corazón"
        },
        {
            "diagnostico": "Paciente de 35 años con crisis asmática",
            "edad": 35,
            "sintomas": ["Sibilancias", "Tos", "Disnea", "Opresión torácica"],
            "codigo_esperado": "J45.9",
            "descripcion": "Asma no especificada"
        },
        {
            "diagnostico": "Paciente de 45 años con estreñimiento crónico",
            "edad": 45,
            "sintomas": ["Dificultad para defecar", "Dolor abdominal", "Distensión"],
            "codigo_esperado": "K59.0",
            "descripcion": "Estreñimiento"
        },
        {
            "diagnostico": "Paciente con paro cardíaco y daño cerebral anóxico",
            "edad": 55,
            "sintomas": ["Alteración de consciencia", "Convulsiones", "Déficit neurológico"],
            "codigo_esperado": "G93.1",
            "descripcion": "Anoxia cerebral no clasificada en otra parte"
        },
        {
            "diagnostico": "Paciente de 65 años con angina de reposo",
            "edad": 65,
            "sintomas": ["Dolor torácico", "Disnea", "Sudoración"],
            "codigo_esperado": "I20.0",
            "descripcion": "Angina de pecho inestable"
        },
        {
            "diagnostico": "Paciente con nefropatía diabética y proteinuria",
            "edad": 58,
            "sintomas": ["Poliuria", "Edema", "Hipertensión", "Proteinuria"],
            "codigo_esperado": "E11.2",
            "descripcion": "Diabetes mellitus no insulinodependiente con complicaciones renales"
        },
        {
            "diagnostico": "Paciente fumador con exacerbación de EPOC",
            "edad": 72,
            "sintomas": ["Disnea", "Tos", "Producción de esputo"],
            "codigo_esperado": "J44.1",
            "descripcion": "EPOC con exacerbación aguda no especificada"
        },
        {
            "diagnostico": "Paciente de 50 años con úlcera gástrica crónica",
            "edad": 50,
            "sintomas": ["Dolor epigástrico", "Náuseas", "Pérdida de apetito"],
            "codigo_esperado": "K25.9",
            "descripcion": "Úlcera gástrica no especificada"
        },
        {
            "diagnostico": "Paciente de 40 años con lumbalgia mecánica",
            "edad": 40,
            "sintomas": ["Dolor lumbar", "Limitación de movimientos", "Rigidez"],
            "codigo_esperado": "M54.5",
            "descripcion": "Dolor en la región lumbar"
        },
        {
            "diagnostico": "Paciente de 55 años con dolor precordial atípico",
            "edad": 55,
            "sintomas": ["Dolor torácico", "Opresión", "Disconfort"],
            "codigo_esperado": "R07.9",
            "descripcion": "Dolor en el tórax no especificado"
        },
        {
            "diagnostico": "Paciente de 70 años con disnea de esfuerzo progresiva",
            "edad": 70,
            "sintomas": ["Disnea", "Ortopnea", "Disnea paroxística nocturna"],
            "codigo_esperado": "I50.1",
            "descripcion": "Insuficiencia cardíaca izquierda"
        },
        {
            "diagnostico": "Paciente con neuropatía diabética periférica",
            "edad": 62,
            "sintomas": ["Parestesias", "Dolor neuropático", "Pérdida de sensibilidad"],
            "codigo_esperado": "E11.4",
            "descripcion": "Diabetes mellitus no insulinodependiente con complicaciones neurológicas"
        },
        {
            "diagnostico": "Paciente de 65 años con infiltrado bronconeumónico",
            "edad": 65,
            "sintomas": ["Fiebre", "Tos", "Disnea", "Dolor torácico"],
            "codigo_esperado": "J18.0",
            "descripcion": "Bronconeumonía no especificada"
        },
        {
            "diagnostico": "Paciente de 75 años con melena de 48 horas",
            "edad": 75,
            "sintomas": ["Heces negras", "Dolor abdominal", "Anemia"],
            "codigo_esperado": "K92.1",
            "descripcion": "Melena"
        },
        {
            "diagnostico": "Paciente de 30 años con crisis parciales complejas",
            "edad": 30,
            "sintomas": ["Convulsiones focales", "Aura", "Alteración de consciencia"],
            "codigo_esperado": "G40.1",
            "descripcion": "Epilepsia localizada sintomática"
        },
        {
            "diagnostico": "Paciente de 72 años con ACV isquémico carotídeo",
            "edad": 72,
            "sintomas": ["Hemiparesia", "Afasia", "Alteración de consciencia"],
            "codigo_esperado": "I63.2",
            "descripcion": "Infarto cerebral debido a oclusión de arterias precerebrales"
        },
        {
            "diagnostico": "Paciente con TFG 90 ml/min y microalbuminuria",
            "edad": 45,
            "sintomas": ["Asintomático", "Proteinuria", "Hipertensión"],
            "codigo_esperado": "N18.1",
            "descripcion": "Enfermedad renal crónica estadio 1"
        },
        {
            "diagnostico": "Paciente de 60 años con artrosis de la base del pulgar",
            "edad": 60,
            "sintomas": ["Dolor en la base del pulgar", "Limitación de movimientos", "Deformidad"],
            "codigo_esperado": "M15.1",
            "descripcion": "Artrosis de la primera articulación carpometacarpiana"
        },
        {
            "diagnostico": "Paciente de 45 años con dolor crónico generalizado",
            "edad": 45,
            "sintomas": ["Dolor", "Malestar", "Disconfort"],
            "codigo_esperado": "R52.9",
            "descripcion": "Dolor no especificado"
        },
        {
            "diagnostico": "Paciente de 40 años con triglicéridos 500 mg/dL",
            "edad": 40,
            "sintomas": ["Asintomático", "Xantomas", "Pancreatitis"],
            "codigo_esperado": "E78.1",
            "descripcion": "Hipergliceridemia pura"
        },
        {
            "diagnostico": "Paciente de 65 años con enfermedad coronaria estable",
            "edad": 65,
            "sintomas": ["Dolor torácico", "Disnea", "Fatiga"],
            "codigo_esperado": "I25.0",
            "descripcion": "Enfermedad cardiovascular aterosclerótica"
        },
        {
            "diagnostico": "Paciente de 25 años con asma alérgica estacional",
            "edad": 25,
            "sintomas": ["Sibilancias", "Tos", "Disnea", "Rinorrea"],
            "codigo_esperado": "J45.0",
            "descripcion": "Asma alérgica predominante"
        },
        {
            "diagnostico": "Paciente de 35 años con síndrome del intestino irritable",
            "edad": 35,
            "sintomas": ["Diarrea", "Dolor abdominal", "Urgencia defecatoria"],
            "codigo_esperado": "K59.1",
            "descripcion": "Diarrea funcional"
        },
        {
            "diagnostico": "Paciente de 70 años con hidrocefalia normotensiva",
            "edad": 70,
            "sintomas": ["Cefalea", "Náuseas", "Alteración de consciencia", "Trastornos de marcha"],
            "codigo_esperado": "G93.2",
            "descripcion": "Hidrocefalia no especificada"
        },
        {
            "diagnostico": "Paciente de 60 años con angina variante",
            "edad": 60,
            "sintomas": ["Dolor torácico", "Disnea", "Fatiga"],
            "codigo_esperado": "I20.8",
            "descripcion": "Otras formas de angina de pecho"
        },
        {
            "diagnostico": "Paciente con retinopatía diabética proliferativa",
            "edad": 55,
            "sintomas": ["Visión borrosa", "Fotopsias", "Pérdida de visión"],
            "codigo_esperado": "E11.3",
            "descripcion": "Diabetes mellitus no insulinodependiente con complicaciones oftálmicas"
        },
        {
            "diagnostico": "Paciente fumador con exacerbación infecciosa de EPOC",
            "edad": 68,
            "sintomas": ["Disnea", "Tos", "Producción de esputo", "Fiebre"],
            "codigo_esperado": "J44.2",
            "descripcion": "EPOC con exacerbación aguda"
        },
        {
            "diagnostico": "Paciente de 55 años con úlcera gástrica sangrante",
            "edad": 55,
            "sintomas": ["Dolor epigástrico", "Hematemesis", "Melena", "Anemia"],
            "codigo_esperado": "K25.0",
            "descripcion": "Úlcera gástrica aguda con hemorragia"
        },
        {
            "diagnostico": "Paciente de 45 años con dorsalgia mecánica",
            "edad": 45,
            "sintomas": ["Dolor dorsal", "Rigidez", "Limitación de movimientos"],
            "codigo_esperado": "M54.6",
            "descripcion": "Dolor en la columna torácica"
        },
        {
            "diagnostico": "Paciente de 50 años con dolor pleurítico",
            "edad": 50,
            "sintomas": ["Dolor torácico", "Disnea", "Tos"],
            "codigo_esperado": "R07.1",
            "descripcion": "Dolor en el tórax al respirar"
        },
        {
            "diagnostico": "Paciente de 75 años con insuficiencia cardíaca global",
            "edad": 75,
            "sintomas": ["Disnea", "Fatiga", "Edema periférico"],
            "codigo_esperado": "I50.9",
            "descripcion": "Insuficiencia cardíaca no especificada"
        },
        {
            "diagnostico": "Paciente con pie diabético y úlcera en talón",
            "edad": 67,
            "sintomas": ["Dolor en extremidades", "Claudicación", "Úlceras"],
            "codigo_esperado": "E11.5",
            "descripcion": "Diabetes mellitus no insulinodependiente con complicaciones circulatorias periféricas"
        },
        {
            "diagnostico": "Paciente de 60 años con neumonía del lóbulo inferior derecho",
            "edad": 60,
            "sintomas": ["Fiebre", "Tos", "Disnea", "Dolor torácico"],
            "codigo_esperado": "J18.1",
            "descripcion": "Neumonía lobar no especificada"
        },
        {
            "diagnostico": "Paciente de 70 años con hematemesis masiva",
            "edad": 70,
            "sintomas": ["Vómitos con sangre", "Dolor abdominal", "Anemia"],
            "codigo_esperado": "K92.0",
            "descripcion": "Hematemesis"
        },
        {
            "diagnostico": "Paciente de 35 años con crisis parciales complejas",
            "edad": 35,
            "sintomas": ["Convulsiones focales", "Alteración de consciencia", "Automatismos"],
            "codigo_esperado": "G40.2",
            "descripcion": "Epilepsia localizada sintomática"
        },
        {
            "diagnostico": "Paciente de 68 años con ACV embólico carotídeo",
            "edad": 68,
            "sintomas": ["Hemiparesia", "Afasia", "Alteración de consciencia"],
            "codigo_esperado": "I63.1",
            "descripcion": "Infarto cerebral debido a embolia de arterias precerebrales"
        },
        {
            "diagnostico": "Paciente con TFG 65 ml/min y proteinuria leve",
            "edad": 52,
            "sintomas": ["Asintomático", "Proteinuria", "Hipertensión"],
            "codigo_esperado": "N18.2",
            "descripcion": "Enfermedad renal crónica estadio 2"
        },
        {
            "diagnostico": "Paciente de 65 años con artrosis erosiva de manos",
            "edad": 65,
            "sintomas": ["Dolor articular", "Rigidez", "Deformidad"],
            "codigo_esperado": "M15.2",
            "descripcion": "Artrosis erosiva"
        },
        {
            "diagnostico": "Paciente de 50 años con fatiga crónica",
            "edad": 50,
            "sintomas": ["Fatiga", "Malestar general", "Astenia"],
            "codigo_esperado": "R53",
            "descripcion": "Malestar y fatiga"
        },
        {
            "diagnostico": "Paciente de 40 años con triglicéridos 500 mg/dL",
            "edad": 40,
            "sintomas": ["Asintomático", "Xantomas", "Pancreatitis"],
            "codigo_esperado": "E78.1",
            "descripcion": "Hipergliceridemia pura"
        }
    ]
    
    import random
    ejemplo_aleatorio = random.choice(ejemplos_clinicos)
    
    return {
        "ejemplo": ejemplo_aleatorio,
        "total_ejemplos": len(ejemplos_clinicos),
        "mensaje": "Ejemplo clínico aleatorio cargado exitosamente"
    }

@app.get("/")
async def root():
    """Endpoint raíz con información del servicio RICOH"""
    return {
        "servicio": "RICOH España - IA de Codificación Médica CIE-10-ES",
        "version": "1.0.0",
        "descripcion": "API de codificación médica con GPT-4 Turbo y base CIE-10-ES oficial del Ministerio de Sanidad",
        "empresa": "RICOH España",
        "endpoints": {
            "codificar": "POST /codificar - Endpoint principal de codificación",
            "health": "GET /health - Estado de salud del servicio",
            "status": "GET /status - Estado detallado del sistema"
        },
        "motor_ia": "OpenAI GPT-4 Turbo",
        "base_datos": "CIE-10-ES Ministerio de Sanidad",
        "status": "ready" if client else "error - configure OPENAI_API_KEY"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)