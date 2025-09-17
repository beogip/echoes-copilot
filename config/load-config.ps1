# PowerShell Configuration Loader
# config/load-config.ps1 - PowerShell utility to load echo configuration

function Load-EchoConfig {
    $configPath = Join-Path $PSScriptRoot "echo-constants.json"
    
    if (-not (Test-Path $configPath)) {
        $configPath = Join-Path (Split-Path $PSScriptRoot) "config/echo-constants.json"
        if (-not (Test-Path $configPath)) {
            Write-Warning "Could not find echo-constants.json, using defaults"
            return $null
        }
    }
    
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        return $config
    } catch {
        Write-Warning "Failed to load echo configuration: $($_.Exception.Message)"
        return $null
    }
}

function Get-EchoFiles {
    $config = Load-EchoConfig
    if ($config -and $config.echos) {
        $extension = $config.files.extension
        return $config.echos | ForEach-Object { $_.name + $extension }
    } else {
        return @("diagnostic.prompt.md", "planning.prompt.md", "evaluation.prompt.md", 
                "optimization.prompt.md", "coherence.prompt.md", "prioritization.prompt.md")
    }
}

function Get-PromptsDir {
    $config = Load-EchoConfig
    if ($config -and $config.paths) {
        return $config.paths.prompts_dir
    } else {
        return ".github/prompts"
    }
}

function Get-FileExtension {
    $config = Load-EchoConfig
    if ($config -and $config.files) {
        return $config.files.extension
    } else {
        return ".prompt.md"
    }
}
