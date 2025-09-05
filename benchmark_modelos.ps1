# Script de Benchmarking para Modelos IA - CIE-10-ES
# Evalúa velocidad, precisión y confianza de todos los modelos

param(
    [string]$BackendUrl = "http://localhost:9999",
    [int]$NumeroPruebas = 5
)

Write-Host "🚀 INICIANDO BENCHMARK DE MODELOS IA CIE-10-ES" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Casos de prueba estandarizados
$casosPrueba = @(
    @{
        diagnostico = "Paciente de 65 años con diabetes mellitus tipo 2 descompensada"
        sintomas = "Poliuria, polidipsia, pérdida de peso, fatiga, visión borrosa"
        edad = 65
        codigoEsperado = "E11"
    },
    @{
        diagnostico = "Mujer de 45 años con hipertensión arterial esencial"
        sintomas = "Dolor de cabeza, mareos, náuseas, visión borrosa, dolor en el pecho"
        edad = 45
        codigoEsperado = "I10"
    },
    @{
        diagnostico = "Varón de 58 años con infarto agudo de miocardio"
        sintomas = "Dolor intenso en el pecho, dificultad para respirar, sudoración fría"
        edad = 58
        codigoEsperado = "I21"
    },
    @{
        diagnostico = "Paciente de 72 años con neumonía adquirida en la comunidad"
        sintomas = "Fiebre alta, tos productiva, dificultad para respirar, dolor en el pecho"
        edad = 72
        codigoEsperado = "J18"
    },
    @{
        diagnostico = "Mujer de 35 años con embarazo de alto riesgo"
        sintomas = "Náuseas matutinas, fatiga, cambios de humor, dolor lumbar"
        edad = 35
        codigoEsperado = "O09"
    }
)

# Modelos a evaluar
$modelos = @(
    @{ nombre = "Gemma3 4B"; id = "gemma3:4b"; tipo = "Local" },
    @{ nombre = "Gemma3 12B"; id = "gemma3:12b"; tipo = "Local" },
    @{ nombre = "Gemma3 27B"; id = "gemma3:27b"; tipo = "Local" },
    @{ nombre = "GPT-OSS 20B"; id = "gpt-oss:20b"; tipo = "Local" },
    @{ nombre = "DeepSeek R1 8B"; id = "deepseek-r1:8b"; tipo = "Local" },
    @{ nombre = "Qwen3 8B"; id = "qwen3:8b"; tipo = "Local" },
    @{ nombre = "GPT-3.5 Turbo"; id = "gpt-3.5-turbo"; tipo = "Cloud" },
    @{ nombre = "GPT-4"; id = "gpt-4"; tipo = "Cloud" },
    @{ nombre = "GPT-4 Turbo"; id = "gpt-4-turbo"; tipo = "Cloud" }
)

