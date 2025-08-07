# RICOH España - Script para probar el servidor local del modelo

Write-Host "Probando servidor local del modelo..." -ForegroundColor Green

# Verificar que el servidor esté corriendo
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method Get -TimeoutSec 5
    Write-Host "✅ Servidor local está funcionando" -ForegroundColor Green
    Write-Host "Estado: $($response.status)" -ForegroundColor Cyan
    Write-Host "Modelo cargado: $($response.model_loaded)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Servidor local no está disponible" -ForegroundColor Red
    Write-Host "Ejecuta primero: .\start-local-model.ps1" -ForegroundColor Yellow
    exit 1
}

# Probar generación de respuesta
Write-Host "Probando generación de respuesta..." -ForegroundColor Yellow

$testPrompt = "Eres un codificador médico experto. Responde en formato JSON: ¿Cuál es el código CIE-10 para diabetes tipo 2?"

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/generate" -Method Post -Body (@{
        prompt = $testPrompt
        max_tokens = 200
        temperature = 0.1
        top_p = 0.9
    } | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 30
    
    Write-Host "✅ Respuesta generada exitosamente" -ForegroundColor Green
    Write-Host "Tiempo de procesamiento: $($response.processing_time) segundos" -ForegroundColor Cyan
    Write-Host "Modelo usado: $($response.model_used)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Respuesta:" -ForegroundColor Yellow
    Write-Host $response.response -ForegroundColor White
    
} catch {
    Write-Host "❌ Error probando generación: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Prueba completada" -ForegroundColor Green
