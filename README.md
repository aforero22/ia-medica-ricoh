# 🏥 Codificación Médica CIE-10 - Demo Kubernetes

## 📋 **Descripción**

Sistema de codificación automática de diagnósticos médicos según la Clasificación Internacional de Enfermedades (CIE-10) desplegado en Kubernetes (Minikube):

- 🏥 **Codificación Médica CIE-10**: Clasificación automática de diagnósticos médicos con IA

## 🎯 **Características (v2.1)**

- ✅ **Microservicio Médico**: Arquitectura distribuida con Kubernetes
- ✅ **API REST**: FastAPI para servicio backend médico
- ✅ **Frontend Médico**: Interfaz web con colores Ricoh España
- ✅ **Ejemplos Interactivos**: Carga automática de casos médicos de prueba
- ✅ **Notificaciones Visuales**: Feedback no bloqueante para el usuario
- ✅ **Validaciones Robustas**: Verificación de entrada en el servicio médico
- ✅ **Logging Mejorado**: Observabilidad completa del sistema
- ✅ **Health Checks**: Verificación automática de salud del servicio
- ✅ **Script de Verificación**: `test-services.sh` para validación completa

## 🏗️ Arquitectura Médica
```
┌─────────────────────────────────────────────────────────────┐
│                 Kubernetes Cluster (Minikube)              │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Frontend Médico                         │   │
│  │           🌐 Interfaz con colores Ricoh             │   │
│  │               (puerto 8080)                          │   │
│  └──────────────────────────────────────────────────────┘   │
│                              │                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              🏥 Medical Service                     │   │
│  │           Clinical ModernBERT v2.0                  │   │
│  │              (puerto 8002)                          │   │
│  └──────────────────────────────────────────────────────┘   │
│                              │                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Auto-Scaling (HPA)                     │   │
│  │           Escalado automático                       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Setup Rápido (15 minutos)

### 1. Prerrequisitos
```bash
# Instalar Minikube
minikube start --cpus=4 --memory=8192 --driver=docker

# Verificar que funciona
kubectl get nodes
```

### 2. Desplegar la Demo (Namespace medical-only)
```powershell
# Construir y desplegar todo en namespace medical-only
.\start-demo.ps1

# Verificar servicios en el namespace
kubectl get pods,services,hpa -n medical-only
```

### 3. Probar el Servicio Médico
```powershell
# Obtener URL del servicio médico
minikube service medical-service -n medical-only --url

# Verificar estado completo
kubectl get pods,services,hpa -n medical-only
```

### 4. Monitoreo
```powershell
# Ver métricas en tiempo real
kubectl top pods -n medical-only

# Ver logs del servicio médico
kubectl logs -f deployment/medical-service -n medical-only
```
```

## 📊 Caso de Uso Médico

### 🏥 Codificación Médica CIE-10 Avanzada
- **Modelo**: `Clinical ModernBERT v2.0` (entrenado en literatura médica)
- **Características**:
  - Base de conocimiento expandida (10+ categorías médicas)
  - Factores demográficos integrados (edad, síntomas)
  - Códigos alternativos ordenados por relevancia
- **Entrada**: Diagnóstico + edad + síntomas
- **Salida**: `{"icd10_code": "I21.9", "confidence": 0.94, "category": "cardiovascular", "alternatives": [...]}`



## 🔧 Componentes Técnicos

### Microservicio Médico
- **FastAPI** con modelo Clinical ModernBERT
- **Docker** container optimizado
- **Health checks** y **readiness probes**
- **Logging** estructurado mejorado

### Kubernetes
- **Deployment** con múltiples réplicas
- **Service** tipo LoadBalancer
- **HPA** (Horizontal Pod Autoscaler) basado en CPU
- **ConfigMaps** para configuración
- **Rolling updates** sin downtime

### Monitoreo
- **kubectl top pods** para métricas de recursos
- **K9s** para interfaz visual
- **Prometheus + Grafana** (opcional)

## 📈 Escalabilidad Automática

### Configuración HPA para Servicio Médico
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🔄 Rolling Updates

