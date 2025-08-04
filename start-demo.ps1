# Codificación Médica CIE-10 - Script de Inicio (PowerShell)
# ✨ Versión enfocada en clasificación médica con colores Ricoh España
# Este script inicia Minikube, despliega el servicio médico y configura port forwarding

Write-Host "🚀 Iniciando Demo Kubernetes para IA..." -ForegroundColor Green

# Función para verificar si un puerto está en uso
function Test-Port {
    param($Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient("127.0.0.1", $Port)
        $connection.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Función para matar procesos kubectl existentes
function Stop-KubectlProcesses {
    Write-Host "🛑 Deteniendo procesos kubectl existentes..." -ForegroundColor Yellow
    try {
        Get-Process -Name "kubectl" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 2
    }
    catch {
        # No hay procesos kubectl corriendo
    }
}

# Función para verificar dependencias
function Test-Dependencies {
    Write-Host "🔍 Verificando dependencias..." -ForegroundColor Blue
    
    $dependencies = @("minikube", "kubectl", "docker")
    $missing = @()
    
    foreach ($dep in $dependencies) {
        try {
            $null = Get-Command $dep -ErrorAction Stop
            Write-Host "  ✅ $dep encontrado" -ForegroundColor Green
        }
        catch {
            Write-Host "  ❌ $dep no encontrado" -ForegroundColor Red
            $missing += $dep
        }
    }
    
    if ($missing.Count -gt 0) {
        Write-Host "❌ Dependencias faltantes: $($missing -join ', ')" -ForegroundColor Red
        Write-Host "Por favor instala las dependencias faltantes antes de continuar" -ForegroundColor Yellow
        exit 1
    }
}

# Verificar dependencias primero
Test-Dependencies

# Verificar que Minikube esté corriendo
Write-Host "📋 Verificando Minikube..." -ForegroundColor Blue
$minikubeStatus = minikube status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Minikube no está corriendo. Iniciando..." -ForegroundColor Red
    minikube start --cpus=4 --memory=8192 --driver=docker
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al iniciar Minikube" -ForegroundColor Red
        Write-Host "Verifica que Docker esté corriendo y que tengas permisos suficientes" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✅ Minikube está corriendo" -ForegroundColor Green
}

# Configurar Docker para usar el daemon de Minikube
Write-Host "🐳 Configurando Docker para Minikube..." -ForegroundColor Blue
minikube docker-env | Invoke-Expression

# Verificar si los servicios ya están desplegados
Write-Host "🔍 Verificando servicios existentes..." -ForegroundColor Blue
$existingPods = kubectl get pods --no-headers 2>$null
if ($LASTEXITCODE -eq 0 -and $existingPods) {
    Write-Host "✅ Servicios ya están desplegados" -ForegroundColor Green
} else {
    Write-Host "📦 Desplegando servicios..." -ForegroundColor Blue
    
    # Construir imágenes Docker
    Write-Host "🔨 Construyendo imágenes Docker..." -ForegroundColor Blue
    
    Set-Location fraud-service
    docker build -t fraud-service:latest .
    Set-Location ..
    
    Set-Location medical-service
    docker build -t medical-service:latest .
    Set-Location ..
    
    
    
    Set-Location frontend-app
    docker build -t frontend-app:latest .
    Set-Location ..
    
    # Desplegar servicios en Kubernetes (namespace medical-only)
    Write-Host "☸️ Desplegando servicios en Kubernetes (namespace medical-only)..." -ForegroundColor Blue
    kubectl apply -f k8s/
    
    # Esperar a que los pods estén listos
    Write-Host "⏳ Esperando a que los pods estén listos..." -ForegroundColor Yellow
    kubectl wait --for=condition=ready pod -l app=medical-service -n medical-only --timeout=300s
    
}

# Detener procesos kubectl existentes antes de configurar port forwarding
Stop-KubectlProcesses

# Configurar port forwarding
Write-Host "🔗 Configurando port forwarding..." -ForegroundColor Blue

# Port forwarding para los servicios backend
Write-Host "  🏥 Medical Service - Clinical ModernBERT v2.0 (puerto 8002)..." -ForegroundColor Cyan
Start-Job -ScriptBlock { kubectl port-forward service/medical-service 8002:80 } | Out-Null

Write-Host "  🌐 Frontend Service - Interfaz web moderna (puerto 8080)..." -ForegroundColor Cyan
Start-Job -ScriptBlock { kubectl port-forward service/frontend-service 8080:80 } | Out-Null

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
    foreach ($port in @(8002)) {
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
        $medicalHealth = Invoke-RestMethod -Uri "http://localhost:8002/health" -TimeoutSec 5
        Write-Host "  ✅ Medical Service: $($medicalHealth.status)" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️ Medical Service: No responde" -ForegroundColor Yellow
    }
    
    # Abrir frontend en el navegador
    Write-Host "🌐 Abriendo frontend en el navegador..." -ForegroundColor Green
    Start-Process "http://localhost:8080"
    
    # Mostrar estado del despliegue
    Write-Host ""
    Write-Host "📊 Estado del despliegue (namespace medical-only):" -ForegroundColor Cyan
    kubectl get pods,services,hpa -n medical-only
    
    Write-Host ""
    Write-Host "✅ ¡Demo de IA Moderna iniciada exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Servicios disponibles:" -ForegroundColor Cyan
    Write-Host "  🎯 Frontend (Codificación Médica): http://localhost:8080" -ForegroundColor White
    Write-Host "  🏥 Medical Service (Clinical ModernBERT v2.0): http://localhost:8002" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 Funcionalidades nuevas:" -ForegroundColor Cyan
    Write-Host "  • Interfaz médica con colores Ricoh España" -ForegroundColor White
    Write-Host "  • Clasificación automática CIE-10" -ForegroundColor White
    Write-Host "  • Modelo Clinical ModernBERT v2.0" -ForegroundColor White
    Write-Host "  • Análisis semántico médico avanzado" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 Comandos útiles:" -ForegroundColor Cyan
    Write-Host "  Ver pods:        kubectl get pods -n medical-only" -ForegroundColor White
    Write-Host "  Ver logs:        kubectl logs -f deployment/medical-service -n medical-only" -ForegroundColor White
    Write-Host "  Ver métricas:    kubectl top pods -n medical-only" -ForegroundColor White
    Write-Host "  Detener demo:    .\stop-demo.ps1" -ForegroundColor White
    
} else {
    Write-Host "❌ Error: No se pudieron configurar todos los port forwarding" -ForegroundColor Red
    Write-Host "Verifica que Minikube esté funcionando correctamente" -ForegroundColor Yellow
}