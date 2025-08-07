# RICOH España - Script para desplegar versión con GPT-OSS
# Despliega la aplicación con soporte para modelos locales de IA

Write-Host "🚀 Desplegando aplicación con GPT-OSS Local..." -ForegroundColor Green

# Verificar que estamos en la rama correcta
$currentBranch = git branch --show-current
if ($currentBranch -ne "gpt-oss-local") {
    Write-Host "⚠️ No estás en la rama gpt-oss-local. Cambiando..." -ForegroundColor Yellow
    git checkout gpt-oss-local
}

# Configurar entorno de Minikube
Write-Host "🔧 Configurando entorno Minikube..." -ForegroundColor Yellow
minikube docker-env | Invoke-Expression

# Construir imagen del backend con soporte para modelos locales
Write-Host "🏗️ Construyendo imagen del backend con GPT-OSS..." -ForegroundColor Yellow
cd medical-service-advanced
docker build -t backend-ricoh:gpt-oss .
cd ..

# Construir imagen del frontend
Write-Host "🏗️ Construyendo imagen del frontend..." -ForegroundColor Yellow
cd frontend-app
docker build -t frontend-ricoh:latest .
cd ..

# Aplicar configuraciones de Kubernetes
Write-Host "☸️ Aplicando configuraciones de Kubernetes..." -ForegroundColor Yellow
kubectl apply -f k8s/backend-ricoh-deployment.yaml -n medical-only
kubectl apply -f k8s/frontend-ricoh-deployment.yaml -n medical-only

# Reiniciar deployments para usar las nuevas imágenes
Write-Host "🔄 Reiniciando deployments..." -ForegroundColor Yellow
kubectl rollout restart deployment/backend-ricoh -n medical-only
kubectl rollout restart deployment/frontend-ricoh -n medical-only

# Esperar a que los pods estén listos
Write-Host "⏳ Esperando a que los pods estén listos..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=backend-ricoh -n medical-only --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend-ricoh -n medical-only --timeout=300s

# Configurar port forwarding
Write-Host "🔗 Configurando port forwarding..." -ForegroundColor Yellow
Start-Job -ScriptBlock { kubectl port-forward service/backend-ricoh-service 8091:80 -n medical-only }
Start-Job -ScriptBlock { kubectl port-forward service/frontend-ricoh-service 8081:80 -n medical-only }

# Verificar estado
Write-Host "📊 Verificando estado de los pods..." -ForegroundColor Yellow
kubectl get pods -n medical-only

Write-Host ""
Write-Host "🎉 ¡Despliegue completado!" -ForegroundColor Green
Write-Host "📋 Información del despliegue:" -ForegroundColor Cyan
Write-Host "   - Frontend: http://localhost:8081" -ForegroundColor White
Write-Host "   - Backend: http://localhost:8091" -ForegroundColor White
Write-Host "   - Health Check: http://localhost:8091/health" -ForegroundColor White
Write-Host "   - Status: http://localhost:8091/status" -ForegroundColor White

Write-Host ""
Write-Host "🔧 Comandos útiles:" -ForegroundColor Cyan
Write-Host "   - Ver logs del backend: kubectl logs deployment/backend-ricoh -n medical-only" -ForegroundColor White
Write-Host "   - Ver logs del frontend: kubectl logs deployment/frontend-ricoh -n medical-only" -ForegroundColor White
Write-Host "   - Verificar estado: kubectl get pods -n medical-only" -ForegroundColor White

Write-Host ""
Write-Host "💡 Para descargar GPT-OSS:" -ForegroundColor Yellow
Write-Host "   - Ejecutar: .\download-gpt-oss.ps1" -ForegroundColor White
Write-Host "   - Reiniciar backend después de descargar el modelo" -ForegroundColor White
