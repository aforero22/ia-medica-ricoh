# Script de limpieza para namespace medical-only
# Limpia todos los recursos del namespace medical-only

Write-Host "🧹 Limpiando namespace medical-only..." -ForegroundColor Yellow

# Detener port forwarding
Write-Host "🔌 Deteniendo port forwarding..." -ForegroundColor Blue
Get-Job | Where-Object {$_.Name -like "*kubectl*"} | Stop-Job
Get-Job | Where-Object {$_.Name -like "*kubectl*"} | Remove-Job

# Eliminar recursos del namespace
Write-Host "🗑️ Eliminando recursos del namespace medical-only..." -ForegroundColor Blue

# Eliminar deployments
kubectl delete deployment medical-service -n medical-only --ignore-not-found=true
kubectl delete deployment frontend-app -n medical-only --ignore-not-found=true

# Eliminar services
kubectl delete service medical-service -n medical-only --ignore-not-found=true
kubectl delete service frontend-service -n medical-only --ignore-not-found=true

# Eliminar HPA
kubectl delete hpa medical-service-hpa -n medical-only --ignore-not-found=true

# Mostrar estado final
Write-Host ""
Write-Host "📊 Estado final del namespace medical-only:" -ForegroundColor Cyan
kubectl get all -n medical-only

Write-Host ""
Write-Host "✅ Limpieza completada" -ForegroundColor Green
Write-Host "💡 Para eliminar completamente el namespace, ejecuta: kubectl delete namespace medical-only" -ForegroundColor Yellow 