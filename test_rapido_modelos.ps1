# Script de Pruebas Rápidas - Modelos IA CIE-10-ES
# Prueba rápida de los modelos más prometedores

param(
    [string]$BackendUrl = "http://localhost:9999"
)

Write-Host "⚡ PRUEBA RÁPIDA DE MODELOS IA" -ForegroundColor Cyan
Write-Host "=" * 40 -ForegroundColor Cyan

# Caso de prueba simple
$casoPrueba = @{
    diagnostico = "Paciente de 65 años con diabetes mellitus tipo 2 descompensada"
    sintomas = "Poliuria, polidipsia, pérdida de peso, fatiga, visión borrosa"
    edad = 65
}

# Modelos a probar (los más prometedores)
$modelosRapidos = @(
    @{ nombre = "Gemma3 4B"; id = "gemma3:4b"; tipo = "Local" },
    @{ nombre = "Gemma3 12B"; id = "gemma3:12b"; tipo = "Local" },
    @{ nombre = "GPT-OSS 20B"; id = "gpt-oss:20b"; tipo = "Local" },
    @{ nombre = "GPT-3.5 Turbo"; id = "gpt-3.5-turbo"; tipo = "Cloud" },
    @{ nombre = "GPT-4"; id = "gpt-4"; tipo = "Cloud" }
)

Write-Host "🧪 Probando con caso: $($casoPrueba.diagnostico)" -ForegroundColor Yellow
Write-Host ""

$resultados = @()

foreach ($modelo in $modelosRapidos) {
    Write-Host "🤖 Probando $($modelo.nombre)..." -ForegroundColor Magenta
    
    $tiempoInicio = Get-Date
    $tiempoInicioMs = $tiempoInicio.Ticks / 10000
    
    try {
        $body = @{
            diagnostico = $casoPrueba.diagnostico
            sintomas = $casoPrueba.sintomas
            edad = $casoPrueba.edad
            modelo = $modelo.id
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BackendUrl/generate" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 120
        
        $tiempoFin = Get-Date
        $tiempoFinMs = $tiempoFin.Ticks / 10000
        $tiempoTotal = ($tiempoFinMs - $tiempoInicioMs) / 1000
        
        $resultado = @{
            Modelo = $modelo.nombre
            Tipo = $modelo.tipo
            Tiempo = $tiempoTotal
            Codigo = $response.diagnostico_principal.codigo
            Confianza = $response.diagnostico_principal.confianza
            Descripcion = $response.diagnostico_principal.descripcion
            Exitoso = $true
        }
        
        $resultados += $resultado
        
        Write-Host "   ✅ Tiempo: $([math]::Round($tiempoTotal, 2))s | Código: $($response.diagnostico_principal.codigo) | Confianza: $([math]::Round($response.diagnostico_principal.confianza * 100, 1))%" -ForegroundColor Green
        
    } catch {
        $tiempoFin = Get-Date
        $tiempoFinMs = $tiempoFin.Ticks / 10000
        $tiempoTotal = ($tiempoFinMs - $tiempoInicioMs) / 1000
        
        Write-Host "   ❌ Error después de $([math]::Round($tiempoTotal, 2))s: $($_.Exception.Message)" -ForegroundColor Red
        
        $resultado = @{
            Modelo = $modelo.nombre
            Tipo = $modelo.tipo
            Tiempo = $tiempoTotal
            Codigo = "ERROR"
            Confianza = 0
            Descripcion = "Error"
            Exitoso = $false
        }
        
        $resultados += $resultado
    }
    
    Write-Host ""
}

# Mostrar resumen
Write-Host "📊 RESUMEN RÁPIDO" -ForegroundColor Cyan
Write-Host "=" * 40 -ForegroundColor Cyan

$exitosos = $resultados | Where-Object { $_.Exitoso }
if ($exitosos.Count -gt 0) {
    $exitosos = $exitosos | Sort-Object Tiempo
    
    Write-Host "🏆 MÁS RÁPIDO: $($exitosos[0].Modelo) - $([math]::Round($exitosos[0].Tiempo, 2))s" -ForegroundColor Green
    
    $mayorConfianza = $exitosos | Sort-Object Confianza -Descending
    Write-Host "🎯 MAYOR CONFIANZA: $($mayorConfianza[0].Modelo) - $([math]::Round($mayorConfianza[0].Confianza * 100, 1))%" -ForegroundColor Blue
    
    Write-Host ""
    Write-Host "📋 TODOS LOS RESULTADOS:" -ForegroundColor Yellow
    foreach ($resultado in $exitosos) {
        $emoji = if ($resultado.Tipo -eq "Local") { "🏠" } else { "☁️" }
        Write-Host "$emoji $($resultado.Modelo): $([math]::Round($resultado.Tiempo, 2))s | $($resultado.Codigo) | $([math]::Round($resultado.Confianza * 100, 1))%" -ForegroundColor White
    }
} else {
    Write-Host "❌ No se pudo completar ninguna prueba exitosamente" -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 Para análisis completo, ejecuta: .\benchmark_modelos.ps1" -ForegroundColor Cyan
