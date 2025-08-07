# RICOH España - Script para descargar GPT-OSS
# Descarga el modelo GPT-OSS de OpenAI para uso local

param(
    [string]$ModelSize = "20b",  # 20b o 120b
    [string]$OutputPath = "medical-service-advanced/models"
)

Write-Host "🚀 Descargando GPT-OSS de OpenAI..." -ForegroundColor Green

# Crear directorio si no existe
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force
    Write-Host "📁 Directorio creado: $OutputPath" -ForegroundColor Yellow
}

# URLs de descarga (ejemplo - actualizar con URLs reales cuando estén disponibles)
$modelUrls = @{
    "20b" = "https://huggingface.co/openai/gpt-oss-20b/resolve/main/gpt-oss-20b.gguf"
    "120b" = "https://huggingface.co/openai/gpt-oss-120b/resolve/main/gpt-oss-120b.gguf"
}

# Verificar si el tamaño de modelo es válido
if ($ModelSize -notin @("20b", "120b")) {
    Write-Host "❌ Error: Tamaño de modelo debe ser '20b' o '120b'" -ForegroundColor Red
    exit 1
}

$modelUrl = $modelUrls[$ModelSize]
$modelFile = "gpt-oss-$ModelSize.gguf"
$outputFile = Join-Path $OutputPath $modelFile

Write-Host "📥 Descargando modelo GPT-OSS-$ModelSize..." -ForegroundColor Yellow
Write-Host "🔗 URL: $modelUrl" -ForegroundColor Cyan
Write-Host "💾 Archivo: $outputFile" -ForegroundColor Cyan

# Descargar archivo
try {
    # Usar Invoke-WebRequest para descarga con progreso
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $modelUrl -OutFile $outputFile -UseBasicParsing
    
    # Verificar que el archivo se descargó correctamente
    if (Test-Path $outputFile) {
        $fileSize = (Get-Item $outputFile).Length / 1GB
        Write-Host "✅ Modelo descargado exitosamente!" -ForegroundColor Green
        Write-Host "📊 Tamaño: $([math]::Round($fileSize, 2)) GB" -ForegroundColor Cyan
        Write-Host "📍 Ubicación: $outputFile" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Error: No se pudo descargar el archivo" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Error descargando modelo: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Sugerencia: Verifica tu conexión a internet y que la URL sea correcta" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🎉 ¡Descarga completada!" -ForegroundColor Green
Write-Host "📋 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Verifica que el archivo esté en: $outputFile" -ForegroundColor White
Write-Host "   2. Ejecuta el backend para cargar el modelo local" -ForegroundColor White
Write-Host "   3. El sistema usará automáticamente GPT-OSS local" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Para usar el modelo:" -ForegroundColor Cyan
Write-Host "   - Reinicia el backend: kubectl rollout restart deployment/backend-ricoh -n medical-only" -ForegroundColor White
Write-Host "   - Verifica logs: kubectl logs deployment/backend-ricoh -n medical-only" -ForegroundColor White
