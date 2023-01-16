[CmdletBinding()]
param (
    [string]$InstallAtCustomPath,
    [switch]$InstallForSystem
)

### ============================================================================
### Helper Functions
### ============================================================================
function checkModulePathInEnvVar {
    param(
        [string]$targetModulePath
    )

    foreach ($checkPath in $env:PSModulePath.Split(';')) {
        if ($checkPath -eq $targetModulePath) {
            return $true
        }
    }
}

## ===== VALIDATE ELEVATED IF InstallForSystem SELECTED ========================
if ($InstallForSystem) {
    $elevated = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (!$elevated) {
        Write-Warning "To install for the system, please run in an elevated prompt"
        break
    }
}

## ===== VALIDATE SOURCE PATH ==================================================
# Pull the .psd1 files and check to make sure there is only one
$psd1ItemObject = Get-ChildItem .\ -Recurse | Where-Object {$_.Extension -eq ".psd1"}
if ($psd1ItemObject.Count -gt 1) {
    Write-Error "SOURCE: More than one .psd1 file was detected."
    return
}

# Read the .psd1 file and convert it to a PSCustomObject
Write-Verbose "SOURCE: Manifest file found at $($psd1ItemObject.FullName). Preforming checks."
$psd1FileHash = Import-PowerShellDataFile $psd1ItemObject.FullName
$psd1FileObject = [PSCustomObject]$psd1FileHash

# Set importtant variables
$sourceModuleName     = $psd1ItemObject.BaseName
$sourceModulePath     = $psd1ItemObject.DirectoryName
$sourceModulePathName = $psd1ItemObject.Directory.Name
$psm1FilePath         = $sourceModulePath + "\" + $psd1FileObject.RootModule

# Check that the directory name matches the module name
if ($sourceModuleName -ne $sourceModulePathName) {
    Write-Error "SOURCE: The .psd1 file name ($sourceModuleName) does not match the root directory name ($sourceModulePathName) at $sourceModulePath."
    return
}

# Check that the module file exists
if (!(Test-Path $psm1FilePath)) {
    Write-Error "SOURCE: The .psm1 file ($psm1FilePath) could not be found in $sourceModulePath."
    return
}

Write-Verbose "SOURCE: File checks passed."
Write-Host "Installing module: "-NoNewline
Write-Host $sourceModuleName -ForegroundColor Cyan

## ===== VALIDATE TARGET PATH ==================================================
# Set the target module path
if ($InstallForSystem) {
    $targetModulePath = 'C:\Program Files\WindowsPowerShell\Modules'
} elseif ($InstallAtCustomPath -ne "") {
    $targetModulePath = $InstallAtCustomPath
} else {
    $targetModulePath = $Env:USERPROFILE + '\Documents\WindowsPowerShell\Modules'
}

Write-Verbose "TARGET: Path designated as $targetModulePath. Performing Checks."

# Test that the target module path exists, and create it if not
if (!(Test-Path $targetModulePath)) {
    Write-Warning "TARGET: Target path ($targetModulePath) does not exist. It will be created.."
    New-Item -ItemType Directory -Path $targetModulePath
}

# Check to see if the target path exists in the PSModulePath variable already
if (!(checkModulePathInEnvVar -targetModulePath $targetModulePath)) {
    Write-Warning "TARGET: Target path ($targetModulePath) does not exist in the PSModulePath variable. It will need to be added manually"
}

Write-Verbose "TARGET: File checks passed"

## ===== COPY MODULE FILES =====================================================
Write-Verbose "COPY: Copying files to $targetModulePath"
Copy-Item -Path $sourceModulePath -Destination $targetModulePath -Recurse -Force
Write-Verbose "COPY: Successfully copied files to $targetModulePath"

## ===== VALIDATE INSTALLATION =================================================
Write-Verbose "VALIDATE: Validating module $sourceModuleName"
$moduleObject = Get-Module -ListAvailable | Where-Object {$_.Name -eq $sourceModuleName}
if ($moduleObject -ne "") {
    Write-Verbose "VALIDATE: Module $sourceModuleName successfully installed"
    Write-Host "Module $sourceModuleName successfully installed in $targetModulePath"
}
else {
    Write-Error "Module $sourceModuleName failed to install successfully"
}

## ===== IMPORT & PRINT ========================================================
Write-Host ""
Write-Host "----------------------------------------------------------------------------------------"
Write-Host "Commands available in the " -NoNewline
Write-Host $sourceModuleName -NoNewline -ForegroundColor Cyan
Write-Host " module:"
Import-Module $sourceModuleName -Force
Get-Command -Module $sourceModuleName
Write-Host ""
Write-Host 'Please run "Get-Help <command name> -Full" for more information on these commands'