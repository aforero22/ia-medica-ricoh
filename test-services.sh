#!/bin/bash

# Script de verificación de salud para Codificación Médica CIE-10
# Verifica que el servicio médico esté funcionando correctamente

echo "🔍 Verificando salud del servicio de Codificación Médica CIE-10..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para verificar servicio
check_service() {
    local service_name=$1
    local url=$2
    local port=$3
    
    echo -e "${BLUE}Verificando $service_name...${NC}"
    
    # Verificar si el puerto está abierto
    if nc -z localhost $port 2>/dev/null; then
        echo -e "  ✅ Puerto $port está abierto"
    else
        echo -e "  ❌ Puerto $port no está abierto"
        return 1
    fi
    
    # Verificar health endpoint
    if curl -s -f "$url/health" >/dev/null; then
        echo -e "  ✅ Health check exitoso"
        
        # Obtener información del servicio
        local health_info=$(curl -s "$url/health")
        echo -e "  📊 Estado: $(echo $health_info | jq -r '.status' 2>/dev/null || echo 'unknown')"
        echo -e "  📊 Modelo: $(echo $health_info | jq -r '.model_version' 2>/dev/null || echo 'unknown')"
        
        return 0
    else
        echo -e "  ❌ Health check falló"
        return 1
    fi
}

# Verificar servicio médico
echo -e "\n${YELLOW}=== Servicio Médico ===${NC}"

medical_ok=false

if check_service "Medical Service" "http://localhost:8002" 8002; then
    medical_ok=true
fi



# Verificar frontend
echo -e "\n${YELLOW}=== Frontend ===${NC}"
if check_service "Frontend" "http://localhost:8080" 8080; then
    frontend_ok=true
else
    frontend_ok=false
fi

# Verificar Kubernetes (namespace medical-only)
echo -e "\n${YELLOW}=== Estado de Kubernetes (namespace medical-only) ===${NC}"
if kubectl get pods --no-headers -n medical-only 2>/dev/null | grep -q "Running"; then
    echo -e "  ✅ Pods están corriendo"
    
    # Mostrar pods
    echo -e "  📊 Pods activos:"
    kubectl get pods --no-headers -n medical-only | while read line; do
        echo -e "    $line"
    done
else
    echo -e "  ❌ No hay pods corriendo en namespace medical-only"
fi

# Resumen
echo -e "\n${YELLOW}=== Resumen ===${NC}"
if $medical_ok; then
    echo -e "  ✅ Medical Service: ${GREEN}OK${NC}"
else
    echo -e "  ❌ Medical Service: ${RED}FALLÓ${NC}"
fi



if $frontend_ok; then
    echo -e "  ✅ Frontend: ${GREEN}OK${NC}"
else
    echo -e "  ❌ Frontend: ${RED}FALLÓ${NC}"
fi

# Comandos útiles
echo -e "\n${YELLOW}=== Comandos Útiles ===${NC}"
echo -e "  🌐 Frontend: http://localhost:8080"
echo -e "  🛡️ Fraud API: http://localhost:8001"
echo -e "  🏥 Medical API: http://localhost:8002"

echo -e "  📊 Ver pods: kubectl get pods"
echo -e "  📊 Ver logs: kubectl logs -f deployment/fraud-service"
echo -e "  📊 Ver métricas: kubectl top pods"

# Verificar si todo está OK
if $medical_ok && $frontend_ok; then
    echo -e "\n${GREEN}🎉 ¡El servicio de Codificación Médica está funcionando correctamente!${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️ El servicio médico no está funcionando correctamente${NC}"
    echo -e "Ejecuta './start-demo.ps1' para reiniciar el servicio"
    exit 1
fi 