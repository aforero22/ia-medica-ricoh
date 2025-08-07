# 🏥 **DOCUMENTACIÓN TÉCNICA DEL CÓDIGO - APLICACIÓN CIE-10**

## **📁 ESTRUCTURA DEL CÓDIGO**

### **Backend (medical-service-advanced/)**

#### **app.py - API Principal**
```python
# Funcionalidades principales:
- FastAPI con endpoints REST
- Integración con OpenAI GPT-4 Turbo
- Carga de base de datos CIE-10
- Validación de datos con Pydantic
- Logging y monitoreo
```

#### **Modelos de Datos (Pydantic)**
```python
class SolicitudCodificacion(BaseModel):
    diagnostico: str
    edad: Optional[int] = None
    sintomas: Optional[List[str]] = []

class RespuestaCodificacion(BaseModel):
    diagnostico_propuesto: str
    diagnostico_principal: DiagnosticoPrincipal
    diagnosticos_secundarios: List[DiagnosticoSecundario]
    tiempo_procesamiento: Optional[float]
    motor_ia: str = "OpenAI GPT-4 Turbo"
    base_datos: str = "CIE-10-ES Ministerio Sanidad"
```

#### **Endpoints Principales**
```python
# POST /codificar
- Recibe diagnóstico en lenguaje natural
- Procesa con GPT-4 Turbo
- Retorna códigos CIE-10 + explicaciones

# GET /ejemplos-clinicos/aleatorio
- Retorna casos clínicos aleatorios
- Para demostración y testing

# GET /health
- Verificación de estado del servicio
- Información de versión y configuración
```

#### **Base de Datos CIE-10**
```python
# models/cie10_database.py
- Carga de 14,498 códigos CIE-10
- Búsqueda por síntomas
- Validación de códigos
- Índice de palabras clave (6,090 términos)
```

### **Frontend (frontend-app/)**

#### **index.html - Interfaz Principal**
```html
# Características:
- Diseño responsive con Tailwind CSS
- Formulario médico intuitivo
- Comunicación con API backend
- Notificaciones en tiempo real
- Ejemplos clínicos aleatorios
```

#### **JavaScript - Lógica de Interfaz**
```javascript
# Funcionalidades:
- Envío de diagnósticos al backend
- Carga de ejemplos clínicos
- Visualización de resultados
- Manejo de errores
- Notificaciones de estado
```

#### **server.py - Servidor Web**
```python
# Servidor web simple para servir HTML
- Flask para desarrollo local
- Puerto 3000
- CORS configurado
```

---

## **🔧 CONFIGURACIÓN TÉCNICA**

### **Variables de Entorno**
```bash
# config.env (NO COMMITAR)
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### **Dependencias Backend**
```txt
# requirements.txt
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.5.0
openai>=1.50.0
python-dotenv==1.0.0
requests==2.32.4
```

### **Dependencias Frontend**
```txt
# Servidor web
flask

# Frontend (CDN)
- Tailwind CSS
- Font Awesome
- Google Fonts
```

---

## **🐳 CONFIGURACIÓN DOCKER**

### **Backend Dockerfile**
```dockerfile
FROM python:3.9-slim
WORKDIR /app

# Instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir \
    fastapi==0.104.1 \
    uvicorn==0.24.0 \
    pydantic==2.5.0 \
    openai>=1.50.0 \
    python-dotenv==1.0.0 \
    requests==2.32.4

# Copiar configuración y código
COPY config.env .env
COPY . .

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

### **Frontend Dockerfile**
```dockerfile
FROM python:3.9-slim
WORKDIR /app

# Copiar archivos
COPY server.py .
COPY index.html .

# Instalar Flask
RUN pip install --no-cache-dir flask

EXPOSE 3000
CMD ["python", "server.py"]
```

---

## **☸️ CONFIGURACIÓN KUBERNETES**

### **Backend Deployment**
```yaml
# k8s/backend-ricoh-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-ricoh
  namespace: medical-only
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend-ricoh
  template:
    metadata:
      labels:
        app: backend-ricoh
    spec:
      containers:
      - name: backend-ricoh
        image: backend-ricoh:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 8000
```

### **Frontend Deployment**
```yaml
# k8s/frontend-ricoh-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-ricoh
  namespace: medical-only
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend-ricoh
  template:
    metadata:
      labels:
        app: frontend-ricoh
    spec:
      containers:
      - name: frontend-ricoh
        image: frontend-ricoh:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 3000
```

---

## **🤖 INTEGRACIÓN CON IA**

### **Prompt Médico Experto**
```python
PROMPT_MEDICO_EXPERTO = """
Actúa como un codificador médico experto en CIE-10-ES.

Tu tarea es:
1. Proponer diagnóstico estructurado
2. Identificar diagnóstico principal
3. Listar diagnósticos secundarios
4. Entregar código CIE-10-ES + descripción + justificación

Formato de respuesta (JSON):
{
  "diagnóstico_propuesto": "[resumen breve]",
  "diagnóstico_principal": {
    "código": "Jxx.xx",
    "descripción": "[descripción en español]",
    "justificación": "[explicación médica]"
  },
  "diagnósticos_secundarios": [
    {
      "código": "Ixx.xx",
      "descripción": "[descripción]",
      "justificación": "[explicación]"
    }
  ]
}
"""
```

