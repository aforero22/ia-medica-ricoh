# Demo Kubernetes para IA - Script de Parada (PowerShell)
# Este script detiene todos los port forwarding y limpia recursos

Write-Host "🛑 Deteniendo Demo Kubernetes para IA..." -ForegroundColor Yellow

# Detener procesos kubectl (port forwarding)
Write-Host "🔌 Deteniendo port forwarding..." -ForegroundColor Blue
try {
    Get-Process -Name "kubectl" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "  ✅ Port forwarding detenido" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️ No hay procesos kubectl corriendo" -ForegroundColor Yellow
}

# Detener jobs de PowerShell
Write-Host "🧹 Limpiando jobs de PowerShell..." -ForegroundColor Blue
Get-Job | Remove-Job -Force
Write-Host "  ✅ Jobs limpiados" -ForegroundColor Green

# Opción para limpiar servicios de Kubernetes
$cleanupChoice = Read-Host "¿Quieres eliminar los servicios de Kubernetes? (y/N)"
if ($cleanupChoice -eq "y" -or $cleanupChoice -eq "Y") {
    Write-Host "🗑️ Eliminando servicios de Kubernetes..." -ForegroundColor Blue
    kubectl delete -f k8s/
    Write-Host "  ✅ Servicios eliminados" -ForegroundColor Green
}

# Opción para detener Minikube
$minikubeChoice = Read-Host "¿Quieres detener Minikube? (y/N)"
if ($minikubeChoice -eq "y" -or $minikubeChoice -eq "Y") {
    Write-Host "⏹️ Deteniendo Minikube..." -ForegroundColor Blue
    minikube stop
    Write-Host "  ✅ Minikube detenido" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Demo detenida exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Para reiniciar la demo:" -ForegroundColor Cyan
Write-Host "  .\start-demo.ps1" -ForegroundColor White