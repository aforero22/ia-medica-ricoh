# Script para verificar el estado de la cuenta de OpenAI
$apiKey = "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"

$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type" = "application/json"
}

Write-Host "=== Verificando estado de la cuenta ==="
try {
    $accountResponse = Invoke-WebRequest -Uri "https://api.openai.com/v1/dashboard/billing/subscription" -Headers $headers -Method GET
    $account = $accountResponse.Content | ConvertFrom-Json
    
    Write-Host "Plan actual: $($account.plan)"
    Write-Host "Estado: $($account.status)"
    Write-Host "Límite de uso: $($account.hard_limit_usd)"
    Write-Host "Uso actual: $($account.system_hard_limit_usd)"
    
} catch {
    Write-Host "Error obteniendo información de la cuenta: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Detalles: $responseBody"
    }
}

Write-Host "`n=== Verificando uso actual ==="
try {
    $usageResponse = Invoke-WebRequest -Uri "https://api.openai.com/v1/dashboard/billing/usage" -Headers $headers -Method GET
    $usage = $usageResponse.Content | ConvertFrom-Json
    
    Write-Host "Uso total: $($usage.total_usage)"
    Write-Host "Límite diario: $($usage.daily_costs[0].line_items[0].cost)"
    
} catch {
    Write-Host "Error obteniendo información de uso: $($_.Exception.Message)"
} 