# ==============================
# Variables desde Azure DevOps
# ==============================
$org = $env:UIPATH_ORG
$tenant = $env:UIPATH_TENANT
$clientId = $env:UIPATH_CLIENT_ID
$clientSecret = $env:UIPATH_CLIENT_SECRET
$folderId = $env:UIPATH_FOLDER_ID

# ==============================
# 1. Obtener token
# ==============================
$tokenUrl = "https://cloud.uipath.com/$org/identity_/connect/token"

$body = @{
    grant_type = "client_credentials"
    client_id = $clientId
    client_secret = $clientSecret
    scope = "OR.Assets.Read OR.Assets.Write"
}

$response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body

$accessToken = $response.access_token

# ==============================
# Headers
# ==============================
$headers = @{
    Authorization = "Bearer $accessToken"
    "X-UIPATH-OrganizationUnitId" = $folderId
    "Content-Type" = "application/json"
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
    }
}

Write-Host "🚀 Assets importados"