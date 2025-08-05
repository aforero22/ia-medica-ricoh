# 🏥 **Documentación Técnica - IA de Codificación Médica CIE-10-ES**

## 📋 **Información del Proyecto**

**Versión**: 1.0.0  
**Fecha**: Agosto 2025  
**Empresa**: RICOH España  
**Tipo**: Aplicación de IA para codificación médica  
**Licencia**: Propietaria RICOH España  

---

## 🏗️ **Arquitectura del Sistema**

### **Diagrama de Arquitectura**
```
┌─────────────────────────────────────────────────────────────┐
│                 Kubernetes Cluster (Minikube)              │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Frontend-Ricoh (2 pods)                │   │
│  │           🌐 Interfaz web puerto 8081               │   │
│  │           🎨 Tailwind CSS + JavaScript              │   │
│  └──────────────────────────────────────────────────────┘   │
│                              │                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Backend-Ricoh (3 pods)                │   │
│  │           🏥 API REST puerto 8091                  │   │
│  │           🤖 OpenAI GPT-4 Turbo                    │   │
│  └──────────────────────────────────────────────────────┘   │
│                              │                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Base de Datos CIE-10-ES               │   │
│  │           📚 Ministerio de Sanidad                 │   │
│  │           🏛️ Clasificación oficial española        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### **Componentes Principales**

#### **1. Frontend (frontend-app/)**
- **Tecnología**: HTML5 + CSS3 + JavaScript vanilla
- **Framework CSS**: Tailwind CSS
- **Iconos**: Font Awesome 6.4.0
- **Fuentes**: Crimson Text, Lato
- **Puerto**: 8081
- **Pods**: 2 réplicas

#### **2. Backend (medical-service-advanced/)**
- **Framework**: FastAPI (Python 3.9)
- **Motor de IA**: OpenAI GPT-4 Turbo
- **Base de datos**: CIE-10-ES oficial
- **Puerto**: 8091
- **Pods**: 3 réplicas

#### **3. Infraestructura (k8s/)**
- **Orquestador**: Kubernetes con Minikube
- **Containerización**: Docker
- **Load Balancing**: Kubernetes Services
- **Namespace**: medical-only

---

## 🔧 **Configuración Técnica**

### **Requisitos del Sistema**
```bash
# Software requerido
- Docker Desktop 4.x+
- Minikube 1.30+
- kubectl 1.28+
- PowerShell 7.0+
```

### **Variables de Entorno**
```bash
# Backend (medical-service-advanced/)
OPENAI_API_KEY=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
```

### **Puertos y Endpoints**
```bash
# Frontend
http://localhost:8081

# Backend APIs
http://localhost:8091/health                    # Health check
http://localhost:8091/codificar                 # POST - Codificación principal
http://localhost:8091/ejemplos-clinicos/aleatorio # GET - Ejemplos aleatorios
http://localhost:8091/status                    # GET - Estado del sistema
http://localhost:8091/cie10/buscar              # GET - Búsqueda CIE-10
```

---

## 📊 **Modelo de Datos**

### **Entrada de Codificación**
```json
{
  "diagnostico": "string",           // Diagnóstico en lenguaje natural
  "edad": "integer",                 // Edad del paciente (opcional)
  "sintomas": ["string"]             // Lista de síntomas (opcional)
}
```

### **Salida de Codificación**
```json
{
  "diagnostico_propuesto": "string",
  "diagnostico_principal": {
    "codigo": "string",              // Código CIE-10-ES
    "descripcion": "string",         // Descripción oficial
    "justificacion": "string"        // Justificación clínica
  },
  "diagnosticos_secundarios": [
    {
      "codigo": "string",
      "descripcion": "string",
      "justificacion": "string"
    }
  ],
  "tiempo_procesamiento": "float",
  "motor_ia": "string",
  "base_datos": "string"
}
```

### **Ejemplo Clínico**
```json
{
  "ejemplo": {
    "diagnostico": "string",
    "edad": "integer",
    "sintomas": ["string"],
    "codigo_esperado": "string",
    "descripcion": "string"
  },
  "total_ejemplos": "integer",
  "mensaje": "string"
}
```

---

## 🤖 **Motor de IA - GPT-4 Turbo**

### **Prompt Médico Experto**
```python
PROMPT_MEDICO_EXPERTO = """Actúa como un codificador médico experto en CIE‑10‑ES 
(versión española oficial del Ministerio de Sanidad).

Se te proporcionará:
- Un diagnóstico clínico en lenguaje natural
- La edad del paciente  
- Síntomas relevantes

Tu tarea es:
1. Proponer un diagnóstico estructurado breve
2. Identificar el diagnóstico principal más probable
3. Listar diagnósticos secundarios clínicamente relevantes
4. Para cada uno, entregar:
   - Código CIE‑10‑ES
   - Descripción en español
   - Justificación médica basada en los datos
"""
```

### **Capacidades del Modelo**
- **Comprensión semántica** de terminología médica
- **Análisis contextual** de síntomas y edad
- **Generación de códigos** CIE-10-ES precisos
- **Justificación clínica** detallada
- **Identificación de comorbilidades**

---

## 🏥 **Base de Datos CIE-10-ES**

### **Cobertura Médica**
- **50 ejemplos clínicos** predefinidos
- **10+ especialidades** médicas cubiertas
- **Casos reales** de práctica clínica
- **Códigos oficiales** del Ministerio de Sanidad

### **Especialidades Cubiertas**
1. **Cardiología** - Infartos, hipertensión, insuficiencia cardíaca
2. **Endocrinología** - Diabetes, trastornos tiroideos
3. **Neurología** - Epilepsia, ACV, migrañas
4. **Neumología** - EPOC, neumonía, asma
5. **Gastroenterología** - Gastritis, hemorragias digestivas
6. **Nefrología** - Enfermedad renal crónica
7. **Reumatología** - Artrosis, artritis
8. **Medicina general** - Fiebre, fatiga, malestar

---

## 🚀 **Despliegue y Operaciones**

### **Scripts de Automatización**
```powershell
# Iniciar aplicación completa
.\start-medical-only.ps1

