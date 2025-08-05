# Script específico para la rama medical-coding-only
# Configura frontend en puerto 8081 y backend en puerto 8091

Write-Host "🏥 Iniciando Demo Medical-Only (CIE-10)" -ForegroundColor Green
Write-Host "Frontend: puerto 8081 | Backend: puerto 8091" -ForegroundColor Cyan

# Función para detener procesos kubectl existentes
function Stop-KubectlProcesses {
    Write-Host "🛑 Deteniendo procesos kubectl existentes..." -ForegroundColor Yellow
    Get-Process -Name "kubectl" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Función para verificar si un puerto está en uso
function Test-Port {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("localhost", $Port)
        $connection.Close()
        return $true
    } catch {
        return $false
    }
}

# Verificar que Minikube esté ejecutándose
Write-Host "🔍 Verificando Minikube..." -ForegroundColor Blue
try {
    $minikubeStatus = kubectl cluster-info 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Minikube no está ejecutándose. Iniciando..." -ForegroundColor Red
        minikube start --cpus=4 --memory=8192 --driver=docker
    } else {
        Write-Host "✅ Minikube está ejecutándose" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Error al verificar Minikube: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Configurar Docker para Minikube
Write-Host "🐳 Configurando Docker para Minikube..." -ForegroundColor Blue
minikube docker-env | Invoke-Expression

# Crear namespace medical-only si no existe
Write-Host "📁 Creando namespace medical-only..." -ForegroundColor Blue
kubectl create namespace medical-only --dry-run=client -o yaml | kubectl apply -f -

# Construir imágenes Docker
Write-Host "🔨 Construyendo imágenes Docker..." -ForegroundColor Blue

# Construir backend medical-service-advanced
Write-Host "  🏥 Construyendo medical-service-advanced..." -ForegroundColor Cyan
Set-Location medical-service-advanced
docker build -t medical-service-only:latest .
Set-Location ..

# Construir frontend
Write-Host "  🌐 Construyendo frontend..." -ForegroundColor Cyan
Set-Location frontend-app
docker build -t frontend-ricoh:latest .
Set-Location ..

# Desplegar servicios en Kubernetes (namespace medical-only)
Write-Host "☸️ Desplegando servicios en Kubernetes (namespace medical-only)..." -ForegroundColor Blue
kubectl apply -f k8s/

# Esperar a que los pods estén listos
Write-Host "⏳ Esperando a que los pods estén listos..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=medical-service-only -n medical-only --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend-medical -n medical-only --timeout=300s

# Detener procesos kubectl existentes antes de configurar port forwarding
Stop-KubectlProcesses

# Configurar port forwarding específico para medical-only
Write-Host "🔗 Configurando port forwarding..." -ForegroundColor Blue

# Port forwarding para backend en puerto 8091
Write-Host "  🏥 Medical Service - Backend (puerto 8091)..." -ForegroundColor Cyan
Start-Job -ScriptBlock { kubectl port-forward service/medical-service-only-service 8091:80 -n medical-only } | Out-Null

# Port forwarding para frontend en puerto 8081
Write-Host "  🌐 Frontend Service - Interfaz web (puerto 8081)..." -ForegroundColor Cyan
Start-Job -ScriptBlock { kubectl port-forward service/frontend-medical-service 8081:80 -n medical-only } | Out-Null

# Esperar a que los port forwarding estén listos
Write-Host "⏳ Esperando a que los port forwarding estén listos..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verificar conectividad de los servicios
Write-Host "🔧 Verificando conectividad de servicios..." -ForegroundColor Blue

$maxRetries = 10
$retryCount = 0

do {
    $allServicesReady = $true
    
    # Verificar cada servicio
    foreach ($port in @(8081, 8091)) {
        if (-not (Test-Port $port)) {
            $allServicesReady = $false
            break
        }
    }
    
    if (-not $allServicesReady) {
        $retryCount++
        Write-Host "  ⏳ Intentando conectar... ($retryCount/$maxRetries)" -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    }
} while (-not $allServicesReady -and $retryCount -lt $maxRetries)

if ($allServicesReady) {
    # Verificar health de los servicios
    Write-Host "🩺 Verificando health de servicios..." -ForegroundColor Blue
    
    try {
        $medicalHealth = Invoke-RestMethod -Uri "http://localhost:8091/health" -TimeoutSec 5
        Write-Host "  ✅ Medical Service: $($medicalHealth.status)" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️ Medical Service: No responde" -ForegroundColor Yellow
    }
    
    # Abrir frontend en el navegador
    Write-Host "🌐 Abriendo frontend en el navegador..." -ForegroundColor Green
    Start-Process "http://localhost:8081"
    
    # Mostrar estado del despliegue
    Write-Host ""
    Write-Host "📊 Estado del despliegue (namespace medical-only):" -ForegroundColor Cyan
    kubectl get pods,services -n medical-only
    
    Write-Host ""
    Write-Host "✅ ¡Demo Medical-Only iniciada exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Servicios disponibles:" -ForegroundColor Cyan
    Write-Host "  🎯 Frontend (Codificación CIE-10): http://localhost:8081" -ForegroundColor White
    Write-Host "  🏥 Medical Service (Backend): http://localhost:8091" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 Funcionalidades:" -ForegroundColor Cyan
    Write-Host "  • Interfaz médica con colores Ricoh España" -ForegroundColor White
    Write-Host "  • Codificación automática CIE-10-ES" -ForegroundColor White
    Write-Host "  • Ejemplos clínicos aleatorios" -ForegroundColor White
    Write-Host "  • Análisis semántico médico avanzado" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 Comandos útiles:" -ForegroundColor Cyan
    Write-Host "  Ver pods:        kubectl get pods -n medical-only" -ForegroundColor White
    Write-Host "  Ver logs:        kubectl logs -f deployment/medical-service-only -n medical-only" -ForegroundColor White
    Write-Host "  Ver métricas:    kubectl top pods -n medical-only" -ForegroundColor White
    Write-Host "  Detener demo:    .\stop-medical-only.ps1" -ForegroundColor White
    
} else {
    Write-Host "❌ Error: No se pudieron configurar todos los port forwarding" -ForegroundColor Red
    Write-Host "Verifica que Minikube esté funcionando correctamente" -ForegroundColor Yellow
} 