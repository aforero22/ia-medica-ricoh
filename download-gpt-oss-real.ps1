# RICOH España - Script para descargar GPT-OSS real
# Descarga el modelo GPT-OSS oficial de OpenAI desde Hugging Face

param(
    [string]$ModelSize = "20b",  # 20b o 120b
    [string]$OutputPath = "medical-service-advanced/models"
)

Write-Host "Descargando GPT-OSS real de OpenAI..." -ForegroundColor Green

# Crear directorio si no existe
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force
    Write-Host "Directorio creado: $OutputPath" -ForegroundColor Yellow
}

# URLs de los modelos GPT-OSS
$modelUrls = @{
    "20b" = "https://huggingface.co/openai/gpt-oss-20b"
    "120b" = "https://huggingface.co/openai/gpt-oss-120b"
}

$selectedUrl = $modelUrls[$ModelSize]
if (!$selectedUrl) {
    Write-Host "Error: Tamaño de modelo no válido. Usa '20b' o '120b'" -ForegroundColor Red
    exit 1
}

Write-Host "Modelo seleccionado: GPT-OSS-$ModelSize" -ForegroundColor Cyan
Write-Host "URL: $selectedUrl" -ForegroundColor Cyan

# Verificar si huggingface-cli está instalado
try {
    $null = huggingface-cli --version
    Write-Host "✅ Hugging Face CLI encontrado" -ForegroundColor Green
} catch {
    Write-Host "Instalando Hugging Face CLI..." -ForegroundColor Yellow
    pip install huggingface_hub
}

# Descargar modelo usando huggingface-cli
Write-Host "Descargando modelo GPT-OSS-$ModelSize..." -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos dependiendo de tu conexión..." -ForegroundColor Cyan

try {
    $modelName = "openai/gpt-oss-$ModelSize"
    $localDir = "$OutputPath/gpt-oss-$ModelSize"
    
    # Descargar modelo completo
    huggingface-cli download $modelName --local-dir $localDir --include "original/*"
    
    if (Test-Path $localDir) {
        Write-Host "✅ Modelo GPT-OSS-$ModelSize descargado exitosamente" -ForegroundColor Green
        Write-Host "Ubicación: $localDir" -ForegroundColor Cyan
        
        # Mostrar información del directorio
        $dirInfo = Get-ChildItem $localDir -Recurse | Measure-Object -Property Length -Sum
        $sizeGB = [math]::Round($dirInfo.Sum / 1GB, 2)
        Write-Host "Tamaño total: $sizeGB GB" -ForegroundColor Cyan
        Write-Host "Archivos: $($dirInfo.Count)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Error: El modelo no se descargó correctamente" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Error descargando modelo: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Alternativa: Descarga manual desde $selectedUrl" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🎉 ¡GPT-OSS descargado exitosamente!" -ForegroundColor Green
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Instalar dependencias: pip install gpt-oss" -ForegroundColor Cyan
Write-Host "2. Actualizar servidor local para usar GPT-OSS" -ForegroundColor Cyan
Write-Host "3. Probar el modelo: python -m gpt_oss.chat $localDir" -ForegroundColor Cyan