### Actualización de Modelo Médico en Caliente
```powershell
# Actualizar imagen del modelo médico
kubectl set image deployment/medical-service medical-service=myapp:v2 -n medical-only

# Ver progreso
kubectl rollout status deployment/medical-service -n medical-only

# Rollback si es necesario
kubectl rollout undo deployment/medical-service -n medical-only
```

## 🎤 Guión para la Presentación

### 1. Introducción (2 min)
- "Kubernetes no es solo para aplicaciones web"
- "Es la plataforma ideal para IA/ML en producción"
- "Hoy veremos un servicio de codificación médica con IA"

### 2. Arquitectura (3 min)
- Mostrar diagrama de arquitectura médica
- Explicar microservicio médico
- "El servicio puede escalar automáticamente según la carga"

### 3. Demo en Vivo (8 min)
- Desplegar servicio médico
- Mostrar autoescalado con carga
- Actualizar modelo en caliente
- Mostrar métricas de monitoreo

### 4. Valor de Kubernetes (2 min)
- **Portabilidad**: Funciona igual en laptop que en cloud
- **Escalabilidad**: Auto-scaling automático
- **Resiliencia**: Auto-healing y rolling updates
- **Observabilidad**: Métricas y logs centralizados

## 🛠️ Troubleshooting

### Problemas Comunes
```powershell
# Si Minikube no arranca
minikube delete && minikube start

# Si los pods no arrancan
kubectl describe pod <pod-name> -n medical-only

# Si el servicio no es accesible
kubectl get endpoints -n medical-only
```

### Logs Útiles
```powershell
# Ver logs del servicio médico
kubectl logs -l app=medical-service -n medical-only

# Ver eventos del namespace
kubectl get events --sort-by='.lastTimestamp' -n medical-only
```

### Limpieza del Namespace
```powershell
# Limpiar recursos del namespace
.\cleanup-medical.ps1

# Eliminar completamente el namespace
kubectl delete namespace medical-only
```

## 📁 **Estructura del Proyecto**

```
demo-ia/
├── 📄 README.md                    # Documentación principal
├── 📄 MEJORAS-IMPLEMENTADAS.md     # Detalles de mejoras v2.1
├── 📄 ESTADO-ACTUAL.md             # Estado actual del proyecto
├── 📄 MODELOS-ACTUALIZADOS.md      # Información de modelos IA
├── 📄 INICIO-RAPIDO.md             # Guía de inicio rápido
├── 📄 LIMPIEZA-PROYECTO.md         # Documentación de limpieza
├── 📄 start-demo.ps1               # Script principal de inicio
├── 📄 stop-demo.ps1                # Script de parada
├── 📄 test-services.sh             # Verificación de salud
│
├── 🏥 medical-service/             # Servicio de clasificación médica
│   ├── app.py                      # API FastAPI
│   └── Dockerfile                  # Configuración Docker
│
├── 🌐 frontend-app/                # Aplicación frontend médico
│   ├── index.html                  # Interfaz web con colores Ricoh
│   ├── server.py                   # Servidor Flask
│   └── Dockerfile                  # Configuración Docker
│
└── ☸️ k8s/                         # Configuraciones Kubernetes
    ├── medical-deployment.yaml     # Deployment medical service
    └── frontend-deployment.yaml    # Deployment frontend
```

## 🎯 KPIs de la Demo Médica
- ✅ **Tiempo de setup**: < 5 minutos
- ✅ **Tiempo de respuesta**: < 200ms por clasificación
- ✅ **Auto-scaling**: 2 → 10 pods bajo carga
- ✅ **Zero-downtime**: Rolling updates sin interrupciones
- ✅ **Observabilidad**: Métricas en tiempo real
- ✅ **Precisión médica**: 85-98% confianza
- ✅ **Validaciones**: Robustas y informativas

## 🚀 URLs de Acceso

- **Frontend Médico**: http://localhost:8080
- **Medical Service**: http://localhost:8002


---

**¡Listo para demostrar la codificación médica con el poder de Kubernetes para IA! 🏥** 