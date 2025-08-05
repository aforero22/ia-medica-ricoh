# Script para actualizar la API key en el deployment
Write-Host "=== Actualizar API Key en Kubernetes ==="

# Nueva API key (reemplaza con tu nueva key)
$newApiKey = "sk-..."  # Reemplaza con tu nueva API key

Write-Host "Para actualizar la API key:"
Write-Host "1. Ve a https://platform.openai.com/api-keys"
Write-Host "2. Crea una nueva API key"
Write-Host "3. Reemplaza la variable 'newApiKey' en este script"
Write-Host "4. Ejecuta el siguiente comando:"
Write-Host ""
Write-Host "kubectl patch deployment backend-ricoh -n medical-only -p '{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"backend-ricoh\",\"env\":[{\"name\":\"OPENAI_API_KEY\",\"value\":\"$newApiKey\"}]}]}}}}'"
Write-Host ""
Write-Host "O edita el archivo k8s/backend-ricoh-deployment.yaml y ejecuta:"
Write-Host "kubectl apply -f k8s/backend-ricoh-deployment.yaml" 