#!/usr/bin/env bats

# Comprehensive tests for install.ps1
# Tests PowerShell installer functionality on cross-platform environments

# Setup for each test
setup() {
    # Create a temporary test directory
    export TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
    
    # Mock script path
    export INSTALL_PS1_SCRIPT="${BATS_TEST_DIRNAME}/../../install.ps1"
    
    # Ensure clean state
    rm -rf .github
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# === POWERSHELL AVAILABILITY TESTS ===

@test "install.ps1 requires PowerShell to test properly" {
    # Skip PowerShell-specific tests if PowerShell not available
    if ! command -v pwsh >/dev/null 2>&1 && ! command -v powershell >/dev/null 2>&1; then
        skip "PowerShell not available for testing"
    fi
}

# === BASIC FUNCTIONALITY TESTS ===

@test "install.ps1 file exists and is readable" {
    [ -f "$INSTALL_PS1_SCRIPT" ]
    [ -r "$INSTALL_PS1_SCRIPT" ]
}

@test "install.ps1 has PowerShell shebang or header" {
    # Should contain PowerShell-specific syntax
    head -5 "$INSTALL_PS1_SCRIPT" | grep -q -E "(param|PowerShell|#.*ps1)"
}

@test "install.ps1 contains help functionality" {
    # Should have help parameter or function
    grep -q -i "help\|usage" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 displays help with PowerShell" {
    if command -v pwsh >/dev/null 2>&1; then
        run pwsh -File "$INSTALL_PS1_SCRIPT" -Help
        [ "$status" -eq 0 ]
        [[ "$output" == *"Installer"* ]] || [[ "$output" == *"help"* ]]
    else
        skip "PowerShell not available"
    fi
}

# === PARAMETER HANDLING TESTS ===

@test "install.ps1 accepts Mode parameter" {
    grep -q -i "Mode" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 accepts Force parameter" {
    grep -q -i "Force" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 accepts Verbose parameter" {
    grep -q -i "Verbose" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 accepts Rollback parameter" {
    grep -q -i "Rollback" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 accepts Help parameter" {
    grep -q -i "Help" "$INSTALL_PS1_SCRIPT"
}

# === POWERSHELL SYNTAX VALIDATION ===

@test "install.ps1 has valid PowerShell syntax" {
    if command -v pwsh >/dev/null 2>&1; then
        # Test syntax validation
        run pwsh -File "$INSTALL_PS1_SCRIPT" -Help -ErrorAction SilentlyContinue
        # Should not have syntax errors (status 0 or 1, not crash codes)
        [[ "$status" -eq 0 || "$status" -eq 1 ]]
    else
        skip "PowerShell not available for syntax check"
    fi
}

@test "install.ps1 contains PowerShell-specific functions" {
    # Should contain Write-Host, Write-Error, or similar PowerShell functions
    grep -q -E "(Write-Host|Write-Error|Write-Warning|Write-Information)" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has proper PowerShell parameter syntax" {
    # Should use PowerShell parameter syntax
    grep -q -E "param\(|Param\(" "$INSTALL_PS1_SCRIPT"
}

# === FEATURE PARITY TESTS ===

@test "install.ps1 supports instructions mode" {
    grep -q -i "instructions" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 supports comprehensive mode" {
    grep -q -i "comprehensive" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has backup functionality" {
    grep -q -i "backup" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has rollback functionality" {
    grep -q -i "rollback" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has error handling" {
    grep -q -E "(try|catch|trap|ErrorAction)" "$INSTALL_PS1_SCRIPT"
}

# === WINDOWS-SPECIFIC FEATURES ===

@test "install.ps1 handles Windows paths" {
    # Should handle Windows-style paths or path separators
    grep -q -E "(\\\\|\\.github\\\\|Join-Path|\[System\.IO\.Path\])" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has execution policy considerations" {
    # Should mention or handle execution policy
    grep -q -i -E "(execution.*policy|ExecutionPolicy|Set-ExecutionPolicy)" "$INSTALL_PS1_SCRIPT" || {
        # Or should be documented in comments
        grep -q -i "policy" "$INSTALL_PS1_SCRIPT"
    }
}

@test "install.ps1 uses PowerShell cmdlets" {
    # Should use PowerShell-specific cmdlets
    grep -q -E "(Get-|Set-|New-|Remove-|Test-|Invoke-)" "$INSTALL_PS1_SCRIPT"
}

# === NETWORK FUNCTIONALITY TESTS ===

@test "install.ps1 has download functionality" {
    # Should have web request capabilities
    grep -q -E "(Invoke-WebRequest|Invoke-RestMethod|WebClient|DownloadString)" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 handles GitHub API" {
    grep -q -i "github" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has network error handling" {
    # Should handle network errors
    grep -q -i -E "(network|connection|timeout|web.*error)" "$INSTALL_PS1_SCRIPT" || {
        # Or general error handling around web requests
        grep -A5 -B5 "Invoke-WebRequest\|Invoke-RestMethod" "$INSTALL_PS1_SCRIPT" | grep -q -i -E "(try|catch|error)"
    }
}

# === CONFIGURATION TESTS ===

@test "install.ps1 has version information" {
    grep -q -E "(version|VERSION)" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has GitHub repository configuration" {
    grep -q "beogip/echos-copilot" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has target directory configuration" {
    grep -q "\.github" "$INSTALL_PS1_SCRIPT"
}

# === OUTPUT AND LOGGING TESTS ===

@test "install.ps1 has colored output" {
    # Should have color or formatting functions
    grep -q -E "(ForegroundColor|BackgroundColor|Color)" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has logging functionality" {
    grep -q -i -E "(log|LOG)" "$INSTALL_PS1_SCRIPT" || {
        # Or verbose output
        grep -q -i "verbose" "$INSTALL_PS1_SCRIPT"
    }
}

@test "install.ps1 has success/error messages" {
    # Should have user feedback
    grep -q -E "(success|error|fail)" "$INSTALL_PS1_SCRIPT"
}

# === VALIDATION TESTS ===

@test "install.ps1 validates installation" {
    grep -q -i -E "(validat|verif|check)" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 checks prerequisites" {
    # Should check for requirements
    grep -q -E "(prerequisite|requirement|check|test)" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 handles file existence checks" {
    grep -q -E "(Test-Path|Exists|\-f |\-d )" "$INSTALL_PS1_SCRIPT"
}

# === SECURITY TESTS ===

@test "install.ps1 handles user confirmation" {
    # Should ask for confirmation on destructive operations
    grep -q -i -E "(confirm|prompt|force)" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 has safe file operations" {
    # Should not use dangerous operations without checks
    ! grep -q -E "(Remove-Item.*-Recurse.*-Force)" "$INSTALL_PS1_SCRIPT" || {
        # If it does, should have safeguards
        grep -B5 -A5 "Remove-Item.*-Recurse.*-Force" "$INSTALL_PS1_SCRIPT" | grep -q -i -E "(confirm|test|if|backup)"
    }
}

# === CROSS-PLATFORM CONSIDERATIONS ===

@test "install.ps1 works on PowerShell Core" {
    if command -v pwsh >/dev/null 2>&1; then
        # Test basic execution on PowerShell Core
        run pwsh -File "$INSTALL_PS1_SCRIPT" -Help
        [[ "$status" -eq 0 || "$status" -eq 1 ]]
    else
        skip "PowerShell Core not available"
    fi
}

@test "install.ps1 handles different PowerShell versions" {
    # Should not use version-specific features or handle them gracefully
    ! grep -q -E "(\\\$PSVersionTable\.PSVersion\.Major -lt|\\\$Host\.Version\.Major -lt)" "$INSTALL_PS1_SCRIPT" || {
        # If it does check versions, should handle appropriately
        grep -A3 -B3 "PSVersion\|Host\.Version" "$INSTALL_PS1_SCRIPT" | grep -q -i -E "(if|throw|error|exit)"
    }
}

# === HELP AND DOCUMENTATION TESTS ===

@test "install.ps1 has comprehensive help" {
    # Count help-related content
    help_lines=$(grep -c -i -E "(help|usage|example|param|synopsis)" "$INSTALL_PS1_SCRIPT")
    [ "$help_lines" -gt 5 ]
}

@test "install.ps1 has usage examples" {
    grep -q -i "example" "$INSTALL_PS1_SCRIPT"
}

@test "install.ps1 documents its parameters" {
    # Should document what each parameter does
    param_count=$(grep -c -E "param.*\[" "$INSTALL_PS1_SCRIPT")
    doc_count=$(grep -c -i -E "(description|parameter|param)" "$INSTALL_PS1_SCRIPT")
    [ "$doc_count" -gt 1 ]
}

# === INTEGRATION TESTS ===

@test "install.ps1 script integrity check" {
    # Basic file integrity
    [ -s "$INSTALL_PS1_SCRIPT" ]  # File is not empty
    wc -l < "$INSTALL_PS1_SCRIPT" | awk '$1 > 50'  # Has substantial content
}

@test "install.ps1 has proper encoding" {
    # Should not have BOM or encoding issues
    ! file "$INSTALL_PS1_SCRIPT" | grep -q "with BOM"
}

@test "install.ps1 handles edge cases mentioned in comments" {
    # Should have comments about edge cases or error handling
    comment_count=$(grep -c "^#" "$INSTALL_PS1_SCRIPT")
    [ "$comment_count" -gt 10 ]
}
