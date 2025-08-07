# Script para convertir CIE-10 completa
# Autor: RICOH España
# Fecha: 2025

Write-Host "Convirtiendo base de datos CIE-10 completa..." -ForegroundColor Green

# Archivos de entrada y salida
$inputFile = "cie-10.json"
$outputFile = "medical-service-advanced/data/complete/cie10_complete_database.json"

# Verificar que existe el archivo de entrada
if (!(Test-Path $inputFile)) {
    Write-Host "Error: No se encuentra el archivo $inputFile" -ForegroundColor Red
    exit 1
}

Write-Host "Leyendo archivo: $inputFile" -ForegroundColor Yellow
Write-Host "Guardando en: $outputFile" -ForegroundColor Yellow

# Leer el archivo JSON completo
$cie10Data = Get-Content $inputFile | ConvertFrom-Json

Write-Host "Total de códigos encontrados: $($cie10Data.Count)" -ForegroundColor Cyan

# Crear estructura de datos para nuestra aplicación
$cie10Complete = @{
    metadata = @{
        fuente = "CIE-10-ES Ministerio de Sanidad España"
        url_oficial = "https://eciemaps.mscbs.gob.es/ecieMaps/browser/index_10_mc.html"
        version = "2024"
        descripcion = "Base de datos completa CIE-10-ES para codificación médica"
        total_codigos = $cie10Data.Count
        categorias = 22
        ultima_actualizacion = (Get-Date -Format "yyyy-MM-dd")
        archivo_origen = $inputFile
    }
    codigos = @{}
    sintomas_index = @{}
}

# Agrupar códigos por categorías principales
$categorias = @{}
$sintomasIndex = @{}

foreach ($item in $cie10Data) {
    $code = $item.code
    $description = $item.description
    $level = $item.level
    
    # Extraer categoría principal (primeros caracteres antes del punto)
    if ($code -match "^([A-Z]\d{2})") {
        $categoriaPrincipal = $matches[1]
    } elseif ($code -match "^([A-Z]\d{2}-[A-Z]\d{2})") {
        $categoriaPrincipal = $matches[1]
    } else {
        $categoriaPrincipal = $code
    }
    
    # Agrupar por categoría principal
    if (!$categorias.ContainsKey($categoriaPrincipal)) {
        $categorias[$categoriaPrincipal] = @{
            categoria = $description
            subcategorias = @{}
        }
    }
    
    # Agregar subcategoría
    $categorias[$categoriaPrincipal].subcategorias[$code] = $description
    
    # Crear índice de síntomas (palabras clave)
    $palabras = $description -split '\s+'
    foreach ($palabra in $palabras) {
        $palabraLimpia = $palabra.ToLower() -replace '[^a-záéíóúñ]', ''
        if ($palabraLimpia.Length -gt 3) {
            if (!$sintomasIndex.ContainsKey($palabraLimpia)) {
                $sintomasIndex[$palabraLimpia] = @()
            }
            if ($sintomasIndex[$palabraLimpia] -notcontains $code) {
                $sintomasIndex[$palabraLimpia] += $code
            }
        }
    }
}

# Agregar códigos a la estructura principal
$cie10Complete.codigos = $categorias
$cie10Complete.sintomas_index = $sintomasIndex

# Crear directorio si no existe
$outputDir = Split-Path $outputFile -Parent
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force
    Write-Host "Directorio creado: $outputDir" -ForegroundColor Green
}

# Guardar archivo JSON
$cie10Complete | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "Base de datos CIE-10 completa convertida exitosamente!" -ForegroundColor Green
Write-Host "Total de códigos: $($cie10Data.Count)" -ForegroundColor Cyan
Write-Host "Categorías principales: $($categorias.Count)" -ForegroundColor Cyan
Write-Host "Índice de síntomas: $($sintomasIndex.Count) palabras clave" -ForegroundColor Cyan
Write-Host "Archivo guardado: $outputFile" -ForegroundColor Cyan
Write-Host "Ejecuta kubectl rollout restart deployment/backend-ricoh -n medical-only para aplicar cambios" -ForegroundColor Yellow 