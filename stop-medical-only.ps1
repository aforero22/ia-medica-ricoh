# Script para detener la demo medical-only

Write-Host "🛑 Deteniendo Demo Medical-Only..." -ForegroundColor Red

# Detener procesos kubectl
Write-Host "🛑 Deteniendo procesos kubectl..." -ForegroundColor Yellow
Get-Process -Name "kubectl" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Esperar un momento
Start-Sleep -Seconds 2

Write-Host "✅ Demo Medical-Only detenida" -ForegroundColor Green
Write-Host "💡 Para iniciar nuevamente: .\start-medical-only.ps1" -ForegroundColor Cyan 