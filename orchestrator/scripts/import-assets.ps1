# ==============================
# Variables desde Azure DevOps
# ==============================
$org = $env:UIPATH_ORG
$tenant = $env:UIPATH_TENANT
$clientId = $env:UIPATH_CLIENT_ID
$clientSecret = $env:UIPATH_CLIENT_SECRET
$folderPath = $env:UIPATH_FOLDER_PATH  # ej. "Servimeters\Comercio\Cartera"

$requiredVariables = @{
    UIPATH_ORG = $org
    UIPATH_TENANT = $tenant
    UIPATH_CLIENT_ID = $clientId
    UIPATH_CLIENT_SECRET = $clientSecret
    UIPATH_FOLDER_PATH = $folderPath
}

foreach ($variable in $requiredVariables.GetEnumerator()) {
    if ([string]::IsNullOrWhiteSpace($variable.Value)) {
        Write-Host "ERROR: $($variable.Key) no esta definido."
        exit 1
    }
}

# ==============================
# 1. Obtener token
# ==============================
$tokenUrl = "https://cloud.uipath.com/$org/identity_/connect/token"

$body = @{
    grant_type = "client_credentials"
    client_id = $clientId
    client_secret = $clientSecret
    scope = "OR.Assets.Read OR.Assets.Write OR.Folders.Read OR.Folders.Write"
}

try {
    $response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body
}
catch {
    Write-Host "ERROR: no se pudo obtener token de UiPath. Valida UIPATH_ORG, UIPATH_CLIENT_ID y UIPATH_CLIENT_SECRET."
    Write-Host "Exception message: $($_.Exception.Message)"
    exit 1
}

$accessToken = $response.access_token

# ==============================
# Headers
# ==============================
$folderHeaders = @{
    Authorization = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# ==============================
# Funcion para crear folder jerarquico
# ==============================
function Create-FolderHierarchy {
    param (
        [string]$folderPath,
        [string]$org,
        [string]$tenant,
        [hashtable]$headers
    )

    $foldersUrl = "https://cloud.uipath.com/$org/$tenant/orchestrator_/odata/Folders"

    try {
        $existingFolders = Invoke-RestMethod -Method Get -Uri $foldersUrl -Headers $headers
    }
    catch {
        Write-Host "ERROR: no se pudieron consultar los folders del tenant actual."
        Write-Host "Exception message: $($_.Exception.Message)"
        exit 1
    }

    $folderNames = $folderPath -split '\\'
    $currentParentId = $null

    foreach ($folderName in $folderNames) {
        if ([string]::IsNullOrWhiteSpace($folderName)) {
            continue
        }

        Write-Host "Verificando folder: $folderName bajo ParentId: $currentParentId"

        $matchingFolders = @($existingFolders.value | Where-Object {
            $_.DisplayName -eq $folderName -and $_.ParentId -eq $currentParentId
        })
        $existingFolder = $matchingFolders | Select-Object -First 1

        if ($existingFolder) {
            Write-Host "Folder '$folderName' ya existe con ID: $($existingFolder.Id)"
            $currentParentId = $existingFolder.Id
        }
        else {
            Write-Host "Creando folder: $folderName"
            $createBody = @{
                DisplayName = $folderName
                ParentId = $currentParentId
            } | ConvertTo-Json

            try {
                $newFolder = Invoke-RestMethod -Method Post -Uri $foldersUrl -Headers $headers -Body $createBody
                Write-Host "Folder '$folderName' creado con ID: $($newFolder.Id)"
                $currentParentId = $newFolder.Id
                $existingFolders.value += $newFolder
            }
            catch {
                Write-Host "Error creando folder '$folderName': $($_.Exception.Message)"
                exit 1
            }
        }
    }

    return $currentParentId
}

# ==============================
# 2. Crear/resolver folder jerarquia
# ==============================
Write-Host "Creando/resolviendo jerarquia de folders: $folderPath"
$folderId = Create-FolderHierarchy -folderPath $folderPath -org $org -tenant $tenant -headers $folderHeaders

if ([string]::IsNullOrWhiteSpace($folderId)) {
    Write-Host "ERROR: no se pudo resolver el ID del folder destino desde UIPATH_FOLDER_PATH."
    exit 1
}

Write-Host "Folder destino resuelto con ID: $folderId"

$assetHeaders = @{
    Authorization = "Bearer $accessToken"
    "X-UIPATH-OrganizationUnitId" = $folderId.ToString()
    "Content-Type" = "application/json"
}

# ==============================
# 3. Leer JSON
# ==============================
$sourceDir = $env:BUILD_SOURCESDIRECTORY
if (-not $sourceDir) {
    Write-Host "ERROR: BUILD_SOURCESDIRECTORY no esta definido."
    exit 1
}

$assetsPath = Join-Path $sourceDir 'orchestrator\assets\assets.json'
Write-Host "Leyendo assets desde: $assetsPath"

if (-not (Test-Path $assetsPath)) {
    Write-Host "ERROR: no se encontro el archivo de assets en la ruta especificada."
    exit 1
}

$assetsJson = Get-Content $assetsPath -Raw | ConvertFrom-Json
if ($assetsJson -eq $null) {
    Write-Host "ERROR: no se pudo leer el archivo de assets"
    exit 1
}

$assets = if ($assetsJson.PSObject.Properties.Name -contains 'value') { $assetsJson.value } else { $assetsJson }
$assets = @($assets)
if ($assets.Count -eq 0) {
    Write-Host "ERROR: no se encontro ningun asset en el JSON"
    exit 1
}

Write-Host "Assets encontrados: $($assets.Count)"
for ($i = 0; $i -lt $assets.Count; $i++) {
    $asset = $assets[$i]
    Write-Host "Asset[$i] Nombre:'$($asset.Name)' Key:'$($asset.Key)' Tipo:'$($asset.ValueType)'"
}

# ==============================
# 4. Endpoint
# ==============================
$assetsUrl = "https://cloud.uipath.com/$org/$tenant/orchestrator_/odata/Assets"

# ==============================
# 5. Crear assets
# ==============================
foreach ($asset in $assets) {
    Write-Host "Creando asset: $($asset.Name)"

    $payload = @{
        Name = $asset.Name
        ValueScope = $asset.ValueScope
        ValueType = $asset.ValueType
    }

    if ($asset.ValueType -eq "Text") {
        $payload.StringValue = $asset.StringValue
    }

    if ($asset.ValueType -eq "Integer") {
        $payload.IntValue = $asset.IntValue
    }

    $json = $payload | ConvertTo-Json -Depth 5

    try {
        Invoke-RestMethod -Method Post -Uri $assetsUrl -Headers $assetHeaders -Body $json
        Write-Host "OK"
    }
    catch {
        Write-Host "Error creando asset: $($asset.Name)"
        Write-Host "Payload: $json"
        Write-Host "Exception message: $($_.Exception.Message)"
        if ($_.Exception.Response -ne $null) {
            try {
                $responseStream = $_.Exception.Response.GetResponseStream()
                $reader = [System.IO.StreamReader]::new($responseStream)
                $responseBody = $reader.ReadToEnd()
                $reader.Close()
                Write-Host "Response body: $responseBody"
            }
            catch {
                Write-Host "No se pudo leer el response body de la excepcion: $($_.Exception.Message)"
            }
        }
    }
}

Write-Host "Assets importados"
