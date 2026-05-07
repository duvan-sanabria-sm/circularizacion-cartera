# ==============================
# Variables desde Azure DevOps
# ==============================
$org = $env:UIPATH_ORG
$tenant = $env:UIPATH_TENANT
$clientId = $env:UIPATH_CLIENT_ID
$clientSecret = $env:UIPATH_CLIENT_SECRET
$folderId = $env:UIPATH_FOLDER_ID
$folderPath = $env:UIPATH_FOLDER_PATH  # ej. "Servimeters\Comercio\Cartera"

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

$response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body

$accessToken = $response.access_token

# ==============================
# Headers
# ==============================
if (-not $folderId) {
    Write-Host "ERROR: UIPATH_FOLDER_ID no está definido. Debes pasar el ID del folder destino." 
    exit 1
}
Write-Host "Usando Folder ID: $folderId"
$headers = @{
    Authorization = "Bearer $accessToken"
    "X-UIPATH-OrganizationUnitId" = $folderId
    "Content-Type" = "application/json"
}

# ==============================
# Función para crear folder jerárquico
# ==============================
function Create-FolderHierarchy {
    param (
        [string]$folderPath,
        [string]$org,
        [string]$tenant,
        [hashtable]$headers
    )
    
    $foldersUrl = "https://cloud.uipath.com/$org/$tenant/orchestrator_/odata/Folders"
    
    # Obtener folders existentes
    $existingFolders = Invoke-RestMethod -Method Get -Uri $foldersUrl -Headers $headers
    
    $folderNames = $folderPath -split '\\'
    $currentParentId = $null
    
    foreach ($folderName in $folderNames) {
        Write-Host "Verificando folder: $folderName bajo ParentId: $currentParentId"
        
        # Buscar si ya existe
        $existingFolder = $existingFolders.value | Where-Object { $_.DisplayName -eq $folderName -and $_.ParentId -eq $currentParentId }
        
        if ($existingFolder) {
            Write-Host "Folder '$folderName' ya existe con ID: $($existingFolder.Id)"
            $currentParentId = $existingFolder.Id
        } else {
            Write-Host "Creando folder: $folderName"
            $createBody = @{
                DisplayName = $folderName
                ParentId = $currentParentId
            } | ConvertTo-Json
            
            try {
                $newFolder = Invoke-RestMethod -Method Post -Uri $foldersUrl -Headers $headers -Body $createBody
                Write-Host "Folder '$folderName' creado con ID: $($newFolder.Id)"
                $currentParentId = $newFolder.Id
            } catch {
                Write-Host "Error creando folder '$folderName': $($_.Exception.Message)"
                exit 1
            }
        }
    }
    
    return $currentParentId
}

# ==============================
# 2. Crear folder jerarquía si se especifica
# ==============================
if ($folderPath) {
    Write-Host "Creando jerarquía de folders: $folderPath"
    $createdFolderId = Create-FolderHierarchy -folderPath $folderPath -org $org -tenant $tenant -headers $headers
    Write-Host "Folder final ID: $createdFolderId"
    # Actualizar headers con el folder ID correcto
    $headers["X-UIPATH-OrganizationUnitId"] = $createdFolderId.ToString()
} else {
    Write-Host "No se especificó folder path, usando folder ID existente: $folderId"
}

# ==============================
# 2. Leer JSON
# ==============================
$sourceDir = $env:BUILD_SOURCESDIRECTORY
if (-not $sourceDir) {
    Write-Host "ERROR: BUILD_SOURCESDIRECTORY no está definido."
    exit 1
}
$assetsPath = Join-Path $sourceDir 'orchestrator\assets\assets.json'
Write-Host "Leyendo assets desde: $assetsPath"
if (-not (Test-Path $assetsPath)) {
    Write-Host "ERROR: no se encontró el archivo de assets en la ruta especificada."
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
    Write-Host "ERROR: no se encontró ningún asset en el JSON"
    exit 1
}
Write-Host "Assets encontrados: $($assets.Count)"
for ($i = 0; $i -lt $assets.Count; $i++) {
    $asset = $assets[$i]
    Write-Host "Asset[$i] Nombre:'$($asset.Name)' Key:'$($asset.Key)' Tipo:'$($asset.ValueType)'"
}

# ==============================
# 3. Endpoint
# ==============================
$assetsUrl = "https://cloud.uipath.com/$org/$tenant/orchestrator_/odata/Assets"

# ==============================
# 4. Crear assets
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
        Invoke-RestMethod -Method Post -Uri $assetsUrl -Headers $headers -Body $json
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
                Write-Host "No se pudo leer el response body de la excepción: $($_.Exception.Message)"
            }
        }
    }
}

Write-Host "🚀 Assets importados"