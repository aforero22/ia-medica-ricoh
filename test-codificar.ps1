# Script para probar el endpoint de codificacion
Write-Host "Probando endpoint de codificacion..."

$uri = "http://localhost:8092/codificar"
$headers = @{
    "Content-Type" = "application/json"
}
$body = @{
    diagnostico = "dolor de pecho"
    edad = 65
    sintomas = @("dolor toracico", "disnea")
} | ConvertTo-Json -Depth 3

Write-Host "URI: $uri"
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