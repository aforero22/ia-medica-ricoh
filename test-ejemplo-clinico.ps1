# Script para probar con ejemplo clinico especifico
Write-Host "Probando con ejemplo clinico de hipertension..."

$uri = "http://localhost:8092/codificar"
$headers = @{
    "Content-Type" = "application/json"
}
$body = @{
    diagnostico = "paciente de 45 anos con presion arterial 160/100 mmHg"
    edad = 45
    sintomas = @("presion arterial elevada", "dolor de cabeza", "mareos")
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