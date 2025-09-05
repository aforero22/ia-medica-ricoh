# Calculadora Simple de Costos OpenAI
Write-Host "CALCULADORA DE COSTOS OPENAI API" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Precios por 1K tokens (Enero 2025)
Write-Host "PRECIOS ACTUALES:" -ForegroundColor Green
Write-Host "GPT-3.5 Turbo: Input $0.0005/1K, Output $0.0015/1K" -ForegroundColor White
Write-Host "GPT-4: Input $0.03/1K, Output $0.06/1K" -ForegroundColor White
Write-Host "GPT-4 Turbo: Input $0.01/1K, Output $0.03/1K" -ForegroundColor White
Write-Host ""

# Estimacion de tokens por consulta
Write-Host "TOKENS POR CONSULTA TIPICA:" -ForegroundColor Yellow
Write-Host "GPT-3.5 Turbo: ~800 input + 150 output = 950 tokens" -ForegroundColor White
Write-Host "GPT-4: ~1000 input + 200 output = 1200 tokens" -ForegroundColor White
Write-Host "GPT-4 Turbo: ~1200 input + 250 output = 1450 tokens" -ForegroundColor White
Write-Host ""

# Calculos de costo
Write-Host "COSTO POR CONSULTA:" -ForegroundColor Magenta
Write-Host "===================" -ForegroundColor Magenta

# GPT-3.5 Turbo
$gpt35_input_cost = (800 / 1000) * 0.0005
$gpt35_output_cost = (150 / 1000) * 0.0015
$gpt35_total = $gpt35_input_cost + $gpt35_output_cost
Write-Host "GPT-3.5 Turbo: $($gpt35_total.ToString('F6')) USD por consulta" -ForegroundColor Green

# GPT-4
$gpt4_input_cost = (1000 / 1000) * 0.03
$gpt4_output_cost = (200 / 1000) * 0.06
$gpt4_total = $gpt4_input_cost + $gpt4_output_cost
Write-Host "GPT-4: $($gpt4_total.ToString('F6')) USD por consulta" -ForegroundColor Blue

# GPT-4 Turbo
$gpt4t_input_cost = (1200 / 1000) * 0.01
$gpt4t_output_cost = (250 / 1000) * 0.03
$gpt4t_total = $gpt4t_input_cost + $gpt4t_output_cost
Write-Host "GPT-4 Turbo: $($gpt4t_total.ToString('F6')) USD por consulta" -ForegroundColor Yellow
Write-Host ""

# Analisis de volumen
Write-Host "COSTOS POR VOLUMEN (50 consultas/dia):" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "GPT-3.5 Turbo: $($($gpt35_total * 50).ToString('F2')) USD/dia = $($($gpt35_total * 50 * 30).ToString('F0')) USD/mes" -ForegroundColor Green
Write-Host "GPT-4: $($($gpt4_total * 50).ToString('F2')) USD/dia = $($($gpt4_total * 50 * 30).ToString('F0')) USD/mes" -ForegroundColor Blue
Write-Host "GPT-4 Turbo: $($($gpt4t_total * 50).ToString('F2')) USD/dia = $($($gpt4t_total * 50 * 30).ToString('F0')) USD/mes" -ForegroundColor Yellow
Write-Host ""

Write-Host "RECOMENDACIONES:" -ForegroundColor Magenta
Write-Host "===============" -ForegroundColor Magenta
Write-Host "MEJOR PRECIO/PERFORMANCE: GPT-3.5 Turbo" -ForegroundColor Green
Write-Host "MAXIMA PRECISION: GPT-4" -ForegroundColor Blue
Write-Host "BALANCEADO: GPT-4 Turbo" -ForegroundColor Yellow
Write-Host ""
Write-Host "MODELOS LOCALES: GRATIS (solo hardware)" -ForegroundColor White
