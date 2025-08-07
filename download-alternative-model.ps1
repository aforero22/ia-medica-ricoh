# RICOH España - Script para descargar modelo alternativo
# Descarga un modelo de IA local alternativo mientras GPT-OSS no esté disponible

param(
    [string]$ModelType = "llama2",  # llama2, mistral, codellama
    [string]$OutputPath = "medical-service-advanced/models"
)

Write-Host "Descargando modelo alternativo de IA local..." -ForegroundColor Green

# Crear directorio si no existe
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force
    Write-Host "Directorio creado: $OutputPath" -ForegroundColor Yellow
}

# URLs de modelos alternativos disponibles
$modelUrls = @{
    "llama2" = "https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf"
    "mistral" = "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf"
    "codellama" = "https://huggingface.co/TheBloke/CodeLlama-7B-Instruct-GGUF/resolve/main/codellama-7b-instruct.Q4_K_M.gguf"
}

# Verificar si el tipo de modelo es válido
if ($ModelType -notin @("llama2", "mistral", "codellama")) {
    Write-Host "Error: Tipo de modelo debe ser 'llama2', 'mistral' o 'codellama'" -ForegroundColor Red
    exit 1
}

$modelUrl = $modelUrls[$ModelType]
$modelFile = "$ModelType-7b-chat.gguf"
$outputFile = Join-Path $OutputPath $modelFile

Write-Host "Descargando modelo $ModelType..." -ForegroundColor Yellow
Write-Host "URL: $modelUrl" -ForegroundColor Cyan
Write-Host "Archivo: $outputFile" -ForegroundColor Cyan

# Descargar archivo
try {
    # Usar Invoke-WebRequest para descarga con progreso
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Iniciando descarga (esto puede tomar varios minutos)..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $modelUrl -OutFile $outputFile -UseBasicParsing
    
    # Verificar que el archivo se descargó correctamente
    if (Test-Path $outputFile) {
        $fileSize = (Get-Item $outputFile).Length / 1GB
        Write-Host "Modelo descargado exitosamente!" -ForegroundColor Green
        Write-Host "Tamaño: $([math]::Round($fileSize, 2)) GB" -ForegroundColor Cyan
        Write-Host "Ubicación: $outputFile" -ForegroundColor Cyan
    } else {
        Write-Host "Error: No se pudo descargar el archivo" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "Error descargando modelo: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Sugerencia: Verifica tu conexión a internet y que la URL sea correcta" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Descarga completada!" -ForegroundColor Green
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Verifica que el archivo esté en: $outputFile" -ForegroundColor White
Write-Host "   2. Reinicia el backend para cargar el modelo local" -ForegroundColor White
Write-Host "   3. El sistema usará automáticamente el modelo local" -ForegroundColor White
Write-Host ""
Write-Host "Para usar el modelo:" -ForegroundColor Cyan
Write-Host "   - Reinicia el backend: kubectl rollout restart deployment/backend-ricoh -n medical-only" -ForegroundColor White
Write-Host "   - Verifica logs: kubectl logs deployment/backend-ricoh -n medical-only" -ForegroundColor White
