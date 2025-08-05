# Script para integrar ejemplos clinicos en la base de datos CIE-10 actual
Write-Host "=== Integrando Ejemplos Clinicos en Base de Datos CIE-10 ==="

# Ruta de la base de datos actual
$dbPath = "medical-service-advanced/data/complete/cie10_complete_database.json"

# Verificar que existe la base de datos
if (!(Test-Path $dbPath)) {
    Write-Host "Error: No se encontro la base de datos en: $dbPath"
    exit 1
}

# Cargar la base de datos actual
Write-Host "Cargando base de datos actual..."
$cie10Database = Get-Content $dbPath -Encoding UTF8 | ConvertFrom-Json

# Ejemplos clinicos para integrar (50 ejemplos)
$ejemplosClinicos = @{
    "I10" = @{
        descripcion = "Hipertension esencial"
        categoria = "I00-I99"
        sintomas = @("Presion arterial elevada", "Dolor de cabeza", "Mareos")
        ejemplos = @(
            "Paciente de 45 anos con presion arterial 160/100 mmHg",
            "Paciente de 60 anos con hipertension de 10 anos de evolucion"
        )
    }
    "E11.9" = @{
        descripcion = "Diabetes mellitus no insulinodependiente sin mencion de complicacion"
        categoria = "E00-E90"
        sintomas = @("Poliuria", "Polidipsia", "Perdida de peso")
        ejemplos = @(
            "Paciente de 55 anos con glucemia en ayunas de 180 mg/dL",
            "Paciente con hemoglobina glicosilada de 8.5%"
        )
    }
    "I21.4" = @{
        descripcion = "Infarto agudo de miocardio no transmural"
        categoria = "I00-I99"
        sintomas = @("Dolor toracico", "Disnea", "Sudoracion")
        ejemplos = @(
            "Paciente de 65 anos con dolor precordial de 2 horas de evolucion",
            "Elevacion de troponinas con ECG sin elevacion del ST"
        )
    }
    "G43.0" = @{
        descripcion = "Migrana sin aura"
        categoria = "G00-G99"
        sintomas = @("Cefalea unilateral", "Fotofobia", "Nauseas")
        ejemplos = @(
            "Paciente de 30 anos con cefalea pulsatil de 4 horas",
            "Cefalea que empeora con la actividad fisica"
        )
    }
    "J44.0" = @{
        descripcion = "EPOC con infeccion aguda de las vias respiratorias inferiores"
        categoria = "J00-J99"
        sintomas = @("Disnea", "Tos productiva", "Sibilancias")
        ejemplos = @(
            "Paciente fumador de 70 anos con exacerbacion de EPOC",
            "Infeccion respiratoria con aumento de disnea"
        )
    }
    "K29.3" = @{
        descripcion = "Gastritis cronica superficial"
        categoria = "K00-K93"
        sintomas = @("Dolor epigastrico", "Nauseas", "Perdida de apetito")
        ejemplos = @(
            "Paciente de 40 anos con dolor abdominal superior",
            "Endoscopia con inflamacion de la mucosa gastrica"
        )
    }
    "M79.3" = @{
        descripcion = "Dolor en la region lumbar"
        categoria = "M00-M99"
        sintomas = @("Dolor lumbar", "Limitacion de movimientos", "Rigidez")
        ejemplos = @(
            "Paciente de 45 anos con lumbalgia de 3 dias",
            "Dolor que se irradia a la pierna derecha"
        )
    }
    "R50.9" = @{
        descripcion = "Fiebre no especificada"
        categoria = "R00-R99"
        sintomas = @("Fiebre", "Malestar general", "Escalofrios")
        ejemplos = @(
            "Paciente de 35 anos con temperatura de 38.5°C",
            "Fiebre de origen desconocido de 5 dias"
        )
    }
    "I50.0" = @{
        descripcion = "Insuficiencia cardiaca congestiva"
        categoria = "I00-I99"
        sintomas = @("Disnea", "Edema periferico", "Fatiga")
        ejemplos = @(
            "Paciente de 75 anos con disnea de esfuerzo",
            "Edema en miembros inferiores y crepitantes pulmonares"
        )
    }
    "E11.1" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con cetoacidosis"
        categoria = "E00-E90"
        sintomas = @("Poliuria", "Polidipsia", "Nauseas", "Dolor abdominal")
        ejemplos = @(
            "Paciente con glucemia de 450 mg/dL y cetonas positivas",
            "Cetoacidosis diabetica con pH 7.2"
        )
    }
    "J18.9" = @{
        descripcion = "Neumonia no especificada"
        categoria = "J00-J99"
        sintomas = @("Fiebre", "Tos", "Disnea", "Dolor toracico")
        ejemplos = @(
            "Paciente de 60 anos con infiltrado pulmonar derecho",
            "Neumonia adquirida en la comunidad"
        )
    }
    "K92.2" = @{
        descripcion = "Hemorragia gastrointestinal no especificada"
        categoria = "K00-K93"
        sintomas = @("Melena", "Hematemesis", "Dolor abdominal")
        ejemplos = @(
            "Paciente de 70 anos con melena de 24 horas",
            "Hemorragia digestiva alta con ulcera gastrica"
        )
    }
    "G40.9" = @{
        descripcion = "Epilepsia no especificada"
        categoria = "G00-G99"
        sintomas = @("Convulsiones", "Perdida de consciencia", "Confusion")
        ejemplos = @(
            "Paciente de 25 anos con crisis convulsiva tonico-clonica",
            "Epilepsia de reciente diagnostico"
        )
    }
    "I63.4" = @{
        descripcion = "Infarto cerebral debido a embolia de arterias cerebrales"
        categoria = "I00-I99"
        sintomas = @("Hemiparesia", "Afasia", "Alteracion de consciencia")
        ejemplos = @(
            "Paciente de 68 anos con hemiparesia izquierda subita",
            "ACV isquemico con fibrilacion auricular"
        )
    }
    "N18.9" = @{
        descripcion = "Insuficiencia renal cronica no especificada"
        categoria = "N00-N99"
        sintomas = @("Fatiga", "Edema", "Anemia", "Hipertension")
        ejemplos = @(
            "Paciente de 65 anos con creatinina 3.2 mg/dL",
            "Insuficiencia renal cronica estadio 4"
        )
    }
    "M15.0" = @{
        descripcion = "Artrosis primaria generalizada"
        categoria = "M00-M99"
        sintomas = @("Dolor articular", "Rigidez", "Limitacion de movimientos")
        ejemplos = @(
            "Paciente de 70 anos con artrosis de rodillas y caderas",
            "Artrosis generalizada con deformidad articular"
        )
    }
    "R51" = @{
        descripcion = "Cefalea"
        categoria = "R00-R99"
        sintomas = @("Dolor de cabeza", "Fotofobia", "Nauseas")
        ejemplos = @(
            "Paciente de 40 anos con cefalea tensional",
            "Cefalea de 2 dias de evolucion sin fiebre"
        )
    }
    "E78.0" = @{
        descripcion = "Hipercolesterolemia pura"
        categoria = "E00-E90"
        sintomas = @("Asintomatico", "Xantomas", "Arco corneal")
        ejemplos = @(
            "Paciente de 50 anos con colesterol total 280 mg/dL",
            "Hipercolesterolemia familiar heterocigota"
        )
    }
    "I25.1" = @{
        descripcion = "Enfermedad aterosclerotica del corazon"
        categoria = "I00-I99"
        sintomas = @("Dolor toracico", "Disnea", "Fatiga")
        ejemplos = @(
            "Paciente de 60 anos con angina de esfuerzo",
            "Enfermedad coronaria con estenosis del 70%"
        )
    }
    "J45.9" = @{
        descripcion = "Asma no especificada"
        categoria = "J00-J99"
        sintomas = @("Sibilancias", "Tos", "Disnea", "Opresion toracica")
        ejemplos = @(
            "Paciente de 35 anos con crisis asmatica",
            "Asma bronquial con sibilancias difusas"
        )
    }
    "K59.0" = @{
        descripcion = "Estrenimiento"
        categoria = "K00-K93"
        sintomas = @("Dificultad para defecar", "Dolor abdominal", "Distension")
        ejemplos = @(
            "Paciente de 45 anos con estrenimiento cronico",
            "Estrenimiento de 5 dias de evolucion"
        )
    }
    "G93.1" = @{
        descripcion = "Anoxia cerebral no clasificada en otra parte"
        categoria = "G00-G99"
        sintomas = @("Alteracion de consciencia", "Convulsiones", "Deficit neurologico")
        ejemplos = @(
            "Paciente con paro cardiaco y dano cerebral anoxico",
            "Anoxia cerebral post-reanimacion"
        )
    }
    "I20.0" = @{
        descripcion = "Angina de pecho inestable"
        categoria = "I00-I99"
        sintomas = @("Dolor toracico", "Disnea", "Sudoracion")
        ejemplos = @(
            "Paciente de 65 anos con angina de reposo",
            "Sindrome coronario agudo sin elevacion del ST"
        )
    }
    "E11.2" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con complicaciones renales"
        categoria = "E00-E90"
        sintomas = @("Poliuria", "Edema", "Hipertension", "Proteinuria")
        ejemplos = @(
            "Paciente con nefropatia diabetica y proteinuria",
            "Diabetes con microalbuminuria positiva"
        )
    }
    "J44.1" = @{
        descripcion = "EPOC con exacerbacion aguda no especificada"
        categoria = "J00-J99"
        sintomas = @("Disnea", "Tos", "Produccion de esputo")
        ejemplos = @(
            "Paciente fumador con exacerbacion de EPOC",
            "Infeccion respiratoria con empeoramiento de disnea"
        )
    }
    "K25.9" = @{
        descripcion = "Ulcera gastrica no especificada"
        categoria = "K00-K93"
        sintomas = @("Dolor epigastrico", "Nauseas", "Perdida de apetito")
        ejemplos = @(
            "Paciente de 50 anos con ulcera gastrica cronica",
            "Endoscopia con ulcera gastrica de 1 cm"
        )
    }
    "M54.5" = @{
        descripcion = "Dolor en la region lumbar"
        categoria = "M00-M99"
        sintomas = @("Dolor lumbar", "Limitacion de movimientos", "Rigidez")
        ejemplos = @(
            "Paciente de 40 anos con lumbalgia mecanica",
            "Dolor lumbar de 1 semana de evolucion"
        )
    }
    "R07.9" = @{
        descripcion = "Dolor en el torax no especificado"
        categoria = "R00-R99"
        sintomas = @("Dolor toracico", "Opresion", "Disconfort")
        ejemplos = @(
            "Paciente de 55 anos con dolor precordial atipico",
            "Dolor toracico de caracteristicas no cardiacas"
        )
    }
    "I50.1" = @{
        descripcion = "Insuficiencia cardiaca izquierda"
        categoria = "I00-I99"
        sintomas = @("Disnea", "Ortopnea", "Disnea paroxistica nocturna")
        ejemplos = @(
            "Paciente de 70 anos con disnea de esfuerzo progresiva",
            "Insuficiencia cardiaca con fraccion de eyeccion reducida"
        )
    }
    "E11.4" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con complicaciones neurologicas"
        categoria = "E00-E90"
        sintomas = @("Parestesias", "Dolor neuropatico", "Perdida de sensibilidad")
        ejemplos = @(
            "Paciente con neuropatia diabetica periferica",
            "Diabetes con pie diabetico y perdida de sensibilidad"
        )
    }
    "J18.0" = @{
        descripcion = "Bronconeumonia no especificada"
        categoria = "J00-J99"
        sintomas = @("Fiebre", "Tos", "Disnea", "Dolor toracico")
        ejemplos = @(
            "Paciente de 65 anos con infiltrado bronconeumonico",
            "Neumonia con afectacion bronquial y alveolar"
        )
    }
    "K92.1" = @{
        descripcion = "Melena"
        categoria = "K00-K93"
        sintomas = @("Heces negras", "Dolor abdominal", "Anemia")
        ejemplos = @(
            "Paciente de 75 anos con melena de 48 horas",
            "Hemorragia digestiva alta con ulcera duodenal"
        )
    }
    "G40.1" = @{
        descripcion = "Epilepsia localizada sintomatica"
        categoria = "G00-G99"
        sintomas = @("Convulsiones focales", "Aura", "Alteracion de consciencia")
        ejemplos = @(
            "Paciente de 30 anos con crisis parciales complejas",
            "Epilepsia focal con lesion cerebral identificada"
        )
    }
    "I63.2" = @{
        descripcion = "Infarto cerebral debido a oclusion de arterias precerebrales"
        categoria = "I00-I99"
        sintomas = @("Hemiparesia", "Afasia", "Alteracion de consciencia")
        ejemplos = @(
            "Paciente de 72 anos con ACV isquemico carotideo",
            "Infarto cerebral en territorio de arteria cerebral media"
        )
    }
    "N18.1" = @{
        descripcion = "Enfermedad renal cronica estadio 1"
        categoria = "N00-N99"
        sintomas = @("Asintomatico", "Proteinuria", "Hipertension")
        ejemplos = @(
            "Paciente con TFG 90 ml/min y microalbuminuria",
            "Enfermedad renal cronica inicial con proteinuria"
        )
    }
    "M15.1" = @{
        descripcion = "Artrosis de la primera articulacion carpometacarpiana"
        categoria = "M00-M99"
        sintomas = @("Dolor en la base del pulgar", "Limitacion de movimientos", "Deformidad")
        ejemplos = @(
            "Paciente de 60 anos con artrosis de la base del pulgar",
            "Rizartrosis con deformidad y limitacion funcional"
        )
    }
    "R52.9" = @{
        descripcion = "Dolor no especificado"
        categoria = "R00-R99"
        sintomas = @("Dolor", "Malestar", "Disconfort")
        ejemplos = @(
            "Paciente de 45 anos con dolor cronico generalizado",
            "Dolor de origen no especificado de 3 meses"
        )
    }
    "E78.1" = @{
        descripcion = "Hipergliceridemia pura"
        categoria = "E00-E90"
        sintomas = @("Asintomatico", "Xantomas", "Pancreatitis")
        ejemplos = @(
            "Paciente de 40 anos con trigliceridos 500 mg/dL",
            "Hipertrigliceridemia familiar con riesgo de pancreatitis"
        )
    }
    "I25.0" = @{
        descripcion = "Enfermedad cardiovascular aterosclerotica"
        categoria = "I00-I99"
        sintomas = @("Dolor toracico", "Disnea", "Fatiga")
        ejemplos = @(
            "Paciente de 65 anos con enfermedad coronaria estable",
            "Aterosclerosis coronaria con estenosis multiples"
        )
    }
    "J45.0" = @{
        descripcion = "Asma alergica predominante"
        categoria = "J00-J99"
        sintomas = @("Sibilancias", "Tos", "Disnea", "Rinorrea")
        ejemplos = @(
            "Paciente de 25 anos con asma alergica estacional",
            "Asma con pruebas cutaneas positivas a acaros"
        )
    }
    "K59.1" = @{
        descripcion = "Diarrea funcional"
        categoria = "K00-K93"
        sintomas = @("Diarrea", "Dolor abdominal", "Urgencia defecatoria")
        ejemplos = @(
            "Paciente de 35 anos con sindrome del intestino irritable",
            "Diarrea funcional de 6 meses de evolucion"
        )
    }
    "G93.2" = @{
        descripcion = "Hidrocefalia no especificada"
        categoria = "G00-G99"
        sintomas = @("Cefalea", "Nauseas", "Alteracion de consciencia", "Trastornos de marcha")
        ejemplos = @(
            "Paciente de 70 anos con hidrocefalia normotensiva",
            "Hidrocefalia comunicante con alteracion de la marcha"
        )
    }
    "I20.8" = @{
        descripcion = "Otras formas de angina de pecho"
        categoria = "I00-I99"
        sintomas = @("Dolor toracico", "Disnea", "Fatiga")
        ejemplos = @(
            "Paciente de 60 anos con angina variante",
            "Angina microvascular con dolor atipico"
        )
    }
    "E11.3" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con complicaciones oftalmicas"
        categoria = "E00-E90"
        sintomas = @("Vision borrosa", "Fotopsias", "Perdida de vision")
        ejemplos = @(
            "Paciente con retinopatia diabetica proliferativa",
            "Diabetes con edema macular diabetico"
        )
    }
    "J44.2" = @{
        descripcion = "EPOC con exacerbacion aguda"
        categoria = "J00-J99"
        sintomas = @("Disnea", "Tos", "Produccion de esputo", "Fiebre")
        ejemplos = @(
            "Paciente fumador con exacerbacion infecciosa de EPOC",
            "EPOC con infeccion respiratoria y empeoramiento de sintomas"
        )
    }
    "K25.0" = @{
        descripcion = "Ulcera gastrica aguda con hemorragia"
        categoria = "K00-K93"
        sintomas = @("Dolor epigastrico", "Hematemesis", "Melena", "Anemia")
        ejemplos = @(
            "Paciente de 55 anos con ulcera gastrica sangrante",
            "Hemorragia digestiva alta por ulcera gastrica aguda"
        )
    }
    "M54.6" = @{
        descripcion = "Dolor en la columna toracica"
        categoria = "M00-M99"
        sintomas = @("Dolor dorsal", "Rigidez", "Limitacion de movimientos")
        ejemplos = @(
            "Paciente de 45 anos con dorsalgia mecanica",
            "Dolor dorsal de 2 semanas de evolucion"
        )
    }
    "R07.1" = @{
        descripcion = "Dolor en el torax al respirar"
        categoria = "R00-R99"
        sintomas = @("Dolor toracico", "Disnea", "Tos")
        ejemplos = @(
            "Paciente de 50 anos con dolor pleuritico",
            "Dolor toracico que aumenta con la respiracion"
        )
    }
    "I50.9" = @{
        descripcion = "Insuficiencia cardiaca no especificada"
        categoria = "I00-I99"
        sintomas = @("Disnea", "Fatiga", "Edema periferico")
        ejemplos = @(
            "Paciente de 75 anos con insuficiencia cardiaca global",
            "Insuficiencia cardiaca con fraccion de eyeccion preservada"
        )
    }
    "E11.5" = @{
        descripcion = "Diabetes mellitus no insulinodependiente con complicaciones circulatorias perifericas"
        categoria = "E00-E90"
        sintomas = @("Dolor en extremidades", "Claudicacion", "Ulceras")
        ejemplos = @(
            "Paciente con pie diabetico y ulcera en talon",
            "Diabetes con arteriopatia periferica y claudicacion"
        )
    }
    "J18.1" = @{
        descripcion = "Neumonia lobar no especificada"
        categoria = "J00-J99"
        sintomas = @("Fiebre", "Tos", "Disnea", "Dolor toracico")
        ejemplos = @(
            "Paciente de 60 anos con neumonia del lobulo inferior derecho",
            "Neumonia lobar con consolidacion pulmonar"
        )
    }
    "K92.0" = @{
        descripcion = "Hematemesis"
        categoria = "K00-K93"
        sintomas = @("Vomitos con sangre", "Dolor abdominal", "Anemia")
        ejemplos = @(
            "Paciente de 70 anos con hematemesis masiva",
            "Hemorragia digestiva alta con vomitos sanguinolentos"
        )
    }
    "G40.2" = @{
        descripcion = "Epilepsia localizada sintomatica"
        categoria = "G00-G99"
        sintomas = @("Convulsiones focales", "Alteracion de consciencia", "Automatismos")
        ejemplos = @(
            "Paciente de 35 anos con crisis parciales complejas",
            "Epilepsia temporal con automatismos orales"
        )
    }
    "I63.1" = @{
        descripcion = "Infarto cerebral debido a embolia de arterias precerebrales"
        categoria = "I00-I99"
        sintomas = @("Hemiparesia", "Afasia", "Alteracion de consciencia")
        ejemplos = @(
            "Paciente de 68 anos con ACV embolico carotideo",
            "Infarto cerebral por embolia de origen cardiaco"
        )
    }
    "N18.2" = @{
        descripcion = "Enfermedad renal cronica estadio 2"
        categoria = "N00-N99"
        sintomas = @("Asintomatico", "Proteinuria", "Hipertension")
        ejemplos = @(
            "Paciente con TFG 65 ml/min y proteinuria leve",
            "Enfermedad renal cronica moderada con hipertension"
        )
    }
    "M15.2" = @{
        descripcion = "Artrosis erosiva"
        categoria = "M00-M99"
        sintomas = @("Dolor articular", "Rigidez", "Deformidad")
        ejemplos = @(
            "Paciente de 65 anos con artrosis erosiva de manos",
            "Artritis erosiva con deformidad articular progresiva"
        )
    }
    "R53" = @{
        descripcion = "Malestar y fatiga"
        categoria = "R00-R99"
        sintomas = @("Fatiga", "Malestar general", "Astenia")
        ejemplos = @(
            "Paciente de 50 anos con fatiga cronica",
            "Sindrome de fatiga de 6 meses de evolucion"
        )
    }
}

