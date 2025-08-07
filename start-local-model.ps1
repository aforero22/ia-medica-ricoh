# RICOH España - Script para ejecutar servidor local del modelo
# Ejecuta el modelo de IA localmente en el host

Write-Host "Iniciando servidor local del modelo de IA..." -ForegroundColor Green

# Verificar que el modelo existe
$modelPath = "medical-service-advanced/models/llama2-7b-chat.gguf"
if (!(Test-Path $modelPath)) {
    Write-Host "Error: Modelo no encontrado en $modelPath" -ForegroundColor Red
    Write-Host "Ejecuta primero: .\download-alternative-model.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "Modelo encontrado: $modelPath" -ForegroundColor Green
$fileSize = (Get-Item $modelPath).Length / 1GB
Write-Host "Tamaño: $([math]::Round($fileSize, 2)) GB" -ForegroundColor Cyan

# Verificar dependencias
Write-Host "Verificando dependencias..." -ForegroundColor Yellow
try {
    python -c "import llama_cpp; import fastapi; import uvicorn" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Instalando dependencias..." -ForegroundColor Yellow
        pip install llama-cpp-python fastapi uvicorn
    }
} catch {
    Write-Host "Error verificando dependencias: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Dependencias verificadas" -ForegroundColor Green

# Iniciar servidor
Write-Host "Iniciando servidor en puerto 8080..." -ForegroundColor Yellow
Write-Host "El modelo estará disponible en: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Health check: http://localhost:8080/health" -ForegroundColor Cyan
Write-Host "Info: http://localhost:8080/info" -ForegroundColor Cyan
Write-Host ""
Write-Host "Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow

# Ejecutar servidor
python local-model-server.py
