# RICOH España - Script para instalar GPT-OSS
# Instala las dependencias necesarias para usar GPT-OSS

Write-Host "Instalando dependencias para GPT-OSS..." -ForegroundColor Green

# Verificar Python
try {
    $pythonVersion = python --version
    Write-Host "✅ Python encontrado: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python no encontrado" -ForegroundColor Red
    exit 1
}

# Instalar dependencias básicas
Write-Host "Instalando dependencias básicas..." -ForegroundColor Yellow
pip install fastapi uvicorn pydantic requests

# Instalar GPT-OSS
Write-Host "Instalando GPT-OSS..." -ForegroundColor Yellow
try {
    pip install gpt-oss
    Write-Host "✅ GPT-OSS instalado exitosamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error instalando GPT-OSS: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Intenta: pip install --upgrade pip" -ForegroundColor Yellow
    exit 1
}

# Instalar Hugging Face Hub para descargas
Write-Host "Instalando Hugging Face Hub..." -ForegroundColor Yellow
pip install huggingface_hub

# Verificar instalación
Write-Host "Verificando instalación..." -ForegroundColor Yellow
try {
    python -c "import gpt_oss; print('✅ GPT-OSS importado correctamente')"
    Write-Host "✅ Todas las dependencias instaladas correctamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error verificando GPT-OSS: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 ¡GPT-OSS instalado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Descargar modelo: .\download-gpt-oss-real.ps1" -ForegroundColor Cyan
Write-Host "2. Iniciar servidor: python gpt-oss-server.py" -ForegroundColor Cyan
Write-Host "3. Probar: .\test-gpt-oss.ps1" -ForegroundColor Cyan
