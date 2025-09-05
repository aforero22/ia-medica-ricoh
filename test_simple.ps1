# Prueba simple de modelos
$BackendUrl = "http://localhost:9999"

Write-Host "⚡ PRUEBA SIMPLE DE MODELOS" -ForegroundColor Cyan

$casoPrueba = @{
    diagnostico = "Paciente de 65 años con diabetes mellitus tipo 2"
    sintomas = "Poliuria, polidipsia, pérdida de peso"
    edad = 65
}

$modelos = @("gemma3:4b", "gemma3:12b", "gpt-3.5-turbo", "gpt-4")

foreach ($modelo in $modelos) {
    Write-Host "🤖 Probando $modelo..." -ForegroundColor Magenta
    
    $tiempoInicio = Get-Date
    
    try {
        $body = @{
            diagnostico = $casoPrueba.diagnostico
            sintomas = $casoPrueba.sintomas
            edad = $casoPrueba.edad
            modelo = $modelo
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BackendUrl/generate" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 60
        
        $tiempoFin = Get-Date
        $tiempoTotal = ($tiempoFin - $tiempoInicio).TotalSeconds
        
        Write-Host "   ✅ Tiempo: $([math]::Round($tiempoTotal, 2))s | Código: $($response.diagnostico_principal.codigo) | Confianza: $([math]::Round($response.diagnostico_principal.confianza * 100, 1))%" -ForegroundColor Green
        
    } catch {
        $tiempoFin = Get-Date
        $tiempoTotal = ($tiempoFin - $tiempoInicio).TotalSeconds
        Write-Host "   ❌ Error después de $([math]::Round($tiempoTotal, 2))s" -ForegroundColor Red
    }
    
    Write-Host ""
}
