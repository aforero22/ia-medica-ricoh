# Script para configurar la API key de OpenAI
# RICOH España - IA de Codificación Médica CIE-10-ES

Write-Host "🔑 Configurando API Key de OpenAI..." -ForegroundColor Green

# Verificar si el archivo config.env existe
if (Test-Path "config.env") {
    Write-Host "⚠️  El archivo config.env ya existe. ¿Deseas sobrescribirlo? (s/N)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -ne "s" -and $response -ne "S") {
        Write-Host "❌ Configuración cancelada" -ForegroundColor Red
        exit 1
    }
}

# Solicitar API key
Write-Host "📝 Ingresa tu API Key de OpenAI:" -ForegroundColor Cyan
$apiKey = Read-Host -AsSecureString

# Convertir a texto plano
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)
$plainApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Crear archivo config.env
$configContent = @"
# Configuración local - NO COMMITAR ESTE ARCHIVO
OPENAI_API_KEY=$plainApiKey
"@

$configContent | Out-File -FilePath "config.env" -Encoding UTF8

Write-Host "✅ API Key configurada correctamente en config.env" -ForegroundColor Green
Write-Host "🔒 El archivo config.env está excluido del control de versiones" -ForegroundColor Cyan
Write-Host "💡 Ahora puedes ejecutar: .\start-medical-only.ps1" -ForegroundColor Yellow 