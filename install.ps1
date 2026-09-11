# Installs:
#   - Copies profile.ps1 from this directory to $PROFILE
#   - Optionally installs Winget packages (Windows only)

# -----------------------------------------
# Winget dependencies
# Add/remove packages here.
# Name = Display name (decorative)
# Id   = Winget package ID
# -----------------------------------------

$WingetPackages = @(
    @{
        Name = "Fastfetch"
        Id   = "Fastfetch-cli.Fastfetch"
    }
    # @{
    #     Name = "Git"
    #     Id   = "Git.Git"
    # }
    # @{
    #     Name = "7-Zip"
    #     Id   = "7zip.7zip"
    # }
    # @{
    #     Name = "Neovim"
    #     Id   = "Neovim.Neovim"
    # }
)

# -----------------------------------------
# Winget installs (Windows only)
# -----------------------------------------

if ($IsWindows -or $env:OS -eq "Windows_NT") {

    $winget = Get-Command winget -ErrorAction SilentlyContinue

    if (-not $winget) {
        Write-Warning "winget is not installed. Skipping package installation."
    }
    else {

        $InstallRemaining = $false
        $SkipRemaining    = $false

        foreach ($pkg in $WingetPackages) {

            $Install = $InstallRemaining

            if (-not $InstallRemaining) {
                Write-Host ""
                Write-Host "Install $($pkg.Name)?"
                Write-Host '[Y] Yes   [A] All remaining   [N] No (default)   [L] No to all remaining'

                $choice = (Read-Host "Choice").Trim().ToUpper()

                switch ($choice) {
                    "Y" {
                        $Install = $true
                    }
                    "A" {
                        $InstallRemaining = $true
                        $Install = $true
                    }
                    "L" {
                        $SkipRemaining = $true
                        $Install = $false
                    }
                    default {
                        Write-Host "Skipped."
                        $Install = $false
                    }
                }
            }

            if ($SkipRemaining) {
                break
            }

            if (-not $Install) {
                continue
            }

            Write-Host ""
            Write-Host "Installing $($pkg.Name)..."

            winget install `
                --id $pkg.Id `
                --exact `
                --accept-package-agreements `
                --accept-source-agreements
        }

        Write-Host ""
    }
}
else {
    Write-Host "Linux detected."
    Write-Host "Winget package installation skipped."
}

# -----------------------------------------
# Config Dir install
# -----------------------------------------

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path $ScriptDir "config"
$TargetDir = Join-Path $HOME ".config"

if (-not (Test-Path $SourceDir)) {
    Write-Error "config directory not found: $SourceDir"
    exit 1
}

# Make target dir exist
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

# Copy contents of config/ into ~/.config/
Copy-Item "$SourceDir\*" -Destination $TargetDir -Recurse -Force

# -----------------------------------------
# Profile install
# -----------------------------------------

# Ensure the user's profile exists
$ProfileDir = Split-Path $PROFILE -Parent
New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$ConfigProfileDir = Join-Path $HOME ".config/powershell"

if (-not (Test-Path $ConfigProfileDir)) {
    Write-Error "PowerShell config directory not found: $ConfigProfileDir"
    exit 1
}

# Find every .ps1 file in ~/.config/powershell
$ProfileFiles = Get-ChildItem -Path $ConfigProfileDir -Filter "*.ps1" -File

if ($ProfileFiles.Count -eq 0) {
    Write-Error "No .ps1 files found in: $ConfigProfileDir"
    exit 1
}

# Add a loader for each profile file
foreach ($ProfileFile in $ProfileFiles) {
    $Loader = ". `"$($ProfileFile.FullName)`""

    if (-not (Select-String -Path $PROFILE -SimpleMatch $Loader -Quiet)) {
        Add-Content -Path $PROFILE -Value @"

# Load $($ProfileFile.Name)
$Loader

"@
    }

    Write-Host "Installed profile:"
    Write-Host "  $($ProfileFile.FullName)"
}

Write-Host ""
Write-Host "Done."