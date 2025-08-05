# Script para crear base de datos con ejemplos clínicos
Write-Host "=== Creando Base de Datos CIE-10-ES con Ejemplos Clínicos ==="

# Crear directorio
$dataDir = "medical-service-advanced/data/official"
if (!(Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force
}

# Base de datos expandida
$cie10Expanded = @{
    metadata = @{
        fuente = "CIE-10-ES Ministerio de Sanidad España"
        version = "2024"
        descripcion = "Base de datos expandida CIE-10-ES con ejemplos clínicos"
        total_codigos = 0
        categorias = @()
    }
    categorias = @{}
    codigos = @{}
    sintomas_index = @{}
}

# Categorías principales
$categorias = @{
    "I00-I99" = "Enfermedades del sistema circulatorio"
    "E00-E89" = "Enfermedades endocrinas, nutricionales y metabólicas"
    "J00-J99" = "Enfermedades del sistema respiratorio"
    "K00-K95" = "Enfermedades del sistema digestivo"
    "M00-M99" = "Enfermedades del sistema osteomuscular"
    "N00-N99" = "Enfermedades del sistema genitourinario"
    "F00-F99" = "Trastornos mentales"
    "G00-G99" = "Enfermedades del sistema nervioso"
    "H00-H59" = "Enfermedades del ojo"
    "L00-L99" = "Enfermedades de la piel"
    "R00-R99" = "Síntomas y signos"
}

# Agregar categorías
foreach ($codigo in $categorias.Keys) {
    $cie10Expanded.categorias[$codigo] = @{
        nombre = $categorias[$codigo]
        codigos = @{}
    }
}

# Ejemplos clínicos (20+ ejemplos)
$ejemplosClinicos = @{
    "I10" = @{
        descripcion = "Hipertensión esencial (primaria)"
        categoria = "I00-I99"
        sintomas = @("Presión arterial elevada", "Dolor de cabeza", "Mareos")
        ejemplos = @(
            "Paciente de 45 años con presión arterial 160/100 mmHg",
            "Paciente de 60 años con hipertensión de 10 años de evolución"
        )
    }
    "I21.4" = @{
        descripcion = "Infarto agudo de miocardio no transmural"
        categoria = "I00-I99"
        sintomas = @("Dolor torácico", "Disnea", "Sudoración")
        ejemplos = @(
            "Paciente de 65 años con dolor torácico de 2 horas",
            "Paciente diabético con elevación de troponinas"
        )
    }
    "I50.0" = @{
        descripcion = "Insuficiencia cardíaca congestiva"
        categoria = "I00-I99"
        sintomas = @("Disnea", "Edema", "Fatiga")
        ejemplos = @(
            "Paciente de 70 años con disnea progresiva",
            "Paciente con antecedentes de infarto"
        )
    }
    "E11.9" = @{
        descripcion = "Diabetes mellitus no insulinodependiente"
        categoria = "E00-E89"
        sintomas = @("Poliuria", "Polidipsia", "Pérdida de peso")
        ejemplos = @(
            "Paciente de 50 años con glucemia en ayunas de 180 mg/dL",
            "Paciente con antecedentes familiares de diabetes"
        )
    }
    "E66.9" = @{
        descripcion = "Obesidad, no especificada"
        categoria = "E00-E89"
        sintomas = @("Aumento de peso", "Dificultad para moverse")
        ejemplos = @(
            "Paciente de 40 años con IMC de 32 kg/m²",
            "Paciente con obesidad de 5 años de evolución"
        )
    }
    "J44.9" = @{
        descripcion = "EPOC, no especificada"
        categoria = "J00-J99"
        sintomas = @("Tos crónica", "Disnea", "Producción de esputo")
        ejemplos = @(
            "Paciente fumador de 55 años con tos progresiva",
            "Paciente con antecedentes de EPOC"
        )
    }
    "J18.9" = @{
        descripcion = "Neumonía, organismo no especificado"
        categoria = "J00-J99"
        sintomas = @("Fiebre", "Tos", "Disnea", "Dolor torácico")
        ejemplos = @(
            "Paciente de 35 años con fiebre de 39°C",
            "Paciente anciano con neumonía adquirida"
        )
    }
    "K25.9" = @{
        descripcion = "Úlcera gástrica, no especificada"
        categoria = "K00-K95"
        sintomas = @("Dolor epigástrico", "Náuseas", "Pérdida de apetito")
        ejemplos = @(
            "Paciente de 45 años con dolor epigástrico de 3 meses",
            "Paciente con antecedentes de úlcera"
        )
    }
    "K59.0" = @{
        descripcion = "Estreñimiento"
        categoria = "K00-K95"
        sintomas = @("Dificultad para defecar", "Heces duras", "Dolor abdominal")
        ejemplos = @(
            "Paciente de 60 años con estreñimiento de 2 semanas",
            "Paciente con cambio en hábitos intestinales"
        )
    }
    "M79.3" = @{
        descripcion = "Dolor en el brazo"
        categoria = "M00-M99"
        sintomas = @("Dolor en extremidad superior", "Limitación de movimientos")
        ejemplos = @(
            "Paciente de 50 años con dolor en brazo derecho de 1 mes",
            "Paciente con dolor irradiado desde cuello"
        )
    }
    "M54.5" = @{
        descripcion = "Dolor lumbar bajo"
        categoria = "M00-M99"
        sintomas = @("Dolor en región lumbar", "Rigidez", "Limitación de movimientos")
        ejemplos = @(
            "Paciente de 40 años con dolor lumbar de 2 semanas",
            "Paciente con lumbalgia mecánica tras levantar peso"
        )
    }
    "N18.9" = @{
        descripcion = "Enfermedad renal crónica, no especificada"
        categoria = "N00-N99"
        sintomas = @("Fatiga", "Edema", "Hipertensión")
        ejemplos = @(
            "Paciente de 65 años con creatinina elevada",
            "Paciente diabético con deterioro progresivo de función renal"
        )
    }
    "N39.0" = @{
        descripcion = "Infección del tracto urinario"
        categoria = "N00-N99"
        sintomas = @("Disuria", "Frecuencia urinaria", "Dolor suprapúbico")
        ejemplos = @(
            "Paciente de 30 años con disuria y frecuencia urinaria",
            "Paciente con síntomas urinarios y urocultivo positivo"
        )
    }
    "F41.1" = @{
        descripcion = "Trastorno de ansiedad generalizada"
        categoria = "F00-F99"
        sintomas = @("Ansiedad", "Preocupación excesiva", "Insomnio")
        ejemplos = @(
            "Paciente de 35 años con ansiedad por 6 meses",
            "Paciente con síntomas que interfieren en su vida diaria"
        )
    }
    "F32.1" = @{
        descripcion = "Episodio depresivo moderado"
        categoria = "F00-F99"
        sintomas = @("Tristeza", "Pérdida de interés", "Alteraciones del sueño")
        ejemplos = @(
            "Paciente de 45 años con tristeza por 3 semanas",
            "Paciente con síntomas depresivos que afectan funcionamiento"
        )
    }
    "G40.9" = @{
        descripcion = "Epilepsia, no especificada"
        categoria = "G00-G99"
        sintomas = @("Convulsiones", "Pérdida de consciencia", "Aura")
        ejemplos = @(
            "Paciente de 25 años con crisis convulsivas generalizadas",
            "Paciente con antecedentes de epilepsia"
        )
    }
    "G93.1" = @{
        descripcion = "Lesión cerebral anóxica"
        categoria = "G00-G99"
        sintomas = @("Alteración de consciencia", "Déficit neurológico")
        ejemplos = @(
            "Paciente post-paro cardíaco con alteración de consciencia",
            "Paciente con hipoxia cerebral tras asfixia"
        )
    }
    "H25.9" = @{
        descripcion = "Catarata senil, no especificada"
        categoria = "H00-H59"
        sintomas = @("Visión borrosa", "Dificultad para ver de noche", "Deslumbramiento")
        ejemplos = @(
            "Paciente de 70 años con visión borrosa progresiva",
            "Paciente con catarata senil bilateral"
        )
    }
    "H40.9" = @{
        descripcion = "Glaucoma, no especificado"
        categoria = "H00-H59"
        sintomas = @("Dolor ocular", "Visión borrosa", "Halos alrededor de luces")
        ejemplos = @(
            "Paciente de 60 años con dolor ocular y visión borrosa",
            "Paciente con presión intraocular elevada"
        )
    }
    "L23.9" = @{
        descripcion = "Dermatitis alérgica de contacto"
        categoria = "L00-L99"
        sintomas = @("Erupción cutánea", "Prurito", "Enrojecimiento")
        ejemplos = @(
            "Paciente de 30 años con erupción en manos tras contacto",
            "Paciente con dermatitis de contacto por níquel"
        )
    }
    "L30.9" = @{
        descripcion = "Dermatitis, no especificada"
        categoria = "L00-L99"
        sintomas = @("Erupción", "Prurito", "Inflamación")
        ejemplos = @(
            "Paciente de 40 años con erupción pruriginosa en tronco",
            "Paciente con dermatitis atópica en pliegues"
        )
    }
    "R50.9" = @{
        descripcion = "Fiebre, no especificada"
        categoria = "R00-R99"
        sintomas = @("Temperatura elevada", "Escalofríos", "Malestar general")
        ejemplos = @(
            "Paciente de 35 años con fiebre de 38.5°C de 2 días",
            "Paciente con fiebre sin foco aparente"
        )
    }
    "R07.9" = @{
        descripcion = "Dolor en el pecho, no especificado"
        categoria = "R00-R99"
        sintomas = @("Dolor torácico", "Molestia precordial")
        ejemplos = @(
            "Paciente de 50 años con dolor torácico atípico",
            "Paciente con dolor en pecho de origen no cardíaco"
        )
    }
}

# Agregar ejemplos clínicos a la base de datos
foreach ($codigo in $ejemplosClinicos.Keys) {
    $ejemplo = $ejemplosClinicos[$codigo]
    
    $cie10Expanded.codigos[$codigo] = @{
        descripcion = $ejemplo.descripcion
        categoria = $ejemplo.categoria
        sintomas_relacionados = $ejemplo.sintomas
        ejemplos_clinicos = $ejemplo.ejemplos
    }
    
    $cie10Expanded.categorias[$ejemplo.categoria].codigos[$codigo] = $ejemplo.descripcion
    
    # Agregar al índice de síntomas
    foreach ($sintoma in $ejemplo.sintomas) {
        if (!$cie10Expanded.sintomas_index.ContainsKey($sintoma)) {
            $cie10Expanded.sintomas_index[$sintoma] = @()
        }
        $cie10Expanded.sintomas_index[$sintoma] += $codigo
    }
}

# Calcular totales
$cie10Expanded.metadata.total_codigos = $cie10Expanded.codigos.Count
$cie10Expanded.metadata.categorias = $cie10Expanded.categorias.Count

# Guardar base de datos expandida
$outputFile = "$dataDir/cie10_expanded_database.json"
$cie10Expanded | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "✅ Base de datos expandida guardada en: $outputFile"
Write-Host "📊 Total de códigos: $($cie10Expanded.metadata.total_codigos)"
Write-Host "📊 Total de categorías: $($cie10Expanded.metadata.categorias)"
Write-Host "📊 Ejemplos clínicos incluidos: $($ejemplosClinicos.Count)"

Write-Host "`n=== Instrucciones para usar la base de datos expandida ==="
Write-Host "1. La base de datos se ha guardado en: $outputFile"
Write-Host "2. Para usar esta base de datos, actualiza el archivo:"
Write-Host "   medical-service-advanced/models/cie10_database.py" 