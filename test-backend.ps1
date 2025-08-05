# Script para probar el endpoint del backend
$uri = "http://localhost:8091/codificar"
$headers = @{
    "Content-Type" = "application/json"
}
$body = @{
    diagnostico = "dolor de pecho"
    edad = 65
    sintomas = @("dolor torácico", "disnea")
} | ConvertTo-Json -Depth 3

Write-Host "Probando endpoint: $uri"
Write-Host "Body: $body"

try {
    $response = Invoke-WebRequest -Uri $uri -Method POST -Headers $headers -Body $body
    Write-Host "Status: $($response.StatusCode)"
    Write-Host "Response: $($response.Content)"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody"
    }
} 