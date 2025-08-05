# Script para probar la conexion entre frontend y backend
Write-Host "=== Probando Conexion Frontend-Backend ==="

# Probar endpoint de ejemplos aleatorios
Write-Host "1. Probando endpoint de ejemplos aleatorios..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8091/ejemplos-clinicos/aleatorio" -Method GET
    Write-Host "✅ Ejemplos aleatorios funcionando"
    Write-Host "Status: $($response.StatusCode)"
    Write-Host "Contenido: $($response.Content.Substring(0, 100))..."
} catch {
    Write-Host "❌ Error en ejemplos aleatorios: $($_.Exception.Message)"
}

# Probar endpoint de codificacion
Write-Host "`n2. Probando endpoint de codificacion..."
try {
    $body = @{
        diagnostico = "dolor de pecho"
        edad = 65
        sintomas = @("dolor toracico", "disnea")
    } | ConvertTo-Json -Depth 3

    $response = Invoke-WebRequest -Uri "http://localhost:8091/codificar" -Method POST -Body $body -ContentType "application/json"
    Write-Host "✅ Codificacion funcionando"
    Write-Host "Status: $($response.StatusCode)"
} catch {
    Write-Host "❌ Error en codificacion: $($_.Exception.Message)"
}

# Probar frontend
Write-Host "`n3. Probando frontend..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -Method GET
    Write-Host "✅ Frontend funcionando"
    Write-Host "Status: $($response.StatusCode)"
} catch {
    Write-Host "❌ Error en frontend: $($_.Exception.Message)"
}

Write-Host "`n=== Fin de Pruebas ==="
Write-Host "Frontend disponible en: http://localhost:8081"
Write-Host "Backend disponible en: http://localhost:8091" 