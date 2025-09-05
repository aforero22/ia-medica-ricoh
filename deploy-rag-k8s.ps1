# Script de despliegue para IA Medica CIE-10-ES con RAG
# Sistema hibrido: RAG + IA para maxima precision

Write-Host "Desplegando IA Medica CIE-10-ES con RAG..." -ForegroundColor Green

# Verificar que Minikube este ejecutandose
Write-Host "Verificando Minikube..." -ForegroundColor Yellow
$minikubeStatus = minikube status --format=json | ConvertFrom-Json
if ($minikubeStatus.Host -ne "Running") {
    Write-Host "Minikube no esta ejecutandose. Iniciando..." -ForegroundColor Red
    minikube start
} else {
    Write-Host "Minikube esta ejecutandose" -ForegroundColor Green
}

# Verificar que Docker este disponible
Write-Host "Verificando Docker..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    Write-Host "Docker esta disponible" -ForegroundColor Green
} catch {
    Write-Host "Docker no esta disponible. Iniciando Docker Desktop..." -ForegroundColor Red
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Start-Sleep -Seconds 30
}

# Verificar archivos Excel
Write-Host "Verificando archivos Excel..." -ForegroundColor Yellow
$diagnosticosFile = "Diagnosticos_ES2024_TablaReferencia_30_06_2023_9096243130459179657.xlsx"
$procedimientosFile = "Procedimientos_ES2024_TablaReferencia_30062023_5537663830978566667.xlsx"

if (-not (Test-Path $diagnosticosFile)) {
    Write-Host "Archivo de diagnosticos no encontrado: $diagnosticosFile" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $procedimientosFile)) {
    Write-Host "Archivo de procedimientos no encontrado: $procedimientosFile" -ForegroundColor Red
    exit 1
}

Write-Host "Archivos Excel verificados" -ForegroundColor Green

# Crear namespace
Write-Host "Creando namespace medical-rag..." -ForegroundColor Yellow
kubectl create namespace medical-rag --dry-run=client -o yaml | kubectl apply -f -

# Crear secret para OpenAI API Key
Write-Host "Configurando secret de OpenAI..." -ForegroundColor Yellow
if (Test-Path "config.env") {
    $apiKey = (Get-Content "config.env" | Where-Object { $_ -match "OPENAI_API_KEY=" }) -replace "OPENAI_API_KEY=", ""
    if ($apiKey) {
        kubectl create secret generic openai-secret --from-literal=api-key=$apiKey -n medical-rag --dry-run=client -o yaml | kubectl apply -f -
        Write-Host "Secret de OpenAI configurado" -ForegroundColor Green
    } else {
        Write-Host "No se encontro OPENAI_API_KEY en config.env" -ForegroundColor Yellow
    }
} else {
    Write-Host "Archivo config.env no encontrado" -ForegroundColor Yellow
}

# Crear Dockerfile para el backend
Write-Host "Creando Dockerfile del backend..." -ForegroundColor Yellow
$dockerfileBackend = @"
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Instalar dependencias de Python
RUN pip install fastapi uvicorn requests python-dotenv pandas numpy scikit-learn openpyxl

# Copiar archivos del proyecto
COPY backend_rag_integrated.py /app/
COPY rag_cie10_optimized.py /app/
COPY $diagnosticosFile /app/
COPY $procedimientosFile /app/

# Exponer puerto
EXPOSE 9999

# Comando de inicio
CMD ["python", "backend_rag_integrated.py"]
"@

$dockerfileBackend | Out-File -FilePath "Dockerfile.backend-rag" -Encoding UTF8

# Construir imagen del backend
Write-Host "Construyendo imagen del backend..." -ForegroundColor Yellow
docker build -f Dockerfile.backend-rag -t backend-rag:latest .
if ($LASTEXITCODE -eq 0) {
    Write-Host "Imagen del backend construida" -ForegroundColor Green
} else {
    Write-Host "Error construyendo imagen del backend" -ForegroundColor Red
    exit 1
}

# Crear Dockerfile para el frontend
Write-Host "Creando Dockerfile del frontend..." -ForegroundColor Yellow
$dockerfileFrontend = @"
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias
RUN pip install flask

# Copiar archivos del frontend
COPY frontend_rag.html /app/templates/
COPY static/ /app/static/
COPY app.py /app/

EXPOSE 8091

CMD ["python", "app.py"]
"@

$dockerfileFrontend | Out-File -FilePath "Dockerfile.frontend-rag" -Encoding UTF8

