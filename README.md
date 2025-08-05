# 🏥 **RICOH España - IA de Codificación Médica CIE-10-ES**

## 📋 **Descripción**

Sistema de **codificación médica automática** que utiliza **IA avanzada** para transformar diagnósticos en lenguaje natural a códigos **CIE-10-ES** oficiales del Ministerio de Sanidad español.

## 🎯 **Funcionalidades Principales**

### **Codificación Automática**
- ✅ **Análisis semántico** de diagnósticos médicos
- ✅ **Generación automática** de códigos CIE-10-ES
- ✅ **Diagnósticos principales y secundarios**
- ✅ **Justificaciones clínicas** detalladas

### **Ejemplos Clínicos**
- ✅ **50 casos médicos** predefinidos
- ✅ **Carga aleatoria** de ejemplos
- ✅ **Múltiples especialidades** cubiertas
- ✅ **Casos reales** de práctica clínica

### **Interfaz Moderna**
- ✅ **Diseño corporativo** RICOH España
- ✅ **Experiencia de usuario** optimizada
- ✅ **Notificaciones visuales** mejoradas
- ✅ **Responsive design** para todos los dispositivos

## 🏗️ **Arquitectura**

### **Frontend (Puerto 8081)**
```
- Interfaz web moderna con Tailwind CSS
- Formulario médico intuitivo
- Visualización de resultados estructurada
- Sistema de notificaciones en tiempo real
```

### **Backend (Puerto 8091)**
```
- API REST con FastAPI
- Motor de IA: OpenAI GPT-4 Turbo
- Base de datos: CIE-10-ES oficial
- Validaciones robustas de entrada
```

### **Infraestructura**
```
- Kubernetes con Minikube
- Docker containerización
- Load balancing automático
- Escalado horizontal (2 frontend, 3 backend)
```

## 🚀 **Inicio Rápido**

### **1. Iniciar la Aplicación**
```powershell
.\start-medical-only.ps1
```

### **2. Acceder a la Interfaz**
- **Frontend**: http://localhost:8081
- **Backend API**: http://localhost:8091

### **3. Detener la Aplicación**
```powershell
.\stop-medical-only.ps1
```

## 📊 **Casos de Uso**

### **Para Hospitales**
- **Automatización** de codificación médica
- **Reducción de errores** en clasificación
- **Ahorro de tiempo** para médicos
- **Cumplimiento normativo** CIE-10-ES

### **Para Demostraciones**
- **Showcase de IA médica**
- **Presentación a clientes** del sector salud
- **Validación de conceptos** de IA aplicada

## 🎮 **Cómo Usar**

### **1. Cargar Ejemplo Clínico**
- Hacer clic en "Cargar Ejemplo Clínico"
- Se carga automáticamente un caso médico aleatorio
- Los datos se rellenan en el formulario

### **2. Ingresar Diagnóstico**
- **Diagnóstico**: Texto en lenguaje natural
- **Edad del paciente**: Años (opcional)
- **Síntomas**: Lista separada por comas (opcional)

### **3. Procesar Codificación**
- Hacer clic en "Codificar CIE-10-ES"
- El sistema analiza con IA y genera códigos
- Se muestran resultados estructurados

## 🔧 **Configuración Técnica**

### **Requisitos**
- Docker Desktop
- Minikube
- PowerShell (Windows)

### **Variables de Entorno**
```bash
OPENAI_API_KEY=sk-proj-...
```

### **Puertos**
- **Frontend**: 8081
- **Backend**: 8091

## 📈 **Métricas de Rendimiento**

| Aspecto | Métrica |
|---------|---------|
| **Precisión CIE-10** | 85-98% |
| **Tiempo de respuesta** | 2-5 segundos |
| **Ejemplos disponibles** | 50 casos |
| **Cobertura médica** | 10+ especialidades |

## 🏥 **Especialidades Médicas Cubiertas**

- **Cardiología** - Infartos, hipertensión, insuficiencia cardíaca
- **Endocrinología** - Diabetes, trastornos tiroideos
- **Neurología** - Epilepsia, ACV, migrañas
- **Neumología** - EPOC, neumonía, asma
- **Gastroenterología** - Gastritis, hemorragias digestivas
- **Nefrología** - Enfermedad renal crónica
- **Reumatología** - Artrosis, artritis
- **Medicina general** - Fiebre, fatiga, malestar

## 🎯 **Comandos Útiles**

### **Ver Estado de Pods**
```powershell
kubectl get pods -n medical-only
```

### **Ver Logs del Backend**
```powershell
kubectl logs -f deployment/backend-ricoh -n medical-only
```

### **Ver Logs del Frontend**
```powershell
kubectl logs -f deployment/frontend-ricoh -n medical-only
```

### **Ver Métricas**
```powershell
kubectl top pods -n medical-only
```

## 🔍 **Troubleshooting**

### **Si los pods no arrancan**
```powershell
kubectl describe pod <nombre-pod> -n medical-only
```

### **Si el port forwarding falla**
```powershell
Get-Job | Stop-Job
.\start-medical-only.ps1
```

### **Si Minikube no responde**
```powershell
minikube delete
minikube start --cpus=4 --memory=8192 --driver=docker
```

## 📝 **Licencia**

**RICOH España** - Sistema de codificación médica con IA

---

**🏥 Transformando la codificación médica con inteligencia artificial** ✨ 