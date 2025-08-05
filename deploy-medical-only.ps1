# Script simple para regenerar imágenes y hacer deployments

Write-Host "🏥 Regenerando imágenes y haciendo deployments..." -ForegroundColor Green

# Configurar Docker para Minikube
Write-Host "🐳 Configurando Docker..." -ForegroundColor Blue
minikube docker-env | Invoke-Expression

# Crear namespace
Write-Host "📁 Creando namespace..." -ForegroundColor Blue
kubectl create namespace medical-only --dry-run=client -o yaml | kubectl apply -f -

# Construir backend
Write-Host "🔨 Construyendo backend..." -ForegroundColor Cyan
cd medical-service-advanced
docker build -t medical-service-only:latest .
cd ..

# Construir frontend
Write-Host "🔨 Construyendo frontend..." -ForegroundColor Cyan
cd frontend-app
docker build -t frontend-ricoh:latest .
cd ..

# Desplegar
Write-Host "☸️ Desplegando servicios..." -ForegroundColor Blue
kubectl apply -f k8s/

# Esperar pods
Write-Host "⏳ Esperando pods..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=medical-service-only -n medical-only --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend-medical -n medical-only --timeout=300s

# Port forwarding
Write-Host "🔗 Configurando port forwarding..." -ForegroundColor Blue
Start-Job -ScriptBlock { kubectl port-forward service/medical-service-only-service 8091:80 -n medical-only }
Start-Job -ScriptBlock { kubectl port-forward service/frontend-medical-service 8081:80 -n medical-only }

Write-Host "✅ ¡Deployment completado!" -ForegroundColor Green
Write-Host "🌐 Frontend: http://localhost:8081" -ForegroundColor White
Write-Host "🏥 Backend: http://localhost:8091" -ForegroundColor White 