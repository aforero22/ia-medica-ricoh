# Script de despliegue con HPA (Horizontal Pod Autoscaler)
# Sistema IA Médica CIE-10-ES con escalado automático

Write-Host "🚀 Desplegando sistema IA Médica con HPA..." -ForegroundColor Green

# Verificar que Minikube esté ejecutándose
Write-Host "Verificando Minikube..." -ForegroundColor Yellow
$minikubeStatus = minikube status --format=json | ConvertFrom-Json
if ($minikubeStatus.Host -ne "Running") {
    Write-Host "Minikube no está ejecutándose. Iniciando..." -ForegroundColor Red
    minikube start
} else {
    Write-Host "Minikube está ejecutándose" -ForegroundColor Green
}

# Crear namespace
Write-Host "Creando namespace medical-rag..." -ForegroundColor Yellow
kubectl create namespace medical-rag --dry-run=client -o yaml | kubectl apply -f -

# Crear secret para OpenAI API Key
Write-Host "Configurando secret de OpenAI..." -ForegroundColor Yellow
if (Test-Path "config.env") {
    $envContent = Get-Content "config.env"
    $apiKey = ($envContent | Where-Object { $_ -match "OPENAI_API_KEY=" }) -replace "OPENAI_API_KEY=", ""
    if ($apiKey) {
        kubectl create secret generic openai-secret --from-literal=api-key=$apiKey -n medical-rag --dry-run=client -o yaml | kubectl apply -f -
        Write-Host "Secret de OpenAI configurado" -ForegroundColor Green
    } else {
        Write-Host "No se encontró OPENAI_API_KEY en config.env" -ForegroundColor Yellow
    }
} else {
    Write-Host "Archivo config.env no encontrado. Creando secret vacío..." -ForegroundColor Yellow
    kubectl create secret generic openai-secret --from-literal=api-key="dummy-key" -n medical-rag --dry-run=client -o yaml | kubectl apply -f -
}

# Desplegar Backend con 3 réplicas iniciales
Write-Host "Desplegando Backend (3 réplicas iniciales)..." -ForegroundColor Yellow
kubectl apply -f backend-deployment-sintomas.yaml

# Desplegar Frontend con 2 réplicas iniciales
Write-Host "Desplegando Frontend (2 réplicas iniciales)..." -ForegroundColor Yellow
kubectl apply -f frontend-deployment-sintomas.yaml

# Esperar a que los deployments estén listos
Write-Host "Esperando a que los deployments estén listos..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/backend-rag-sintomas -n medical-rag
kubectl wait --for=condition=available --timeout=300s deployment/frontend-rag-sintomas -n medical-rag

# Aplicar HPA para Backend (3-10 réplicas)
Write-Host "Aplicando HPA para Backend (3-10 réplicas)..." -ForegroundColor Yellow
kubectl apply -f backend-hpa.yaml

# Aplicar HPA para Frontend (2-5 réplicas)
Write-Host "Aplicando HPA para Frontend (2-5 réplicas)..." -ForegroundColor Yellow
kubectl apply -f frontend-hpa.yaml

# Configurar port-forwarding
Write-Host "Configurando port-forwarding..." -ForegroundColor Yellow

# Backend en puerto 9999
Write-Host "Backend disponible en: http://localhost:9999" -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command", "kubectl port-forward -n medical-rag service/backend-rag-sintomas-service 9999:9999"

# Frontend en puerto 8083
Write-Host "Frontend disponible en: http://localhost:8083" -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command", "kubectl port-forward -n medical-rag service/frontend-rag-sintomas-service 8083:80"

# Mostrar estado
Write-Host "`n📊 Estado del sistema:" -ForegroundColor Cyan
kubectl get pods -n medical-rag
Write-Host "`n📈 Estado de HPA:" -ForegroundColor Cyan
kubectl get hpa -n medical-rag

Write-Host "`n✅ Sistema desplegado con HPA exitosamente!" -ForegroundColor Green
Write-Host "🎯 Configuración de escalado:" -ForegroundColor Yellow
Write-Host "   Backend: 3-10 réplicas (CPU >70% o Memoria >80%)" -ForegroundColor White
Write-Host "   Frontend: 2-5 réplicas (CPU >80% o Memoria >85%)" -ForegroundColor White

Write-Host "`n🔍 Comandos útiles:" -ForegroundColor Cyan
Write-Host "   Ver pods: kubectl get pods -n medical-rag" -ForegroundColor White
Write-Host "   Ver HPA: kubectl get hpa -n medical-rag" -ForegroundColor White
Write-Host "   Ver logs: kubectl logs -f deployment/backend-rag-sintomas -n medical-rag" -ForegroundColor White
Write-Host "   Escalar manual: kubectl scale deployment backend-rag-sintomas --replicas=5 -n medical-rag" -ForegroundColor White
