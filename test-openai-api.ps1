# Script para verificar la API key de OpenAI
$apiKey = "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"

# Headers para la API de OpenAI
$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type" = "application/json"
}

Write-Host "=== Verificando modelos disponibles ==="
try {
    $modelsResponse = Invoke-WebRequest -Uri "https://api.openai.com/v1/models" -Headers $headers -Method GET
    $models = $modelsResponse.Content | ConvertFrom-Json
    
    Write-Host "Modelos disponibles:"
    $models.data | Where-Object { $_.id -like "*gpt*" } | ForEach-Object {
        Write-Host "- $($_.id) (creado: $($_.created))"
    }
} catch {
    Write-Host "Error obteniendo modelos: $($_.Exception.Message)"
}

Write-Host "`n=== Probando modelo gpt-4o ==="
$testBody = @{
    model = "gpt-4o"
    messages = @(
        @{
            role = "user"
            content = "Hola, ¿puedes responder con 'OK'?"
        }
    )
    max_tokens = 10
} | ConvertTo-Json -Depth 3

try {
    $response = Invoke-WebRequest -Uri "https://api.openai.com/v1/chat/completions" -Headers $headers -Method POST -Body $testBody
    Write-Host "✅ gpt-4o funciona correctamente"
    Write-Host "Respuesta: $($response.Content)"
} catch {
    Write-Host "❌ Error con gpt-4o: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Detalles del error: $responseBody"
    }
}

Write-Host "`n=== Probando modelo gpt-4 ==="
$testBody2 = @{
    model = "gpt-4"
    messages = @(
        @{
            role = "user"
            content = "Hola, ¿puedes responder con 'OK'?"
        }
    )
    max_tokens = 10
} | ConvertTo-Json -Depth 3

try {
    $response2 = Invoke-WebRequest -Uri "https://api.openai.com/v1/chat/completions" -Headers $headers -Method POST -Body $testBody2
    Write-Host "✅ gpt-4 funciona correctamente"
    Write-Host "Respuesta: $($response2.Content)"
} catch {
    Write-Host "❌ Error con gpt-4: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Detalles del error: $responseBody"
    }
} 