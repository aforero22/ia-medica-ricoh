# 🚀 Inicio Rápido - Demo Kubernetes para IA Moderna

## ⚡ Reinicio después de reiniciar tu máquina

> **🆕 Versión 2.1 actualizada** con modelos modernos de IA y mejoras UX

### Opción 1: Script Automático (Recomendado)
```powershell
# Desde PowerShell, en la carpeta demo-ia
.\start-demo.ps1
```

### Opción 2: Manual (Si hay problemas)
```powershell
# 1. Iniciar Minikube
minikube start --cpus=4 --memory=8192 --driver=docker

# 2. Configurar Docker
minikube docker-env | Invoke-Expression

# 3. Construir imágenes (solo si cambiaste código)
docker build -t fraud-service:latest fraud-service/
docker build -t medical-service:latest medical-service/

docker build -t frontend-app:latest frontend-app/

# 4. Desplegar servicios
kubectl apply -f k8s/

# 5. Configurar port forwarding (en ventanas separadas)
kubectl port-forward service/fraud-service 8001:80
kubectl port-forward service/medical-service 8002:80

kubectl port-forward service/frontend-service 8080:80

# 6. Abrir navegador
start http://localhost:8080
```

## 📱 URLs de la Demo

- **Frontend**: http://localhost:8080
- **Fraud Service**: http://localhost:8001
- **Medical Service**: http://localhost:8002


## 🛑 Detener Demo

```powershell
.\stop-demo.ps1
```

## 🔧 Resolución de Problemas

### Si Minikube no arranca:
```powershell
minikube delete
minikube start --cpus=4 --memory=8192 --driver=docker
```

### Si los pods no arrancan:
```powershell
kubectl get pods
kubectl describe pod <nombre-del-pod>
kubectl logs <nombre-del-pod>
```

### Si el port forwarding falla:
```powershell
# Matar procesos kubectl
taskkill /f /im kubectl.exe

# Reiniciar port forwarding
.\start-demo.ps1
```

### Si hay problemas de permisos:
```powershell
# Habilitar ejecución de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📊 Comandos Útiles

```powershell
# Ver estado de pods
kubectl get pods

# Ver métricas de CPU/Memoria
kubectl top pods

# Ver logs en tiempo real
kubectl logs -f deployment/fraud-service

# Ver eventos del cluster
kubectl get events --sort-by='.lastTimestamp'

# Verificar health de servicios
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health

# Verificar estado completo
.\test-services.sh
```

## 🎯 Flujo de Trabajo Típico

1. **Después de reiniciar**: `.\start-demo.ps1`
2. **Trabajar con la demo**: Usar http://localhost:8080
3. **Detener al final del día**: `.\stop-demo.ps1`
4. **Al día siguiente**: `.\start-demo.ps1` (más rápido porque ya está todo configurado)

## 🆕 Nuevas Características v2.1

### **Mejoras UX/UI**
- ✅ Notificaciones visuales en lugar de alerts
- ✅ Mejor feedback de estados de carga
- ✅ Manejo de errores más informativo

### **Validaciones Robustas**
- ✅ Validación de longitud de texto
- ✅ Validación de rangos de edad
- ✅ Validación de montos de transacción
- ✅ Mensajes de error más claros

### **Logging Mejorado**
- ✅ Formato de logs estructurado
- ✅ Información detallada de errores
- ✅ Traceback completo para debugging

### **Script de Verificación**
- ✅ `.\test-services.sh` para verificar estado completo
- ✅ Verificación automática de todos los servicios
- ✅ Resumen visual del estado

---

**¡Con esto puedes usar la demo después de cualquier reinicio! 🎉**