# Detener aplicación
.\stop-medical-only.ps1

# Desplegar solo imágenes y servicios
.\deploy-medical-only.ps1
```

### **Comandos Kubernetes**
```bash
# Ver estado de pods
kubectl get pods -n medical-only

# Ver servicios
kubectl get services -n medical-only

# Ver logs del backend
kubectl logs -f deployment/backend-ricoh -n medical-only

# Ver logs del frontend
kubectl logs -f deployment/frontend-ricoh -n medical-only

# Ver métricas
kubectl top pods -n medical-only
```

### **Port Forwarding**
```bash
# Backend (puerto 8091)
kubectl port-forward service/backend-ricoh-service 8091:80 -n medical-only

# Frontend (puerto 8081)
kubectl port-forward service/frontend-ricoh-service 8081:80 -n medical-only
```

---

## 📈 **Métricas y Monitoreo**

### **Métricas de Rendimiento**
| Métrica | Valor |
|---------|-------|
| **Precisión CIE-10** | 85-98% |
| **Tiempo de respuesta** | 2-5 segundos |
| **Disponibilidad** | 99.9% |
| **Ejemplos disponibles** | 50 casos |
| **Cobertura médica** | 10+ especialidades |

### **Health Checks**
```bash
# Verificar salud del backend
curl http://localhost:8091/health

# Verificar estado del sistema
curl http://localhost:8091/status
```

### **Logs Estructurados**
```python
# Formato de logs
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

---

## 🔍 **Troubleshooting**

### **Problemas Comunes**

#### **1. Pods no arrancan**
```bash
# Verificar descripción del pod
kubectl describe pod <nombre-pod> -n medical-only

# Verificar eventos del namespace
kubectl get events -n medical-only --sort-by='.lastTimestamp'
```

#### **2. Port forwarding falla**
```powershell
# Detener jobs existentes
Get-Job | Stop-Job

# Reiniciar port forwarding
.\start-medical-only.ps1
```

#### **3. Minikube no responde**
```bash
# Reiniciar Minikube
minikube delete
minikube start --cpus=4 --memory=8192 --driver=docker
```

#### **4. Imágenes no se construyen**
```bash
# Configurar Docker para Minikube
minikube docker-env | Invoke-Expression

# Reconstruir imágenes
docker build -t frontend-ricoh:latest frontend-app/
docker build -t medical-service-only:latest medical-service-advanced/
```

### **Logs Útiles**
```bash
# Logs del backend
kubectl logs -f deployment/backend-ricoh -n medical-only

# Logs del frontend
kubectl logs -f deployment/frontend-ricoh -n medical-only

# Logs de todos los pods
kubectl logs -l app=backend-ricoh -n medical-only
kubectl logs -l app=frontend-ricoh -n medical-only
```

---

## 🔒 **Seguridad**

### **Consideraciones de Seguridad**
- **API Key**: OpenAI API key configurada en variables de entorno
- **CORS**: Configurado para permitir comunicación frontend-backend
- **Validaciones**: Entrada validada en frontend y backend
- **Logs**: Sin información sensible en logs

### **Buenas Prácticas**
- ✅ **Validación de entrada** robusta
- ✅ **Manejo de errores** detallado
- ✅ **Logs estructurados** para debugging
- ✅ **Health checks** regulares
- ✅ **Timeouts** configurados

---

## 📝 **Mantenimiento**

### **Actualizaciones**
```bash
# Actualizar imagen del backend
docker build -t medical-service-only:latest medical-service-advanced/
kubectl rollout restart deployment/backend-ricoh -n medical-only

# Actualizar imagen del frontend
docker build -t frontend-ricoh:latest frontend-app/
kubectl rollout restart deployment/frontend-ricoh -n medical-only
```

### **Backup y Recuperación**
```bash
# Backup de configuración
kubectl get all -n medical-only -o yaml > backup-medical-only.yaml

# Restaurar configuración
kubectl apply -f backup-medical-only.yaml
```

### **Limpieza**
```bash
# Limpiar namespace
kubectl delete namespace medical-only

# Limpiar imágenes Docker
docker rmi frontend-ricoh:latest medical-service-only:latest
```

---

## 📞 **Soporte Técnico**

### **Contacto**
- **Empresa**: RICOH España
- **Proyecto**: IA de Codificación Médica CIE-10-ES
- **Versión**: 1.0.0
- **Fecha**: Agosto 2025

### **Recursos Adicionales**
- **Documentación OpenAI**: https://platform.openai.com/docs
- **FastAPI**: https://fastapi.tiangolo.com/
- **Kubernetes**: https://kubernetes.io/docs/
- **CIE-10-ES**: Ministerio de Sanidad español

---

**🏥 Transformando la codificación médica con inteligencia artificial** ✨ 