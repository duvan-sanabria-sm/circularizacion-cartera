[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$warnings = New-Object System.Collections.Generic.List[string]
$errors = New-Object System.Collections.Generic.List[string]

function Add-Warning {
    param([string]$Message)
    $warnings.Add($Message)
    Write-Warning $Message
}

function Add-ValidationError {
    param([string]$Message)
    $errors.Add($Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

$requiredFiles = @(
    'project.json',
    'Main.xaml',
    'entry-points.json',
    'orchestrator\assets\assets.json',
    'orchestrator\scripts\import-assets.ps1'
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $projectRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        Add-ValidationError "Falta el archivo requerido: $relativePath"
    }
}

$projectPath = Join-Path $projectRoot 'project.json'
if (Test-Path -LiteralPath $projectPath) {
    try {
        $project = Get-Content -LiteralPath $projectPath -Raw | ConvertFrom-Json
        if ($project.main -ne 'Main.xaml') {
            Add-Warning "El punto de entrada declarado no es Main.xaml: $($project.main)"
        }
    }
    catch {
        Add-ValidationError "project.json no contiene JSON válido: $($_.Exception.Message)"
    }
}

$xamlPath = Join-Path $projectRoot 'Main.xaml'
if (Test-Path -LiteralPath $xamlPath) {
    try {
        $xamlText = Get-Content -LiteralPath $xamlPath -Raw
        [void][xml]$xamlText

        if ($xamlText -match '<ui:CommentOut') {
            Add-Warning 'Main.xaml contiene actividades Comment Out; verificar que no oculten lógica productiva.'
        }
        if ($xamlText -match 'C:\\Users\\') {
            Add-Warning 'Main.xaml contiene rutas de perfil local C:\Users\... y no es completamente portable.'
        }
        if ($xamlText -match 'To=&quot;?duvan\.sanabria@' -or $xamlText -match 'To="duvan\.sanabria@') {
            Add-Warning 'Main.xaml contiene destinatarios de prueba codificados.'
        }
        if ($xamlText -match '<Catch[^>]*>[\s\S]*?<ActivityAction[^>]*/>[\s\S]*?</Catch>') {
            Add-Warning 'Main.xaml puede contener bloques Catch sin acciones de registro o propagación.'
        }
    }
    catch {
        Add-ValidationError "Main.xaml no contiene XML válido: $($_.Exception.Message)"
    }
}

$assetsPath = Join-Path $projectRoot 'orchestrator\assets\assets.json'
if (Test-Path -LiteralPath $assetsPath) {
    try {
        $assetsDocument = Get-Content -LiteralPath $assetsPath -Raw | ConvertFrom-Json
        $assets = if ($assetsDocument.PSObject.Properties.Name -contains 'value') {
            @($assetsDocument.value)
        }
        else {
            @($assetsDocument)
        }

        foreach ($asset in $assets) {
            $value = [string]$asset.Value
            if ($value -match '^[^:]+\.(vb|vbs|xlsx|xlsm)$') {
                $assetFile = Join-Path $projectRoot $value
                if (-not (Test-Path -LiteralPath $assetFile -PathType Leaf)) {
                    Add-Warning "El activo '$($asset.Name)' apunta a un archivo inexistente en el repositorio: $value"
                }
            }
        }
    }
    catch {
        Add-ValidationError "assets.json no contiene JSON válido: $($_.Exception.Message)"
    }
}

Write-Host ''
Write-Host "Validación finalizada: $($errors.Count) error(es), $($warnings.Count) advertencia(s)."

if ($errors.Count -gt 0) {
    exit 1
}

exit 0
