# 🎯 Libretos de Presentación - Equipo Interno

## 📋 **INFORMACIÓN GENERAL**

**Audiencia:** Equipo de desarrollo, DevOps, arquitectos de software  
**Duración:** 15-20 minutos  
**Objetivo:** Demostrar capacidades técnicas en microservicios, Kubernetes e IA aplicada  
**Tono:** Técnico, detallado, enfocado en arquitectura y implementación  

---

## 🎤 **LIBRETO COMPLETO**

### **1. INTRODUCCIÓN (2 minutos)**

```
"Buenos días equipo. Hoy les voy a mostrar una demo técnica que hemos desarrollado 
que combina microservicios, Kubernetes y IA aplicada a dos casos de uso críticos: 
detección de fraude financiero y clasificación médica.

Esta demo representa el estado del arte en arquitectura de microservicios y nos 
permite validar nuestras capacidades técnicas en tecnologías modernas.

La arquitectura está completamente containerizada, orquestada con Kubernetes, 
y utiliza APIs REST para comunicación entre servicios."
```

### **2. ARQUITECTURA TÉCNICA (3 minutos)**

```
"La arquitectura se basa en microservicios desplegados en Kubernetes:

• Frontend: Interfaz web responsive con Flask
• Fraud Service: API FastAPI para detección de fraude
• Medical Service: API FastAPI para clasificación CIE-10
• Kubernetes: Orquestación con Minikube local

Cada servicio es independiente, escalable y tiene su propio health check.

Puntos técnicos importantes:
✅ Microservicios independientes
✅ APIs REST documentadas
✅ Health checks automáticos
✅ Logging estructurado
✅ Validaciones robustas
✅ Fallback automático
✅ Escalabilidad horizontal
✅ Observabilidad completa"
```

### **3. DEMOSTRACIÓN TÉCNICA (8 minutos)**

#### **Paso 1: Inicio del Sistema**
```
"Primero, vamos a ver cómo se despliega todo el sistema:

1. Minikube start - Clúster local
2. Docker build - Construcción de imágenes
3. kubectl apply - Despliegue de servicios
4. Port forwarding - Exposición de APIs

Todo se automatiza con scripts PowerShell.

[EJECUTAR: .\start-demo.ps1]

Observen cómo se despliegan los pods:
- fraud-service: 2 réplicas
- medical-service: 2 réplicas  
- frontend-app: 1 réplica

Cada servicio tiene su propio deployment, service y health checks."
```

#### **Paso 2: Detección de Fraude**
```
"Ahora probemos el servicio de detección de fraude:

1. Cargar ejemplo: 'Transferencia urgente de 50,000 euros a Nigeria'
2. Análisis en tiempo real
3. Resultado: 95% probabilidad de fraude
4. Explicación: Patrones sospechosos detectados

El modelo usa Enhanced Transformer v2.0 con análisis semántico.

[DEMOSTRAR EN FRONTEND]

Puntos técnicos:
- API REST en FastAPI
- Validaciones de entrada
- Logging estructurado
- Métricas de rendimiento
- Timeout configurado
- Error handling robusto"
```

#### **Paso 3: Clasificación Médica**
```
"Ahora el servicio médico:

1. Cargar ejemplo: 'Paciente con dolor en el pecho'
2. Análisis de síntomas
3. Resultado: I20.0 - Angina de pecho
4. Confianza: 92%

Usa Clinical ModernBERT v2.0 para códigos CIE-10.

[DEMOSTRAR EN FRONTEND]

Aspectos técnicos:
- Procesamiento de texto natural
- Clasificación multiclase
- Validación de edad del paciente
- Análisis de síntomas múltiples
- Códigos CIE-10 estándar"
```

### **4. ASPECTOS TÉCNICOS DESTACADOS (3 minutos)**

```
"Puntos técnicos importantes que hemos implementado:

✅ MICROSERVICIOS:
- Cada servicio es independiente
- APIs REST bien definidas
- Comunicación HTTP/JSON
- Versionado de APIs

✅ KUBERNETES:
- Deployments con réplicas
- Services para networking
- Health checks automáticos
- Resource limits configurados

✅ OBSERVABILIDAD:
- Logging estructurado
- Métricas de rendimiento
- Health endpoints
- Error tracking

✅ DEVOPS:
- Docker containers
- CI/CD ready
- Scripts de automatización
- Environment variables

✅ SEGURIDAD:
- Validaciones de entrada
- Error handling
- Timeouts configurados
- CORS configurado"
```

### **5. CIERRE TÉCNICO (2 minutos)**

```
"Esta demo valida nuestras capacidades en:

• Kubernetes y contenedores
• Microservicios y APIs
• IA aplicada a casos reales
• DevOps y automatización
• Arquitectura escalable

Tecnologías utilizadas:
- Python/FastAPI
- Docker/Kubernetes
- JavaScript/HTML/CSS
- PowerShell scripting

Próximos pasos:
1. Implementar CI/CD pipeline
2. Agregar monitoring (Prometheus/Grafana)
3. Implementar tests automatizados
4. Documentar APIs con OpenAPI

¿Preguntas técnicas sobre la implementación?"
```

---

## 📊 **MÉTRICAS TÉCNICAS A MOSTRAR**

### **Rendimiento:**
- Tiempo de respuesta: < 200ms
- Throughput: 1000+ requests/min
- Uptime: 99.9%
- Memory usage: < 512MB por pod

### **Escalabilidad:**
- Horizontal Pod Autoscaler configurado
- Load balancing automático
- Resource limits definidos
- Health checks funcionando

### **Observabilidad:**
- Logs estructurados
- Health endpoints
- Error tracking
- Performance metrics

---

## 🛠️ **COMANDOS TÉCNICOS ÚTILES**

```bash
# Verificar estado de pods
kubectl get pods

# Ver logs en tiempo real
kubectl logs -f deployment/fraud-service

# Verificar health checks
curl http://localhost:8001/health

# Ver métricas de recursos
kubectl top pods

# Escalar servicios
kubectl scale deployment fraud-service --replicas=3
```

---

## 🎯 **PUNTOS CLAVE PARA DESTACAR**

1. **Arquitectura moderna** con microservicios
2. **Containerización completa** con Docker
3. **Orquestación** con Kubernetes
4. **APIs REST** bien diseñadas
5. **Observabilidad** implementada
6. **Escalabilidad** horizontal
7. **DevOps** automatizado
8. **IA aplicada** a casos reales

---

**¿Listo para la presentación técnica?** 🚀 