# Construir imagen del frontend
Write-Host "Construyendo imagen del frontend..." -ForegroundColor Yellow
docker build -f Dockerfile.frontend-rag -t frontend-rag:latest .
if ($LASTEXITCODE -eq 0) {
    Write-Host "Imagen del frontend construida" -ForegroundColor Green
} else {
    Write-Host "Error construyendo imagen del frontend" -ForegroundColor Red
    exit 1
}

# Crear archivo de deployment del backend
Write-Host "Creando deployment del backend..." -ForegroundColor Yellow
$backendYaml = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-rag
  namespace: medical-rag
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend-rag
  template:
    metadata:
      labels:
        app: backend-rag
    spec:
      containers:
      - name: backend
        image: backend-rag:latest
        ports:
        - containerPort: 9999
        env:
        - name: OLLAMA_HOST
          value: "host.minikube.internal"
        - name: OLLAMA_PORT
          value: "11434"
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
"@

$backendYaml | Out-File -FilePath "backend-deployment.yaml" -Encoding UTF8

# Crear archivo de servicio del backend
$backendServiceYaml = @"
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: medical-rag
spec:
  selector:
    app: backend-rag
  ports:
  - protocol: TCP
    port: 9999
    targetPort: 9999
  type: ClusterIP
"@

$backendServiceYaml | Out-File -FilePath "backend-service.yaml" -Encoding UTF8

# Crear archivo de deployment del frontend
$frontendYaml = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-rag
  namespace: medical-rag
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend-rag
  template:
    metadata:
      labels:
        app: frontend-rag
    spec:
      containers:
      - name: frontend
        image: frontend-rag:latest
        ports:
        - containerPort: 8091
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
"@

$frontendYaml | Out-File -FilePath "frontend-deployment.yaml" -Encoding UTF8

# Crear archivo de servicio del frontend
$frontendServiceYaml = @"
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: medical-rag
spec:
  selector:
    app: frontend-rag
  ports:
  - protocol: TCP
    port: 8091
    targetPort: 8091
  type: ClusterIP
"@

$frontendServiceYaml | Out-File -FilePath "frontend-service.yaml" -Encoding UTF8

# Aplicar deployments y servicios
Write-Host "Aplicando deployments..." -ForegroundColor Yellow
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# Esperar a que los pods esten listos
Write-Host "Esperando a que los pods esten listos..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=backend-rag -n medical-rag --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend-rag -n medical-rag --timeout=300s

# Configurar port-forwarding
Write-Host "Configurando port-forwarding..." -ForegroundColor Yellow

# Iniciar port-forwarding del backend en background
Start-Job -ScriptBlock {
    kubectl port-forward -n medical-rag service/backend-service 9999:9999
} | Out-Null

# Iniciar port-forwarding del frontend en background
Start-Job -ScriptBlock {
    kubectl port-forward -n medical-rag service/frontend-service 8083:8091
} | Out-Null

# Esperar un momento para que el port-forwarding se establezca
Start-Sleep -Seconds 5

# Verificar estado
Write-Host "Verificando estado del despliegue..." -ForegroundColor Yellow
kubectl get pods -n medical-rag
kubectl get services -n medical-rag

# Verificar conectividad
Write-Host "Verificando conectividad..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:9999/health" -Method Get -TimeoutSec 10
    Write-Host "Backend respondiendo: $($healthResponse | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "Error conectando al backend: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Despliegue completado!" -ForegroundColor Green
Write-Host ""
Write-Host "URLs de acceso:" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:8083" -ForegroundColor White
Write-Host "   Backend API: http://localhost:9999" -ForegroundColor White
Write-Host "   Health Check: http://localhost:9999/health" -ForegroundColor White
Write-Host "   Modelos: http://localhost:9999/models" -ForegroundColor White
Write-Host "   RAG Search: http://localhost:9999/rag/search?query=diabetes" -ForegroundColor White
Write-Host ""
Write-Host "Comandos utiles:" -ForegroundColor Cyan
Write-Host "   Ver logs: kubectl logs -f deployment/backend-rag -n medical-rag" -ForegroundColor White
Write-Host "   Ver pods: kubectl get pods -n medical-rag" -ForegroundColor White
Write-Host "   Ver servicios: kubectl get services -n medical-rag" -ForegroundColor White
Write-Host ""
Write-Host "El sistema RAG esta listo para usar con maxima precision!" -ForegroundColor Green