### **Procesamiento de IA**
```python
# Flujo de procesamiento:
1. Recibe diagnóstico en español
2. Construye prompt con contexto médico
3. Envía a OpenAI GPT-4 Turbo
4. Procesa respuesta JSON
5. Valida códigos en base de datos CIE-10
6. Retorna resultado estructurado
```

---

## **📊 BASE DE DATOS CIE-10**

### **Estructura de Datos**
```json
{
  "metadata": {
    "version": "CIE-10-ES 2024",
    "total_codigos": 14498,
    "categorias_principales": 2038
  },
  "codigos": {
    "A00-B99": {
      "categoria": "Ciertas enfermedades infecciosas y parasitarias",
      "subcategorias": {
        "A00": "Cólera",
        "A01": "Fiebres tifoidea y paratifoidea"
      }
    }
  },
  "sintomas_index": {
    "dolor de cabeza": ["G43.0", "G43.1", "R51"],
    "fiebre": ["A00", "A01", "R50"]
  }
}
```

### **Funciones de Base de Datos**
```python
# models/cie10_database.py
class CIE10Database:
    def buscar_por_sintomas(self, sintomas: List[str]) -> List[str]
    def obtener_descripcion(self, codigo: str) -> Optional[str]
    def validar_codigo(self, codigo: str) -> bool
    def buscar_codigos_similares(self, texto: str, limite: int = 5) -> List[Tuple[str, str]]
    def obtener_contexto_medico(self, codigos: List[str]) -> str
```

---

## **🔍 VALIDACIÓN Y ERRORES**

### **Validación de Entrada**
```python
# Validaciones implementadas:
- Diagnóstico no vacío
- Edad en rango válido (0-150)
- Síntomas como lista de strings
- Longitud máxima de diagnóstico
```

### **Manejo de Errores**
```python
# Tipos de errores manejados:
- Error de conexión con OpenAI
- Códigos CIE-10 no válidos
- Timeout en procesamiento
- Errores de validación de datos
```

### **Logging**
```python
# Logs implementados:
- Inicio de aplicación
- Carga de base de datos
- Solicitudes de codificación
- Errores y excepciones
- Métricas de rendimiento
```

---

## **🚀 OPTIMIZACIONES IMPLEMENTADAS**

### **Rendimiento**
```python
# Optimizaciones:
- Carga única de base de datos en memoria
- Cache de respuestas frecuentes
- Procesamiento asíncrono
- Timeout configurado para OpenAI
```

### **Seguridad**
```python
# Medidas de seguridad:
- API key en archivo local (no en código)
- Validación de entrada con Pydantic
- CORS configurado
- Logging sin datos sensibles
```

### **Escalabilidad**
```python
# Características escalables:
- Múltiples réplicas (2 frontend, 3 backend)
- Load balancing automático
- Configuración por variables de entorno
- Separación frontend/backend
```

---

## **🧪 TESTING**

### **Endpoints de Testing**
```python
# GET /health
- Verificación de estado del servicio
- Información de versión
- Estado de conexión con OpenAI

# GET /status
- Estado detallado del sistema
- Estadísticas de base de datos
- Métricas de rendimiento
```

### **Casos de Prueba**
```python
# Ejemplos de testing:
- Diagnósticos simples (diabetes, hipertensión)
- Casos complejos (múltiples condiciones)
- Validación de códigos CIE-10
- Manejo de errores
```

---

## **📈 MÉTRICAS Y MONITOREO**

### **Métricas Implementadas**
```python
# Métricas disponibles:
- Tiempo de procesamiento por solicitud
- Número de códigos en base de datos
- Precisión de codificación
- Disponibilidad del servicio
```

### **Logs Estructurados**
```python
# Información loggeada:
- Timestamp de cada solicitud
- Diagnóstico procesado
- Códigos generados
- Tiempo de respuesta
- Errores y excepciones
```

---

## **🔧 COMANDOS DE DESARROLLO**

### **Desarrollo Local**
```bash
# Instalar dependencias
pip install -r requirements.txt

# Ejecutar backend
uvicorn app:app --reload --host 0.0.0.0 --port 8000

# Ejecutar frontend
python server.py
```

### **Docker**
```bash
# Construir imágenes
docker build -t backend-ricoh:latest medical-service-advanced/
docker build -t frontend-ricoh:latest frontend-app/

# Ejecutar contenedores
docker run -p 8000:8000 backend-ricoh:latest
docker run -p 3000:3000 frontend-ricoh:latest
```

### **Kubernetes**
```bash
# Desplegar en Minikube
kubectl apply -f k8s/

# Verificar estado
kubectl get pods -n medical-only
kubectl logs deployment/backend-ricoh -n medical-only
```

---

## **📝 CONVENCIONES DE CÓDIGO**

### **Python (Backend)**
```python
# Convenciones:
- Docstrings en todas las funciones
- Type hints obligatorios
- Logging estructurado
- Manejo de excepciones
- Validación de entrada
```

### **JavaScript (Frontend)**
```javascript
// Convenciones:
- Funciones async/await
- Manejo de errores con try/catch
- Comentarios descriptivos
- Nombres de variables claros
```

### **HTML/CSS**
```html
<!-- Convenciones: -->
- Estructura semántica
- Clases CSS descriptivas
- Responsive design
- Accesibilidad básica
```

---

*Documentación técnica del código - RICOH España 2025*