# Función para probar un modelo
function Test-Modelo {
    param($modelo, $caso, $numeroPrueba)
    
    $tiempoInicio = Get-Date
    $tiempoInicioMs = $tiempoInicio.Ticks / 10000
    
    try {
        $body = @{
            diagnostico = $caso.diagnostico
            sintomas = $caso.sintomas
            edad = $caso.edad
            modelo = $modelo.id
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BackendUrl/generate" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 300
        
        $tiempoFin = Get-Date
        $tiempoFinMs = $tiempoFin.Ticks / 10000
        $tiempoTotal = ($tiempoFinMs - $tiempoInicioMs) / 1000
        
        # Verificar precisión
        $codigoCorrecto = $response.diagnostico_principal.codigo -eq $caso.codigoEsperado
        $confianza = $response.diagnostico_principal.confianza
        
        return @{
            Exitoso = $true
            Tiempo = $tiempoTotal
            Codigo = $response.diagnostico_principal.codigo
            CodigoEsperado = $caso.codigoEsperado
            CodigoCorrecto = $codigoCorrecto
            Confianza = $confianza
            Descripcion = $response.diagnostico_principal.descripcion
            Justificacion = $response.diagnostico_principal.justificacion
            MotorIA = $response.motor_ia
            Error = $null
        }
    }
    catch {
        $tiempoFin = Get-Date
        $tiempoFinMs = $tiempoFin.Ticks / 10000
        $tiempoTotal = ($tiempoFinMs - $tiempoInicioMs) / 1000
        
        return @{
            Exitoso = $false
            Tiempo = $tiempoTotal
            Codigo = $null
            CodigoEsperado = $caso.codigoEsperado
            CodigoCorrecto = $false
            Confianza = 0
            Descripcion = $null
            Justificacion = $null
            MotorIA = $modelo.nombre
            Error = $_.Exception.Message
        }
    }
}

# Función para mostrar progreso
function Show-Progress {
    param($actual, $total, $modelo, $caso)
    $porcentaje = [math]::Round(($actual / $total) * 100, 1)
    Write-Host "🔄 Progreso: $porcentaje% - Probando $($modelo.nombre) con caso: $($caso.diagnostico.Substring(0, [Math]::Min(50, $caso.diagnostico.Length)))..." -ForegroundColor Yellow
}

# Ejecutar benchmark
$resultados = @()
$totalPruebas = $modelos.Count * $casosPrueba.Count
$pruebaActual = 0

Write-Host "📊 Ejecutando $totalPruebas pruebas en total..." -ForegroundColor Green
Write-Host ""

foreach ($modelo in $modelos) {
    Write-Host "🤖 EVALUANDO: $($modelo.nombre) ($($modelo.tipo))" -ForegroundColor Magenta
    Write-Host "-" * 50 -ForegroundColor Magenta
    
    $resultadosModelo = @()
    
    foreach ($caso in $casosPrueba) {
        $pruebaActual++
        Show-Progress $pruebaActual $totalPruebas $modelo $caso
        
        $resultado = Test-Modelo $modelo $caso $pruebaActual
        $resultado | Add-Member -NotePropertyName "Modelo" -NotePropertyValue $modelo.nombre
        $resultado | Add-Member -NotePropertyName "Tipo" -NotePropertyValue $modelo.tipo
        $resultado | Add-Member -NotePropertyName "Caso" -NotePropertyValue $caso.diagnostico
        
        $resultadosModelo += $resultado
        $resultados += $resultado
        
        if ($resultado.Exitoso) {
            $estado = if ($resultado.CodigoCorrecto) { "✅" } else { "⚠️" }
            Write-Host "   $estado Tiempo: $([math]::Round($resultado.Tiempo, 2))s | Código: $($resultado.Codigo) | Confianza: $([math]::Round($resultado.Confianza * 100, 1))%" -ForegroundColor $(if ($resultado.CodigoCorrecto) { "Green" } else { "Yellow" })
        } else {
            Write-Host "   ❌ Error: $($resultado.Error)" -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 500  # Pausa entre pruebas
    }
    
    Write-Host ""
}

# Análisis de resultados
Write-Host "📈 ANÁLISIS DE RESULTADOS" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Agrupar por modelo
$resultadosPorModelo = $resultados | Group-Object Modelo

foreach ($grupo in $resultadosPorModelo) {
    $modelo = $grupo.Name
    $pruebas = $grupo.Group
    $exitosas = $pruebas | Where-Object { $_.Exitoso }
    $correctas = $pruebas | Where-Object { $_.CodigoCorrecto }
    
    if ($exitosas.Count -gt 0) {
        $tiempoPromedio = ($exitosas | Measure-Object -Property Tiempo -Average).Average
        $confianzaPromedio = ($exitosas | Measure-Object -Property Confianza -Average).Average
        $precision = ($correctas.Count / $pruebas.Count) * 100
        $disponibilidad = ($exitosas.Count / $pruebas.Count) * 100
        
        Write-Host "🤖 $modelo" -ForegroundColor White
        Write-Host "   ⚡ Tiempo promedio: $([math]::Round($tiempoPromedio, 2))s" -ForegroundColor Green
        Write-Host "   🎯 Precisión: $([math]::Round($precision, 1))%" -ForegroundColor Blue
        Write-Host "   🔒 Confianza promedio: $([math]::Round($confianzaPromedio * 100, 1))%" -ForegroundColor Yellow
        Write-Host "   ✅ Disponibilidad: $([math]::Round($disponibilidad, 1))%" -ForegroundColor Cyan
        Write-Host ""
    }
}

# Ranking de modelos
Write-Host "🏆 RANKING DE MODELOS" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

$ranking = @()
foreach ($grupo in $resultadosPorModelo) {
    $modelo = $grupo.Name
    $pruebas = $grupo.Group
    $exitosas = $pruebas | Where-Object { $_.Exitoso }
    $correctas = $pruebas | Where-Object { $_.CodigoCorrecto }
    
    if ($exitosas.Count -gt 0) {
        $tiempoPromedio = ($exitosas | Measure-Object -Property Tiempo -Average).Average
        $confianzaPromedio = ($exitosas | Measure-Object -Property Confianza -Average).Average
        $precision = ($correctas.Count / $pruebas.Count) * 100
        $disponibilidad = ($exitosas.Count / $pruebas.Count) * 100
        
        # Puntuación combinada (menor tiempo = mejor, mayor precisión = mejor)
        $puntuacion = ($precision * 0.4) + ($confianzaPromedio * 100 * 0.3) + ($disponibilidad * 0.2) + ((10 - [Math]::Min($tiempoPromedio, 10)) * 10 * 0.1)
        
        $ranking += @{
            Modelo = $modelo
            Tiempo = $tiempoPromedio
            Precision = $precision
            Confianza = $confianzaPromedio * 100
            Disponibilidad = $disponibilidad
            Puntuacion = $puntuacion
        }
    }
}

$ranking = $ranking | Sort-Object Puntuacion -Descending

Write-Host "🥇 TOP 3 MODELOS RECOMENDADOS:" -ForegroundColor Green
for ($i = 0; $i -lt [Math]::Min(3, $ranking.Count); $i++) {
    $pos = $i + 1
    $emoji = if ($pos -eq 1) { "🥇" } elseif ($pos -eq 2) { "🥈" } else { "🥉" }
    $modelo = $ranking[$i]
    Write-Host "$emoji $($modelo.Modelo)" -ForegroundColor White
    Write-Host "   Puntuación: $([math]::Round($modelo.Puntuacion, 1)) | Tiempo: $([math]::Round($modelo.Tiempo, 2))s | Precisión: $([math]::Round($modelo.Precision, 1))%" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ BENCHMARK COMPLETADO" -ForegroundColor Green
Write-Host "📊 Total de pruebas ejecutadas: $($resultados.Count)" -ForegroundColor Cyan
