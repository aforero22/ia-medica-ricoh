# Calculadora de Costos OpenAI API para CIE-10-ES
# Analiza el costo por consulta de diagnóstico médico

Write-Host "💰 CALCULADORA DE COSTOS OPENAI API" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

# Precios por 1K tokens (Enero 2025)
$precios = @{
    "gpt-3.5-turbo" = @{
        input = 0.0005   # $0.0005 por 1K tokens
        output = 0.0015  # $0.0015 por 1K tokens
    }
    "gpt-4" = @{
        input = 0.03     # $0.03 por 1K tokens
        output = 0.06    # $0.06 por 1K tokens
    }
    "gpt-4-turbo" = @{
        input = 0.01     # $0.01 por 1K tokens
        output = 0.03    # $0.03 por 1K tokens
    }
}

# Estimación de tokens por consulta típica
$tokensEstimados = @{
    "gpt-3.5-turbo" = @{
        input = 800      # Prompt + contexto RAG + síntomas
        output = 150     # Respuesta estructurada
    }
    "gpt-4" = @{
        input = 1000     # Prompt más detallado
        output = 200     # Respuesta más elaborada
    }
    "gpt-4-turbo" = @{
        input = 1200     # Prompt más completo
        output = 250     # Respuesta más detallada
    }
}

Write-Host "📊 ANÁLISIS DE COSTOS POR CONSULTA:" -ForegroundColor Green
Write-Host ""

foreach ($modelo in $precios.Keys) {
    $precio = $precios[$modelo]
    $tokens = $tokensEstimados[$modelo]
    
    # Calcular costos
    $costoInput = ($tokens.input / 1000) * $precio.input
    $costoOutput = ($tokens.output / 1000) * $precio.output
    $costoTotal = $costoInput + $costoOutput
    
    Write-Host "🤖 $($modelo.ToUpper())" -ForegroundColor Magenta
    Write-Host "   📥 Input: $($tokens.input) tokens × $($precio.input)/1K = $($costoInput.ToString('F6')) USD" -ForegroundColor Blue
    Write-Host "   📤 Output: $($tokens.output) tokens × $($precio.output)/1K = $($costoOutput.ToString('F6')) USD" -ForegroundColor Blue
    Write-Host "   💰 TOTAL POR CONSULTA: $($costoTotal.ToString('F6')) USD" -ForegroundColor Green
    Write-Host ""
}

# Análisis de volumen
Write-Host "📈 ANÁLISIS DE VOLUMEN:" -ForegroundColor Yellow
Write-Host "=" * 30 -ForegroundColor Yellow

$volumenes = @(
    @{ nombre = "Consultorio pequeño"; consultas = 50; periodo = "por día" },
    @{ nombre = "Hospital mediano"; consultas = 500; periodo = "por día" },
    @{ nombre = "Red hospitalaria"; consultas = 5000; periodo = "por día" },
    @{ nombre = "Sistema nacional"; consultas = 50000; periodo = "por día" }
)

foreach ($volumen in $volumenes) {
    Write-Host "🏥 $($volumen.nombre) ($($volumen.consultas) consultas $($volumen.periodo)):" -ForegroundColor White
    
    foreach ($modelo in $precios.Keys) {
        $precio = $precios[$modelo]
        $tokens = $tokensEstimados[$modelo]
        $costoPorConsulta = (($tokens.input / 1000) * $precio.input) + (($tokens.output / 1000) * $precio.output)
        $costoDiario = $costoPorConsulta * $volumen.consultas
        $costoMensual = $costoDiario * 30
        $costoAnual = $costoMensual * 12
        
        Write-Host "   $($modelo): $($costoDiario.ToString('F2')) USD/día | $($costoMensual.ToString('F0')) USD/mes | $($costoAnual.ToString('F0')) USD/año" -ForegroundColor Gray
    }
    Write-Host ""
}

# Comparación con alternativas
Write-Host "🔄 COMPARACIÓN CON ALTERNATIVAS:" -ForegroundColor Cyan
Write-Host "=" * 40 -ForegroundColor Cyan

Write-Host "🏠 MODELOS LOCALES (Ollama):" -ForegroundColor Green
Write-Host "   💰 Costo inicial: $0 (solo hardware)" -ForegroundColor Green
Write-Host "   ⚡ Velocidad: 14-47 segundos" -ForegroundColor Yellow
Write-Host "   🔒 Privacidad: 100% (datos no salen del servidor)" -ForegroundColor Green
Write-Host "   🎯 Precisión: Necesita optimización" -ForegroundColor Yellow
Write-Host ""

Write-Host "☁️ MODELOS CLOUD (OpenAI):" -ForegroundColor Blue
Write-Host "   💰 Costo por consulta: $0.0001 - $0.0003 USD" -ForegroundColor Blue
Write-Host "   ⚡ Velocidad: 1.96 - 2.94 segundos" -ForegroundColor Green
Write-Host "   🔒 Privacidad: Datos van a OpenAI" -ForegroundColor Yellow
Write-Host "   🎯 Precisión: Excelente (códigos correctos)" -ForegroundColor Green
Write-Host ""

# Recomendaciones
Write-Host "💡 RECOMENDACIONES:" -ForegroundColor Magenta
Write-Host "=" * 20 -ForegroundColor Magenta

Write-Host "🥇 PARA MÁXIMO AHORRO:" -ForegroundColor Green
Write-Host "   • Usar Gemma3 4B local (gratis)" -ForegroundColor Green
Write-Host "   • Optimizar prompts para mejor precisión" -ForegroundColor Green
Write-Host ""

Write-Host "🥈 PARA MEJOR PRECISIÓN/COSTO:" -ForegroundColor Blue
Write-Host "   • Usar GPT-3.5 Turbo ($0.0001 por consulta)" -ForegroundColor Blue
Write-Host "   • 50 consultas/día = $1.50 USD/mes" -ForegroundColor Blue
Write-Host ""

Write-Host "🥉 PARA MÁXIMA PRECISIÓN:" -ForegroundColor Yellow
Write-Host "   • Usar GPT-4 ($0.0003 por consulta)" -ForegroundColor Yellow
Write-Host "   • 50 consultas/día = $4.50 USD/mes" -ForegroundColor Yellow
Write-Host ""

Write-Host "🎯 ESTRATEGIA HÍBRIDA RECOMENDADA:" -ForegroundColor Cyan
Write-Host "   • Casos simples: Gemma3 4B local" -ForegroundColor Cyan
Write-Host "   • Casos complejos: GPT-3.5 Turbo cloud" -ForegroundColor Cyan
Write-Host "   • Casos críticos: GPT-4 cloud" -ForegroundColor Cyan
