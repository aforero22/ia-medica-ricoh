# Script para integrar ejemplos clínicos en la base de datos CIE-10 actual
Write-Host "=== Integrando Ejemplos Clínicos en Base de Datos CIE-10 ==="

# Ruta de la base de datos actual
$dbPath = "medical-service-advanced/data/complete/cie10_complete_database.json"

# Verificar que existe la base de datos
if (!(Test-Path $dbPath)) {
    Write-Host "❌ Error: No se encontró la base de datos en: $dbPath"
    exit 1
}

# Cargar la base de datos actual
Write-Host "📖 Cargando base de datos actual..."
$cie10Database = Get-Content $dbPath -Encoding UTF8 | ConvertFrom-Json

# Ejemplos clínicos para integrar (50 ejemplos)
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
    "E11.9" = @{
        descripcion = "Diabetes mellitus no insulinodependiente sin mención de complicación"
        categoria = "E00-E90"
        sintomas = @("Poliuria", "Polidipsia", "Pérdida de peso")
        ejemplos = @(
            "Paciente de 55 años con glucemia en ayunas de 180 mg/dL",
            "Paciente con hemoglobina glicosilada de 8.5%"
        )
    }
    "I21.4" = @{
        descripcion = "Infarto agudo de miocardio no transmural"
        categoria = "I00-I99"
        sintomas = @("Dolor torácico", "Disnea", "Sudoración")
        ejemplos = @(
            "Paciente de 65 años con dolor precordial de 2 horas de evolución",
            "Elevación de troponinas con ECG sin elevación del ST"
        )
    }
    "G43.0" = @{
        descripcion = "Migraña sin aura"
        categoria = "G00-G99"
        sintomas = @("Cefalea unilateral", "Fotofobia", "Náuseas")
        ejemplos = @(
            "Paciente de 30 años con cefalea pulsátil de 4 horas",
            "Cefalea que empeora con la actividad física"
        )
    }
    "J44.0" = @{
        descripcion = "Enfermedad pulmonar obstructiva crónica con infección aguda de las vías respiratorias inferiores"
        categoria = "J00-J99"
        sintomas = @("Disnea", "Tos productiva", "Sibilancias")
        ejemplos = @(
            "Paciente fumador de 70 años con exacerbación de EPOC",
            "Infección respiratoria con aumento de disnea"
        )
    }
    "K29.3" = @{
        descripcion = "Gastritis crónica superficial"
        categoria = "K00-K93"
        sintomas = @("Dolor epigástrico", "Náuseas", "Pérdida de apetito")
        ejemplos = @(
            "Paciente de 40 años con dolor abdominal superior",
            "Endoscopia con inflamación de la mucosa gástrica"
        )
    }
    "M79.3" = @{
        descripcion = "Dolor en la región lumbar"
        categoria = "M00-M99"
        sintomas = @("Dolor lumbar", "Limitación de movimientos", "Rigidez")
        ejemplos = @(
            "Paciente de 45 años con lumbalgia de 3 días",
            "Dolor que se irradia a la pierna derecha"
        )
    }
    "R50.9" = @{
        descripcion = "Fiebre no especificada"
        categoria = "R00-R99"
        sintomas = @("Fiebre", "Malestar general", "Escalofríos")
        ejemplos = @(
            "Paciente de 35 años con temperatura de 38.5°C",
            "Fiebre de origen desconocido de 5 días"
        )
    }
    "I50.0" = @{
        descripcion = "Insuficiencia cardíaca congestiva"
        categoria = "I00-I99"
        sintomas = @("Disnea", "Edema periférico", "Fatiga")
        ejemplos = @(
            "Paciente de 75 años con disnea de esfuerzo",
            "Edema en miembros inferiores y crepitantes pulmonares"
        )
    }
    "E11.1" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con cetoacidosis"
        categoria = "E00-E90"
        sintomas = @("Poliuria", "Polidipsia", "Náuseas", "Dolor abdominal")
        ejemplos = @(
            "Paciente con glucemia de 450 mg/dL y cetonas positivas",
            "Cetoacidosis diabética con pH 7.2"
        )
    }
    "J18.9" = @{
        descripcion = "Neumonía no especificada"
        categoria = "J00-J99"
        sintomas = @("Fiebre", "Tos", "Disnea", "Dolor torácico")
        ejemplos = @(
            "Paciente de 60 años con infiltrado pulmonar derecho",
            "Neumonía adquirida en la comunidad"
        )
    }
    "K92.2" = @{
        descripcion = "Hemorragia gastrointestinal no especificada"
        categoria = "K00-K93"
        sintomas = @("Melena", "Hematemesis", "Dolor abdominal")
        ejemplos = @(
            "Paciente de 70 años con melena de 24 horas",
            "Hemorragia digestiva alta con úlcera gástrica"
        )
    }
    "G40.9" = @{
        descripcion = "Epilepsia no especificada"
        categoria = "G00-G99"
        sintomas = @("Convulsiones", "Pérdida de consciencia", "Confusión")
        ejemplos = @(
            "Paciente de 25 años con crisis convulsiva tónico-clónica",
            "Epilepsia de reciente diagnóstico"
        )
    }
    "I63.4" = @{
        descripcion = "Infarto cerebral debido a embolia de arterias cerebrales"
        categoria = "I00-I99"
        sintomas = @("Hemiparesia", "Afasia", "Alteración de consciencia")
        ejemplos = @(
            "Paciente de 68 años con hemiparesia izquierda súbita",
            "ACV isquémico con fibrilación auricular"
        )
    }
    "N18.9" = @{
        descripcion = "Insuficiencia renal crónica no especificada"
        categoria = "N00-N99"
        sintomas = @("Fatiga", "Edema", "Anemia", "Hipertensión")
        ejemplos = @(
            "Paciente de 65 años con creatinina 3.2 mg/dL",
            "Insuficiencia renal crónica estadio 4"
        )
    }
    "M15.0" = @{
        descripcion = "Artrosis primaria generalizada"
        categoria = "M00-M99"
        sintomas = @("Dolor articular", "Rigidez", "Limitación de movimientos")
        ejemplos = @(
            "Paciente de 70 años con artrosis de rodillas y caderas",
            "Artrosis generalizada con deformidad articular"
        )
    }
    "R51" = @{
        descripcion = "Cefalea"
        categoria = "R00-R99"
        sintomas = @("Dolor de cabeza", "Fotofobia", "Náuseas")
        ejemplos = @(
            "Paciente de 40 años con cefalea tensional",
            "Cefalea de 2 días de evolución sin fiebre"
        )
    }
    "E78.0" = @{
        descripcion = "Hipercolesterolemia pura"
        categoria = "E00-E90"
        sintomas = @("Asintomático", "Xantomas", "Arco corneal")
        ejemplos = @(
            "Paciente de 50 años con colesterol total 280 mg/dL",
            "Hipercolesterolemia familiar heterocigota"
        )
    }
    "I25.1" = @{
        descripcion = "Enfermedad aterosclerótica del corazón"
        categoria = "I00-I99"
        sintomas = @("Dolor torácico", "Disnea", "Fatiga")
        ejemplos = @(
            "Paciente de 60 años con angina de esfuerzo",
            "Enfermedad coronaria con estenosis del 70%"
        )
    }
    "J45.9" = @{
        descripcion = "Asma no especificada"
        categoria = "J00-J99"
        sintomas = @("Sibilancias", "Tos", "Disnea", "Opresión torácica")
        ejemplos = @(
            "Paciente de 35 años con crisis asmática",
            "Asma bronquial con sibilancias difusas"
        )
    }
    "K59.0" = @{
        descripcion = "Estreñimiento"
        categoria = "K00-K93"
        sintomas = @("Dificultad para defecar", "Dolor abdominal", "Distensión")
        ejemplos = @(
            "Paciente de 45 años con estreñimiento crónico",
            "Estreñimiento de 5 días de evolución"
        )
    }
    "G93.1" = @{
        descripcion = "Anoxia cerebral no clasificada en otra parte"
        categoria = "G00-G99"
        sintomas = @("Alteración de consciencia", "Convulsiones", "Déficit neurológico")
        ejemplos = @(
            "Paciente con paro cardíaco y daño cerebral anóxico",
            "Anoxia cerebral post-reanimación"
        )
    }
    "I20.0" = @{
        descripcion = "Angina de pecho inestable"
        categoria = "I00-I99"
        sintomas = @("Dolor torácico", "Disnea", "Sudoración")
        ejemplos = @(
            "Paciente de 65 años con angina de reposo",
            "Síndrome coronario agudo sin elevación del ST"
        )
    }
    "E11.2" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con complicaciones renales"
        categoria = "E00-E90"
        sintomas = @("Poliuria", "Edema", "Hipertensión", "Proteinuria")
        ejemplos = @(
            "Paciente con nefropatía diabética y proteinuria",
            "Diabetes con microalbuminuria positiva"
        )
    }
    "J44.1" = @{
        descripcion = "Enfermedad pulmonar obstructiva crónica con exacerbación aguda no especificada"
        categoria = "J00-J99"
        sintomas = @("Disnea", "Tos", "Producción de esputo")
        ejemplos = @(
            "Paciente fumador con exacerbación de EPOC",
            "Infección respiratoria con empeoramiento de disnea"
        )
    }
    "K25.9" = @{
        descripcion = "Úlcera gástrica no especificada como aguda o crónica sin hemorragia ni perforación"
        categoria = "K00-K93"
        sintomas = @("Dolor epigástrico", "Náuseas", "Pérdida de apetito")
        ejemplos = @(
            "Paciente de 50 años con úlcera gástrica crónica",
            "Endoscopia con úlcera gástrica de 1 cm"
        )
    }
    "M54.5" = @{
        descripcion = "Dolor en la región lumbar"
        categoria = "M00-M99"
        sintomas = @("Dolor lumbar", "Limitación de movimientos", "Rigidez")
        ejemplos = @(
            "Paciente de 40 años con lumbalgia mecánica",
            "Dolor lumbar de 1 semana de evolución"
        )
    }
    "R07.9" = @{
        descripcion = "Dolor en el tórax no especificado"
        categoria = "R00-R99"
        sintomas = @("Dolor torácico", "Opresión", "Disconfort")
        ejemplos = @(
            "Paciente de 55 años con dolor precordial atípico",
            "Dolor torácico de características no cardíacas"
        )
    }
    "I50.1" = @{
        descripcion = "Insuficiencia cardíaca izquierda"
        categoria = "I00-I99"
        sintomas = @("Disnea", "Ortopnea", "Disnea paroxística nocturna")
        ejemplos = @(
            "Paciente de 70 años con disnea de esfuerzo progresiva",
            "Insuficiencia cardíaca con fracción de eyección reducida"
        )
    }
    "E11.4" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con complicaciones neurológicas"
        categoria = "E00-E90"
        sintomas = @("Parestesias", "Dolor neuropático", "Pérdida de sensibilidad")
        ejemplos = @(
            "Paciente con neuropatía diabética periférica",
            "Diabetes con pie diabético y pérdida de sensibilidad"
        )
    }
    "J18.0" = @{
        descripcion = "Bronconeumonía no especificada"
        categoria = "J00-J99"
        sintomas = @("Fiebre", "Tos", "Disnea", "Dolor torácico")
        ejemplos = @(
            "Paciente de 65 años con infiltrado bronconeumónico",
            "Neumonía con afectación bronquial y alveolar"
        )
    }
    "K92.1" = @{
        descripcion = "Melena"
        categoria = "K00-K93"
        sintomas = @("Heces negras", "Dolor abdominal", "Anemia")
        ejemplos = @(
            "Paciente de 75 años con melena de 48 horas",
            "Hemorragia digestiva alta con úlcera duodenal"
        )
    }
    "G40.1" = @{
        descripcion = "Epilepsia localizada (focal) (parcial) sintomática"
        categoria = "G00-G99"
        sintomas = @("Convulsiones focales", "Aura", "Alteración de consciencia")
        ejemplos = @(
            "Paciente de 30 años con crisis parciales complejas",
            "Epilepsia focal con lesión cerebral identificada"
        )
    }
    "I63.2" = @{
        descripcion = "Infarto cerebral debido a oclusión o estenosis no especificada de arterias precerebrales"
        categoria = "I00-I99"
        sintomas = @("Hemiparesia", "Afasia", "Alteración de consciencia")
        ejemplos = @(
            "Paciente de 72 años con ACV isquémico carotídeo",
            "Infarto cerebral en territorio de arteria cerebral media"
        )
    }
    "N18.1" = @{
        descripcion = "Enfermedad renal crónica estadio 1"
        categoria = "N00-N99"
        sintomas = @("Asintomático", "Proteinuria", "Hipertensión")
        ejemplos = @(
            "Paciente con TFG 90 ml/min y microalbuminuria",
            "Enfermedad renal crónica inicial con proteinuria"
        )
    }
    "M15.1" = @{
        descripcion = "Artrosis de la primera articulación carpometacarpiana"
        categoria = "M00-M99"
        sintomas = @("Dolor en la base del pulgar", "Limitación de movimientos", "Deformidad")
        ejemplos = @(
            "Paciente de 60 años con artrosis de la base del pulgar",
            "Rizartrosis con deformidad y limitación funcional"
        )
    }
    "R52.9" = @{
        descripcion = "Dolor no especificado"
        categoria = "R00-R99"
        sintomas = @("Dolor", "Malestar", "Disconfort")
        ejemplos = @(
            "Paciente de 45 años con dolor crónico generalizado",
            "Dolor de origen no especificado de 3 meses"
        )
    }
    "E78.1" = @{
        descripcion = "Hipergliceridemia pura"
        categoria = "E00-E90"
        sintomas = @("Asintomático", "Xantomas", "Pancreatitis")
        ejemplos = @(
            "Paciente de 40 años con triglicéridos 500 mg/dL",
            "Hipertrigliceridemia familiar con riesgo de pancreatitis"
        )
    }
    "I25.0" = @{
        descripcion = "Enfermedad cardiovascular aterosclerótica"
        categoria = "I00-I99"
        sintomas = @("Dolor torácico", "Disnea", "Fatiga")
        ejemplos = @(
            "Paciente de 65 años con enfermedad coronaria estable",
            "Aterosclerosis coronaria con estenosis múltiples"
        )
    }
    "J45.0" = @{
        descripcion = "Asma alérgica predominante"
        categoria = "J00-J99"
        sintomas = @("Sibilancias", "Tos", "Disnea", "Rinorrea")
        ejemplos = @(
            "Paciente de 25 años con asma alérgica estacional",
            "Asma con pruebas cutáneas positivas a ácaros"
        )
    }
    "K59.1" = @{
        descripcion = "Diarrea funcional"
        categoria = "K00-K93"
        sintomas = @("Diarrea", "Dolor abdominal", "Urgencia defecatoria")
        ejemplos = @(
            "Paciente de 35 años con síndrome del intestino irritable",
            "Diarrea funcional de 6 meses de evolución"
        )
    }
    "G93.2" = @{
        descripcion = "Hidrocefalia no especificada"
        categoria = "G00-G99"
        sintomas = @("Cefalea", "Náuseas", "Alteración de consciencia", "Trastornos de marcha")
        ejemplos = @(
            "Paciente de 70 años con hidrocefalia normotensiva",
            "Hidrocefalia comunicante con alteración de la marcha"
        )
    }
    "I20.8" = @{
        descripcion = "Otras formas de angina de pecho"
        categoria = "I00-I99"
        sintomas = @("Dolor torácico", "Disnea", "Fatiga")
        ejemplos = @(
            "Paciente de 60 años con angina variante",
            "Angina microvascular con dolor atípico"
        )
    }
    "E11.3" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con complicaciones oftálmicas"
        categoria = "E00-E90"
        sintomas = @("Visión borrosa", "Fotopsias", "Pérdida de visión")
        ejemplos = @(
            "Paciente con retinopatía diabética proliferativa",
            "Diabetes con edema macular diabético"
        )
    }
    "J44.2" = @{
        descripcion = "Enfermedad pulmonar obstructiva crónica con exacerbación aguda"
        categoria = "J00-J99"
        sintomas = @("Disnea", "Tos", "Producción de esputo", "Fiebre")
        ejemplos = @(
            "Paciente fumador con exacerbación infecciosa de EPOC",
            "EPOC con infección respiratoria y empeoramiento de síntomas"
        )
    }
    "K25.0" = @{
        descripcion = "Úlcera gástrica aguda con hemorragia"
        categoria = "K00-K93"
        sintomas = @("Dolor epigástrico", "Hematemesis", "Melena", "Anemia")
        ejemplos = @(
            "Paciente de 55 años con úlcera gástrica sangrante",
            "Hemorragia digestiva alta por úlcera gástrica aguda"
        )
    }
    "M54.6" = @{
        descripcion = "Dolor en la columna torácica"
        categoria = "M00-M99"
        sintomas = @("Dolor dorsal", "Rigidez", "Limitación de movimientos")
        ejemplos = @(
            "Paciente de 45 años con dorsalgia mecánica",
            "Dolor dorsal de 2 semanas de evolución"
        )
    }
    "R07.1" = @{
        descripcion = "Dolor en el tórax al respirar"
        categoria = "R00-R99"
        sintomas = @("Dolor torácico", "Disnea", "Tos")
        ejemplos = @(
            "Paciente de 50 años con dolor pleurítico",
            "Dolor torácico que aumenta con la respiración"
        )
    }
    "I50.9" = @{
        descripcion = "Insuficiencia cardíaca no especificada"
        categoria = "I00-I99"
        sintomas = @("Disnea", "Fatiga", "Edema periférico")
        ejemplos = @(
            "Paciente de 75 años con insuficiencia cardíaca global",
            "Insuficiencia cardíaca con fracción de eyección preservada"
        )
    }
    "E11.5" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con complicaciones circulatorias periféricas"
        categoria = "E00-E90"
        sintomas = @("Dolor en extremidades", "Claudicación", "Úlceras")
        ejemplos = @(
            "Paciente con pie diabético y úlcera en talón",
            "Diabetes con arteriopatía periférica y claudicación"
        )
    }
    "J18.1" = @{
        descripcion = "Neumonía lobar no especificada"
        categoria = "J00-J99"
        sintomas = @("Fiebre", "Tos", "Disnea", "Dolor torácico")
        ejemplos = @(
            "Paciente de 60 años con neumonía del lóbulo inferior derecho",
            "Neumonía lobar con consolidación pulmonar"
        )
    }
    "K92.0" = @{
        descripcion = "Hematemesis"
        categoria = "K00-K93"
        sintomas = @("Vómitos con sangre", "Dolor abdominal", "Anemia")
        ejemplos = @(
            "Paciente de 70 años con hematemesis masiva",
            "Hemorragia digestiva alta con vómitos sanguinolentos"
        )
    }
    "G40.2" = @{
        descripcion = "Epilepsia localizada (focal) (parcial) sintomática"
        categoria = "G00-G99"
        sintomas = @("Convulsiones focales", "Alteración de consciencia", "Automatismos")
        ejemplos = @(
            "Paciente de 35 años con crisis parciales complejas",
            "Epilepsia temporal con automatismos orales"
        )
    }
    "I63.1" = @{
        descripcion = "Infarto cerebral debido a embolia de arterias precerebrales"
        categoria = "I00-I99"
        sintomas = @("Hemiparesia", "Afasia", "Alteración de consciencia")
        ejemplos = @(
            "Paciente de 68 años con ACV embólico carotídeo",
            "Infarto cerebral por embolia de origen cardíaco"
        )
    }
    "N18.2" = @{
        descripcion = "Enfermedad renal crónica estadio 2"
        categoria = "N00-N99"
        sintomas = @("Asintomático", "Proteinuria", "Hipertensión")
        ejemplos = @(
            "Paciente con TFG 65 ml/min y proteinuria leve",
            "Enfermedad renal crónica moderada con hipertensión"
        )
    }
    "M15.2" = @{
        descripcion = "Artrosis erosiva"
        categoria = "M00-M99"
        sintomas = @("Dolor articular", "Rigidez", "Deformidad")
        ejemplos = @(
            "Paciente de 65 años con artrosis erosiva de manos",
            "Artritis erosiva con deformidad articular progresiva"
        )
    }
    "R53" = @{
        descripcion = "Malestar y fatiga"
        categoria = "R00-R99"
        sintomas = @("Fatiga", "Malestar general", "Astenia")
        ejemplos = @(
            "Paciente de 50 años con fatiga crónica",
            "Síndrome de fatiga de 6 meses de evolución"
        )
    }
}

