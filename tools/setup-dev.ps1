[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$addonsRoot = "C:\Users\zurip\Documents\Elder Scrolls Online\live\AddOns"
$linkPath = Join-Path $addonsRoot "EZOcamsens"

Write-Host "Project root: $projectRoot"
Write-Host "AddOns root:  $addonsRoot"
Write-Host "Link path:    $linkPath"

if (-not (Test-Path -LiteralPath $addonsRoot)) {
    throw "No existe la carpeta de AddOns: $addonsRoot"
}

$policySummary = Get-ExecutionPolicy -List | ForEach-Object {
    "{0}={1}" -f $_.Scope, $_.ExecutionPolicy
}
Write-Host ("PowerShell ExecutionPolicy: " + ($policySummary -join ", "))

$existing = Get-Item -LiteralPath $linkPath -ErrorAction SilentlyContinue

if ($null -ne $existing) {
    if ($existing.LinkType -eq "SymbolicLink") {
        $currentTarget = [string]$existing.Target
        if ($currentTarget -eq $projectRoot) {
            Write-Host "El symlink ya existe y apunta al proyecto."
            exit 0
        }

        if (-not $Force) {
            throw "Ya existe un symlink en $linkPath apuntando a '$currentTarget'. Usa -Force para reemplazarlo."
        }

        Write-Host "Reemplazando symlink existente..."
        Remove-Item -LiteralPath $linkPath -Force
    }
    else {
        throw "Ya existe una carpeta o archivo real en $linkPath. No se toca automáticamente."
    }
}

try {
    New-Item -ItemType SymbolicLink -Path $linkPath -Target $projectRoot | Out-Null
    Write-Host "Symlink creado correctamente."
}
catch [System.UnauthorizedAccessException] {
    throw "No hay privilegios suficientes para crear el symlink. Ejecuta PowerShell como administrador y vuelve a lanzar .\\tools\\setup-dev.ps1."
}
