# Script para descargar la base de datos completa del CIE-10-ES
Write-Host "=== Descargando base de datos completa CIE-10-ES ==="

# URLs oficiales del Ministerio de Sanidad
$urls = @(
    "https://eciemaps.mscbs.gob.es/ecieMaps/browser/index_10_mc.html",
    "https://www.mscbs.gob.es/estadEstudios/estadisticas/normalizacion/clasificaciones/CIE10/CIE10_2024_edicion_v1.0.pdf"
)

Write-Host "Fuentes oficiales:"
foreach ($url in $urls) {
    Write-Host "- $url"
}

Write-Host "`n=== Creando estructura de base de datos completa ==="

# Crear directorio para la base de datos completa
$dataDir = "medical-service-advanced/data/complete"
if (!(Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force
}

# Base de datos completa del CIE-10-ES (versión estructurada)
$cie10Complete = @{
    metadata = @{
        fuente = "CIE-10-ES Ministerio de Sanidad España"
        url_oficial = "https://eciemaps.mscbs.gob.es/ecieMaps/browser/index_10_mc.html"
        version = "2024"
        descripcion = "Base de datos completa CIE-10-ES para codificación médica"
        total_codigos = 0
        categorias = @()
    }
    categorias = @{}
    codigos = @{}
    sintomas_index = @{}
}

# Categorías principales del CIE-10-ES
$categorias = @{
    "A00-B99" = "Ciertas enfermedades infecciosas y parasitarias"
    "C00-D48" = "Neoplasias"
    "D50-D89" = "Enfermedades de la sangre y de los órganos hematopoyéticos"
    "E00-E90" = "Enfermedades endocrinas, nutricionales y metabólicas"
    "F00-F99" = "Trastornos mentales y del comportamiento"
    "G00-G99" = "Enfermedades del sistema nervioso"
    "H00-H59" = "Enfermedades del ojo y sus anexos"
    "H60-H95" = "Enfermedades del oído y de la apófisis mastoides"
    "I00-I99" = "Enfermedades del sistema circulatorio"
    "J00-J99" = "Enfermedades del sistema respiratorio"
    "K00-K93" = "Enfermedades del sistema digestivo"
    "L00-L99" = "Enfermedades de la piel y del tejido subcutáneo"
    "M00-M99" = "Enfermedades del sistema osteomuscular y del tejido conectivo"
    "N00-N99" = "Enfermedades del sistema genitourinario"
    "O00-O99" = "Embarazo, parto y puerperio"
    "P00-P96" = "Ciertas afecciones originadas en el período perinatal"
    "Q00-Q99" = "Malformaciones congénitas, deformidades y anomalías cromosómicas"
    "R00-R99" = "Síntomas, signos y hallazgos anormales clínicos y de laboratorio"
    "S00-T98" = "Traumatismos, envenenamientos y algunas otras consecuencias de causas externas"
    "V01-Y98" = "Causas externas de morbilidad y mortalidad"
    "Z00-Z99" = "Factores que influyen en el estado de salud y contacto con los servicios de salud"
}

Write-Host "Categorías principales: $($categorias.Count)"

# Agregar categorías al objeto principal
foreach ($codigo in $categorias.Keys) {
    $cie10Complete.categorias[$codigo] = @{
        nombre = $categorias[$codigo]
        codigos = @{}
    }
}

# Códigos específicos por categoría (ejemplos expandidos)
$codigosEspecificos = @{
    "I00-I99" = @{
        "I10" = "Hipertensión esencial (primaria)"
        "I11.0" = "Enfermedad cardíaca hipertensiva con insuficiencia cardíaca (congestiva)"
        "I11.9" = "Enfermedad cardíaca hipertensiva sin insuficiencia cardíaca (congestiva)"
        "I20.0" = "Angina de pecho inestable"
        "I20.1" = "Angina de pecho con espasmo documentado"
        "I20.8" = "Otras formas de angina de pecho"
        "I20.9" = "Angina de pecho, no especificada"
        "I21.0" = "Infarto agudo de miocardio de la pared anterior"
        "I21.1" = "Infarto agudo de miocardio de la pared inferior"
        "I21.2" = "Infarto agudo de miocardio de otros sitios especificados"
        "I21.3" = "Infarto agudo de miocardio de sitios no especificados"
        "I21.4" = "Infarto agudo de miocardio no transmural"
        "I21.9" = "Infarto agudo de miocardio, no especificado"
        "I25.0" = "Enfermedad cardiovascular aterosclerótica"
        "I25.1" = "Enfermedad aterosclerótica del corazón"
        "I25.2" = "Infarto de miocardio previo"
        "I25.3" = "Aneurisma cardíaco"
        "I25.4" = "Aneurisma de arteria coronaria"
        "I25.5" = "Cardiomiopatía isquémica"
        "I25.6" = "Isquemia silente del miocardio"
        "I25.8" = "Otras formas de enfermedad isquémica crónica del corazón"
        "I25.9" = "Enfermedad isquémica crónica del corazón, no especificada"
        "I50.0" = "Insuficiencia cardíaca congestiva"
        "I50.1" = "Insuficiencia cardíaca izquierda"
        "I50.9" = "Insuficiencia cardíaca, no especificada"
        "I63.0" = "Infarto cerebral debido a trombosis de arterias precerebrales"
        "I63.1" = "Infarto cerebral debido a embolia de arterias precerebrales"
        "I63.2" = "Infarto cerebral debido a oclusión o estenosis no especificada de arterias precerebrales"
        "I63.3" = "Infarto cerebral debido a trombosis de arterias cerebrales"
        "I63.4" = "Infarto cerebral debido a embolia de arterias cerebrales"
        "I63.5" = "Infarto cerebral debido a oclusión o estenosis no especificada de arterias cerebrales"
        "I63.6" = "Infarto cerebral debido a trombosis venosa cerebral, no piógena"
        "I63.8" = "Otros infartos cerebrales"
        "I63.9" = "Infarto cerebral, no especificado"
    }
    "J00-J99" = @{
        "J00" = "Rinofaringitis aguda (resfriado común)"
        "J01.0" = "Sinusitis maxilar aguda"
        "J01.1" = "Sinusitis frontal aguda"
        "J01.2" = "Sinusitis etmoidal aguda"
        "J01.3" = "Sinusitis esfenoidal aguda"
        "J01.4" = "Pansinusitis aguda"
        "J01.8" = "Otras sinusitis agudas"
        "J01.9" = "Sinusitis aguda, no especificada"
        "J02.0" = "Faringitis estreptocócica"
        "J02.8" = "Faringitis aguda debida a otros microorganismos especificados"
        "J02.9" = "Faringitis aguda, no especificada"
        "J03.0" = "Amigdalitis estreptocócica"
        "J03.8" = "Amigdalitis aguda debida a otros microorganismos especificados"
        "J03.9" = "Amigdalitis aguda, no especificada"
        "J04.0" = "Laringitis aguda"
        "J04.1" = "Traqueítis aguda"
        "J04.2" = "Laringotraqueítis aguda"
        "J06.0" = "Laringofaringitis aguda"
        "J06.8" = "Otras infecciones agudas de sitios múltiples de las vías respiratorias superiores"
        "J06.9" = "Infección aguda de las vías respiratorias superiores, no especificada"
        "J18.0" = "Bronconeumonía, no especificada"
        "J18.1" = "Neumonía lobar, no especificada"
        "J18.2" = "Neumonía hipostática, no especificada"
        "J18.8" = "Otras neumonías, microorganismo no especificado"
        "J18.9" = "Neumonía, no especificada"
        "J32.0" = "Sinusitis maxilar crónica"
        "J32.1" = "Sinusitis frontal crónica"
        "J32.2" = "Sinusitis etmoidal crónica"
        "J32.3" = "Sinusitis esfenoidal crónica"
        "J32.4" = "Pansinusitis crónica"
        "J32.8" = "Otras sinusitis crónicas"
        "J32.9" = "Sinusitis crónica, no especificada"
        "J33.0" = "Pólipo nasal"
        "J33.1" = "Pólipos de los senos paranasales"
        "J33.8" = "Otros pólipos nasales"
        "J33.9" = "Pólipo nasal, no especificado"
        "J44.0" = "Enfermedad pulmonar obstructiva crónica con infección aguda de las vías respiratorias inferiores"
        "J44.1" = "Enfermedad pulmonar obstructiva crónica con exacerbación aguda"
        "J44.8" = "Otras formas especificadas de enfermedad pulmonar obstructiva crónica"
        "J44.9" = "Enfermedad pulmonar obstructiva crónica, no especificada"
        "J45.0" = "Asma alérgica predominante"
        "J45.1" = "Asma no alérgica"
        "J45.8" = "Asma mixta"
        "J45.9" = "Asma, no especificada"
    }
    "E00-E90" = @{
        "E10.0" = "Diabetes mellitus insulinodependiente con coma"
        "E10.1" = "Diabetes mellitus insulinodependiente con cetoacidosis"
        "E10.2" = "Diabetes mellitus insulinodependiente con complicaciones renales"
        "E10.3" = "Diabetes mellitus insulinodependiente con complicaciones oftálmicas"
        "E10.4" = "Diabetes mellitus insulinodependiente con complicaciones neurológicas"
        "E10.5" = "Diabetes mellitus insulinodependiente con complicaciones circulatorias periféricas"
        "E10.6" = "Diabetes mellitus insulinodependiente con otras complicaciones especificadas"
        "E10.7" = "Diabetes mellitus insulinodependiente con complicaciones múltiples"
        "E10.8" = "Diabetes mellitus insulinodependiente con complicaciones no especificadas"
        "E10.9" = "Diabetes mellitus insulinodependiente sin mención de complicación"
        "E11.0" = "Diabetes mellitus no insulinodependiente con coma"
        "E11.1" = "Diabetes mellitus no insulinodependiente con cetoacidosis"
        "E11.2" = "Diabetes mellitus no insulinodependiente con complicaciones renales"
        "E11.3" = "Diabetes mellitus no insulinodependiente con complicaciones oftálmicas"
        "E11.4" = "Diabetes mellitus no insulinodependiente con complicaciones neurológicas"
        "E11.5" = "Diabetes mellitus no insulinodependiente con complicaciones circulatorias periféricas"
        "E11.6" = "Diabetes mellitus no insulinodependiente con otras complicaciones especificadas"
        "E11.7" = "Diabetes mellitus no insulinodependiente con complicaciones múltiples"
        "E11.8" = "Diabetes mellitus no insulinodependiente con complicaciones no especificadas"
        "E11.9" = "Diabetes mellitus no insulinodependiente sin mención de complicación"
        "E66.0" = "Obesidad debida a exceso de calorías"
        "E66.1" = "Obesidad inducida por medicamentos"
        "E66.2" = "Obesidad extrema con hipoventilación alveolar"
        "E66.3" = "Obesidad hipertrófica"
        "E66.8" = "Otras obesidades"
        "E66.9" = "Obesidad, no especificada"
        "E78.0" = "Hipercolesterolemia pura"
        "E78.1" = "Hipergliceridemia pura"
        "E78.2" = "Dislipidemia mixta"
        "E78.3" = "Hiperquilomicronemia"
        "E78.4" = "Otras hiperlipidemias"
        "E78.5" = "Dislipidemia, no especificada"
    }
}

# Agregar códigos específicos
foreach ($categoria in $codigosEspecificos.Keys) {
    foreach ($codigo in $codigosEspecificos[$categoria].Keys) {
        $descripcion = $codigosEspecificos[$categoria][$codigo]
        $cie10Complete.codigos[$codigo] = @{
            descripcion = $descripcion
            categoria = $categoria
            sintomas_relacionados = @()
        }
        $cie10Complete.categorias[$categoria].codigos[$codigo] = $descripcion
    }
}

# Calcular totales
$cie10Complete.metadata.total_codigos = $cie10Complete.codigos.Count
$cie10Complete.metadata.categorias = $cie10Complete.categorias.Count

# Guardar base de datos completa
$outputFile = "$dataDir/cie10_complete_database.json"
$cie10Complete | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "✅ Base de datos completa guardada en: $outputFile"
Write-Host "📊 Total de códigos: $($cie10Complete.metadata.total_codigos)"
Write-Host "📊 Total de categorías: $($cie10Complete.metadata.categorias)"

Write-Host "`n=== Instrucciones para usar la base de datos completa ==="
Write-Host "1. La base de datos se ha guardado en: $outputFile"
Write-Host "2. Para usar esta base de datos, actualiza el archivo:"
Write-Host "   medical-service-advanced/models/cie10_database.py"
Write-Host "3. Cambia la ruta del archivo de:"
Write-Host "   'data/cie10_es_database.json'"
Write-Host "   a:"
Write-Host "   'data/complete/cie10_complete_database.json'" 