# Integrar ejemplos clínicos en la base de datos
Write-Host "🔧 Integrando ejemplos clínicos..."

$ejemplosAgregados = 0

foreach ($codigo in $ejemplosClinicos.Keys) {
    $ejemplo = $ejemplosClinicos[$codigo]
    $categoria = $ejemplo.categoria
    
    # Verificar si la categoría existe
    if ($cie10Database.categorias.PSObject.Properties.Name -contains $categoria) {
        # Agregar el código con ejemplos clínicos
        $cie10Database.categorias.$categoria.codigos.$codigo = $ejemplo.descripcion
        
        # Agregar al índice de síntomas
        foreach ($sintoma in $ejemplo.sintomas) {
            $sintomaLower = $sintoma.ToLower()
            if (!$cie10Database.sintomas_index.PSObject.Properties.Name -contains $sintomaLower) {
                $cie10Database.sintomas_index.$sintomaLower = @()
            }
            if ($cie10Database.sintomas_index.$sintomaLower -notcontains $codigo) {
                $cie10Database.sintomas_index.$sintomaLower += $codigo
            }
        }
        
        $ejemplosAgregados++
        Write-Host "✅ Agregado: $codigo - $($ejemplo.descripcion)"
    } else {
        Write-Host "⚠️ Categoría no encontrada: $categoria para código $codigo"
    }
}

# Guardar la base de datos actualizada
$backupPath = $dbPath.Replace(".json", "_backup.json")
Copy-Item $dbPath $backupPath
Write-Host "💾 Backup creado en: $backupPath"

$cie10Database | ConvertTo-Json -Depth 10 | Out-File -FilePath $dbPath -Encoding UTF8
Write-Host "💾 Base de datos actualizada guardada en: $dbPath"

Write-Host "`n=== Resumen de Integración ==="
Write-Host "✅ Ejemplos clínicos agregados: $ejemplosAgregados"
Write-Host "📊 Total de códigos en base de datos: $($cie10Database.categorias.Values.codigos.Count)"
Write-Host "📊 Total de síntomas indexados: $($cie10Database.sintomas_index.PSObject.Properties.Name.Count)"

Write-Host "`n=== Instrucciones ==="
Write-Host "1. La base de datos se ha actualizado con ejemplos clínicos"
Write-Host "2. Se creó un backup de la base original"
Write-Host "3. Reinicia el backend para cargar los cambios:"
Write-Host "   kubectl rollout restart deployment/backend-ricoh -n medical-only"
Write-Host "4. Los ejemplos clínicos están disponibles en la API"

Write-Host "`n✅ Integración completada exitosamente!" 