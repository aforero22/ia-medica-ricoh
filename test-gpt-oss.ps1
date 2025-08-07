# RICOH España - Script para probar GPT-OSS
# Prueba el servidor local de GPT-OSS

Write-Host "Probando servidor GPT-OSS..." -ForegroundColor Green

# Verificar que el servidor esté corriendo
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method Get -TimeoutSec 5
    Write-Host "✅ Servidor GPT-OSS está funcionando" -ForegroundColor Green
    Write-Host "Estado: $($response.status)" -ForegroundColor Cyan
    Write-Host "Modelo cargado: $($response.model_loaded)" -ForegroundColor Cyan
    Write-Host "Tipo de modelo: $($response.model_type)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Servidor GPT-OSS no está disponible" -ForegroundColor Red
    Write-Host "Ejecuta primero: python gpt-oss-server.py" -ForegroundColor Yellow
    exit 1
}

# Probar generación de respuesta con diferentes niveles de razonamiento
Write-Host "Probando generación de respuesta..." -ForegroundColor Yellow

$testPrompt = "Eres un codificador médico experto. Responde en formato JSON: ¿Cuál es el código CIE-10 para diabetes tipo 2?"

$reasoningLevels = @("low", "medium", "high")

foreach ($level in $reasoningLevels) {
    Write-Host "Probando con nivel de razonamiento: $level" -ForegroundColor Cyan
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/generate" -Method Post -Body (@{
            prompt = $testPrompt
            max_tokens = 300
            temperature = 0.1
            reasoning_level = $level
        } | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 60
        
        Write-Host "✅ Respuesta generada exitosamente" -ForegroundColor Green
        Write-Host "Tiempo de procesamiento: $($response.processing_time) segundos" -ForegroundColor Cyan
        Write-Host "Nivel de razonamiento: $($response.reasoning_level)" -ForegroundColor Cyan
        Write-Host "Modelo usado: $($response.model_used)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Respuesta:" -ForegroundColor Yellow
        Write-Host $response.response -ForegroundColor White
        Write-Host ""
        Write-Host "---" -ForegroundColor Gray
        
    } catch {
        Write-Host "❌ Error probando con nivel $level`: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Prueba completada" -ForegroundColor Green