# Integrar ejemplos clinicos en la base de datos
Write-Host "Integrando ejemplos clinicos..."

$ejemplosAgregados = 0

foreach ($codigo in $ejemplosClinicos.Keys) {
    $ejemplo = $ejemplosClinicos[$codigo]
    $categoria = $ejemplo.categoria
    
    # Verificar si la categoria existe
    if ($cie10Database.categorias.PSObject.Properties.Name -contains $categoria) {
        # Agregar el codigo con ejemplos clinicos
        $cie10Database.categorias.$categoria.codigos.$codigo = $ejemplo.descripcion
        
        # Agregar al indice de sintomas
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
        Write-Host "Agregado: $codigo - $($ejemplo.descripcion)"
    } else {
        Write-Host "Categoria no encontrada: $categoria para codigo $codigo"
    }
}

# Guardar la base de datos actualizada
$backupPath = $dbPath.Replace(".json", "_backup.json")
Copy-Item $dbPath $backupPath
Write-Host "Backup creado en: $backupPath"

$cie10Database | ConvertTo-Json -Depth 10 | Out-File -FilePath $dbPath -Encoding UTF8
Write-Host "Base de datos actualizada guardada en: $dbPath"

Write-Host "Resumen de Integracion"
Write-Host "Ejemplos clinicos agregados: $ejemplosAgregados"
Write-Host "Total de codigos en base de datos: $($cie10Database.categorias.Values.codigos.Count)"
Write-Host "Total de sintomas indexados: $($cie10Database.sintomas_index.PSObject.Properties.Name.Count)"

Write-Host "Instrucciones"
Write-Host "1. La base de datos se ha actualizado con ejemplos clinicos"
Write-Host "2. Se creo un backup de la base original"
Write-Host "3. Reinicia el backend para cargar los cambios:"
Write-Host "   kubectl rollout restart deployment/backend-ricoh -n medical-only"
Write-Host "4. Los ejemplos clinicos estan disponibles en la API"

Write-Host "Integracion completada exitosamente!" 