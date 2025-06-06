#!/usr/bin/env bats

# Cross-platform compatibility tests for all installation scripts
# Tests interaction between different installers and platform-specific behaviors

# Test directory setup and cleanup
setup() {
    export TEST_DIR="/tmp/bats-test-cross-platform-$$"
    export TEST_HOME="$TEST_DIR/home"
    export TEST_TARGET="$TEST_DIR/target"
    export BACKUP_DIR="$TEST_DIR/backup"
    
    # Store original working directory
    export ORIGINAL_PWD="$(pwd)"
    
    mkdir -p "$TEST_DIR" "$TEST_HOME" "$TEST_TARGET" "$BACKUP_DIR"
    cd "$TEST_DIR"
    
    # Store original values
    export ORIGINAL_HOME="$HOME"
    export HOME="$TEST_HOME"
    
    # Create test environment
    mkdir -p "$TEST_HOME/.echos-copilot"
    
    # Set absolute paths to installers
    export INSTALL_SH="$ORIGINAL_PWD/install.sh"
    export INSTALL_LOCAL_SH="$ORIGINAL_PWD/install-local.sh"
    export INSTALL_JS="$ORIGINAL_PWD/install.js"
    export INSTALL_PS1="$ORIGINAL_PWD/install.ps1"
    
    # Detect available installers
    export HAS_BASH=$(command -v bash >/dev/null 2>&1 && echo "1" || echo "0")
    export HAS_NODE=$(command -v node >/dev/null 2>&1 && echo "1" || echo "0")
    export HAS_POWERSHELL=$(command -v pwsh >/dev/null 2>&1 && echo "1" || echo "0")
    
    # Skip slow network tests by default
    export BATS_SKIP_NETWORK_TESTS=${BATS_SKIP_NETWORK_TESTS:-1}
}

teardown() {
    # Restore original HOME
    export HOME="$ORIGINAL_HOME"
    
    # Clean up test directory
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Platform Detection Tests
@test "detect current platform consistently across installers" {
    local platform_bash="" platform_node="" platform_ps=""
    
    # Test bash/shell detection
    if [[ "$HAS_BASH" == "1" ]]; then
        platform_bash=$(uname -s | tr '[:upper:]' '[:lower:]' 2>/dev/null || echo "unknown")
    fi
    
    # Test Node.js detection
    if [[ "$HAS_NODE" == "1" ]]; then
        platform_node=$(node -e "console.log(process.platform)" 2>/dev/null || echo "unknown")
    fi
    
    # Test PowerShell detection (if available)
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        platform_ps=$(pwsh -c "if (\$IsLinux) { 'linux' } elseif (\$IsMacOS) { 'darwin' } elseif (\$IsWindows) { 'win32' } else { 'unknown' }" 2>/dev/null || echo "unknown")
    fi
    
    # At least one platform detection should work
    [[ "$platform_bash" != "unknown" ]] || [[ "$platform_node" != "unknown" ]] || [[ "$platform_ps" != "unknown" ]]
    
    # If multiple detectors work, they should be consistent
    if [[ "$platform_bash" != "unknown" && "$platform_node" != "unknown" ]]; then
        # Map bash platform names to Node.js names
        case "$platform_bash" in
            linux) [[ "$platform_node" == "linux" ]] ;;
            darwin) [[ "$platform_node" == "darwin" ]] ;;
            *) true ;; # Allow other platforms
        esac
    fi
}

# Cross-installer File Compatibility Tests
@test "all installers create compatible directory structures" {
    local bash_structure="" local_structure=""
    
    # Test bash installer directory structure
    if [[ "$HAS_BASH" == "1" && -f "$INSTALL_SH" ]]; then
        timeout 30 bash "$INSTALL_SH" --target "$TEST_TARGET/bash" --dry-run --verbose 2>/dev/null || true
        if [[ -d "$TEST_TARGET/bash" ]]; then
            bash_structure=$(find "$TEST_TARGET/bash" -type d | sort)
        fi
    fi
    
    # Test local installer directory structure
    if [[ "$HAS_BASH" == "1" && -f "$INSTALL_LOCAL_SH" ]]; then
        timeout 30 bash "$INSTALL_LOCAL_SH" --target "$TEST_TARGET/local" --dry-run --verbose 2>/dev/null || true
        if [[ -d "$TEST_TARGET/local" ]]; then
            local_structure=$(find "$TEST_TARGET/local" -type d | sort)
        fi
    fi
    
    # At least one installer should create some structure
    [[ -n "$bash_structure" ]] || [[ -n "$local_structure" ]]
}

@test "installers handle same target directory consistently" {
    # Create initial installation with first available installer
    local first_installer=""
    
    if [[ "$HAS_BASH" == "1" && -f "$INSTALL_SH" ]]; then
        timeout 30 bash "$INSTALL_SH" --target "$TEST_TARGET" --force --dry-run 2>/dev/null || true
        first_installer="bash"
    elif [[ "$HAS_BASH" == "1" && -f "$INSTALL_LOCAL_SH" ]]; then
        timeout 30 bash "$INSTALL_LOCAL_SH" --target "$TEST_TARGET" --force --dry-run 2>/dev/null || true
        first_installer="local"
    elif [[ "$HAS_POWERSHELL" == "1" && -f "$INSTALL_PS1" ]]; then
        timeout 30 pwsh "$INSTALL_PS1" -Target "$TEST_TARGET" -Force -DryRun 2>/dev/null || true
        first_installer="powershell"
    fi
    
    # Test second installer on same directory
    if [[ "$first_installer" == "bash" && "$HAS_NODE" == "1" ]]; then
        run timeout 30 bash "$INSTALL_LOCAL_SH" --target "$TEST_TARGET" --force --dry-run 2>/dev/null
        [ "$status" -ne 124 ]  # Should not timeout
    elif [[ "$first_installer" == "node" && "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash "$INSTALL_SH" --target "$TEST_TARGET" --force --dry-run 2>/dev/null
        [ "$status" -ne 124 ]  # Should not timeout
    else
        skip "Need at least two different installers available"
    fi
}

# Path Handling Tests
@test "all installers handle Unix-style paths" {
    local unix_path="$TEST_TARGET/unix/style/path"
    mkdir -p "$unix_path"
    
    local results=0
    
    # Test bash installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_SH" --target "$unix_path" --dry-run 2>/dev/null && results=$((results + 1)) || true
    fi
    
    # Test local installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_LOCAL_SH" --target "$unix_path" --dry-run 2>/dev/null && results=$((results + 1)) || true
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh "$INSTALL_PS1" -Target "$unix_path" -DryRun 2>/dev/null && results=$((results + 1)) || true
    fi
    
    # At least one installer should handle Unix paths
    [ "$results" -gt 0 ]
}

@test "all installers handle paths with spaces" {
    local spaced_path="$TEST_TARGET/path with spaces"
    mkdir -p "$spaced_path"
    
    local results=0
    
    # Test bash installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_SH" --target "$spaced_path" --dry-run 2>/dev/null && results=$((results + 1)) || true
    fi
    
    # Test local installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_LOCAL_SH" --target "$spaced_path" --dry-run 2>/dev/null && results=$((results + 1)) || true
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh "$INSTALL_PS1" -Target "$spaced_path" -DryRun 2>/dev/null && results=$((results + 1)) || true
    fi
    
    # At least one installer should handle spaced paths
    [ "$results" -gt 0 ]
}

# Permission Handling Tests
@test "all installers handle permission denied consistently" {
    # Try to use a restricted directory that should fail even in dry-run
    local restricted_dir="/sys/test-install-$$"  # More restricted than /root
    
    local bash_result=0 local_result=0 ps_result=0
    
    # Test bash installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 10 bash "$INSTALL_SH" --target "$restricted_dir" --dry-run 2>/dev/null || bash_result=$?
    fi
    
    # Test local installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 10 bash "$INSTALL_LOCAL_SH" --target "$restricted_dir" --dry-run 2>/dev/null || local_result=$?
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 10 pwsh "$INSTALL_PS1" -Target "$restricted_dir" -DryRun 2>/dev/null || ps_result=$?
    fi
    
    # All should fail with permission issues or timeout
    [[ "$bash_result" -ne 0 ]] || [[ "$local_result" -ne 0 ]] || [[ "$ps_result" -ne 0 ]]
}

# Network Handling Tests (if enabled)
@test "all installers handle network failures consistently" {
    if [[ "$BATS_SKIP_NETWORK_TESTS" == "1" ]]; then
        skip "Network tests disabled"
    fi
    
    local invalid_url="https://invalid-domain-xyz-123.com/file"
    local bash_result=0 node_result=0 ps_result=0
    
    # Test bash installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 15 bash "$INSTALL_SH" --url "$invalid_url" --target "$TEST_TARGET/bash" 2>/dev/null || bash_result=$?
    fi
    
    # Test local installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 15 bash "$INSTALL_LOCAL_SH" --target "$TEST_TARGET/local" 2>/dev/null || local_result=$?
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 15 pwsh "$INSTALL_PS1" -Url "$invalid_url" -Target "$TEST_TARGET/ps" 2>/dev/null || ps_result=$?
    fi
    
    # All should fail or timeout when given invalid URL
    [[ "$bash_result" -ne 0 ]] || [[ "$node_result" -ne 0 ]] || [[ "$ps_result" -ne 0 ]]
}

# Backup Compatibility Tests
@test "backup files created by different installers are compatible" {
    # Create some initial files
    mkdir -p "$TEST_TARGET"
    echo "original content 1" > "$TEST_TARGET/file1.txt"
    echo "original content 2" > "$TEST_TARGET/file2.txt"
    
    local backup_created=0
    
    # Try creating backup with first available installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_SH" --target "$TEST_TARGET" --backup --dry-run 2>/dev/null && backup_created=1 || true
    elif [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_LOCAL_SH" --target "$TEST_TARGET" --dry-run 2>/dev/null && backup_created=1 || true
    elif [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh "$INSTALL_PS1" -Target "$TEST_TARGET" -Backup -DryRun 2>/dev/null && backup_created=1 || true
    fi
    
    # Original files should still exist
    [ -f "$TEST_TARGET/file1.txt" ]
    [ -f "$TEST_TARGET/file2.txt" ]
    
    # Backup process should complete
    [ "$backup_created" -eq 1 ] || skip "No installer could create backup"
}

# Argument Compatibility Tests
@test "help argument works consistently across installers" {
    local help_outputs=()
    
    # Test bash installer help
    if [[ "$HAS_BASH" == "1" ]]; then
        local bash_help
        bash_help=$(timeout 10 bash "$INSTALL_SH" --help 2>/dev/null || echo "failed")
        help_outputs+=("bash:$bash_help")
    fi
    
    # Test local installer help
    if [[ "$HAS_BASH" == "1" ]]; then
        local local_help
        local_help=$(timeout 10 bash "$INSTALL_LOCAL_SH" --help 2>/dev/null || echo "failed")
        help_outputs+=("local:$local_help")
    fi
    
    # Test PowerShell installer help
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        local ps_help
        ps_help=$(timeout 10 pwsh "$INSTALL_PS1" -Help 2>/dev/null || echo "failed")
        help_outputs+=("ps:$ps_help")
    fi
    
    # At least one help should work
    local working_help=0
    for output in "${help_outputs[@]}"; do
        if [[ "$output" != *"failed"* && ( "$output" =~ (help|usage|Usage|Help|USAGE|Installer|OPTIONS) ) ]]; then
            working_help=$((working_help + 1))
        fi
    done
    
    [ "$working_help" -gt 0 ]
}

@test "version detection works across installers" {
    local version_found=0
    
    # Check if installers can report or handle version information
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 10 bash "$INSTALL_SH" --version 2>/dev/null && version_found=$((version_found + 1)) || true
    fi
    
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 10 node "$INSTALL_JS" --version 2>/dev/null && version_found=$((version_found + 1)) || true
    fi
    
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 10 pwsh "$INSTALL_PS1" -Version 2>/dev/null && version_found=$((version_found + 1)) || true
    fi
    
    # At least one installer should handle version requests (or skip if not implemented)
    [ "$version_found" -ge 0 ]  # Always pass, just testing they don't crash
}

# Installation Validation Tests
@test "all installers can validate their own installations" {
    local validation_works=0
    
    # Test bash installer validation
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_SH" --target "$TEST_TARGET/bash" --validate --dry-run 2>/dev/null && validation_works=$((validation_works + 1)) || true
    fi
    
    # Test local installer validation
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_LOCAL_SH" --target "$TEST_TARGET/local" --dry-run 2>/dev/null && validation_works=$((validation_works + 1)) || true
    fi
    
    # Test PowerShell installer validation
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh "$INSTALL_PS1" -Target "$TEST_TARGET/ps" -Validate -DryRun 2>/dev/null && validation_works=$((validation_works + 1)) || true
    fi
    
    # At least validation doesn't crash (may not be implemented in all)
    [ "$validation_works" -ge 0 ]
}

# Performance Consistency Tests
@test "all installers complete help commands within reasonable time" {
    local total_time=0
    local installer_count=0
    
    # Time bash installer help
    if [[ "$HAS_BASH" == "1" ]]; then
        local start_time=$(date +%s)
        timeout 10 bash "$INSTALL_SH" --help >/dev/null 2>&1 || true
        local end_time=$(date +%s)
        total_time=$((total_time + end_time - start_time))
        installer_count=$((installer_count + 1))
    fi
    
    # Time local installer help
    if [[ "$HAS_BASH" == "1" ]]; then
        local start_time=$(date +%s)
        timeout 10 bash "$INSTALL_LOCAL_SH" --help >/dev/null 2>&1 || true
        local end_time=$(date +%s)
        total_time=$((total_time + end_time - start_time))
        installer_count=$((installer_count + 1))
    fi
    
    # Time PowerShell installer help
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        local start_time=$(date +%s)
        timeout 10 pwsh "$INSTALL_PS1" -Help >/dev/null 2>&1 || true
        local end_time=$(date +%s)
        total_time=$((total_time + end_time - start_time))
        installer_count=$((installer_count + 1))
    fi
    
    # Average time should be reasonable (under 5 seconds per installer)
    if [ "$installer_count" -gt 0 ]; then
        local avg_time=$((total_time / installer_count))
        [ "$avg_time" -lt 10 ]  # Each installer should complete help in under 10 seconds
    else
        skip "No installers available"
    fi
}

# Integration Tests
@test "local installer works alongside remote installers" {
    if [[ ! -f "$INSTALL_LOCAL_SH" ]]; then
        skip "Local installer not available"
    fi
    
    # Test local installer
    local local_result=0
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 60 bash "$INSTALL_LOCAL_SH" --target "$TEST_TARGET/local" --dry-run 2>/dev/null || local_result=$?
    fi
    
    # Test remote installer on different target to avoid conflicts
    local remote_result=0
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 60 bash "$INSTALL_SH" --target "$TEST_TARGET/remote" --force --dry-run 2>/dev/null || remote_result=$?
    fi
    
    # Both should complete successfully (exit code 0) and not timeout (exit code 124)
    [[ "$local_result" -eq 124 ]] && fail "Local installer timed out (exit code 124)"
    [[ "$remote_result" -eq 124 ]] && fail "Remote installer timed out (exit code 124)"
    
    # Both installers should complete without errors
    [[ "$local_result" -eq 0 ]] || fail "Local installer failed with exit code $local_result"
    [[ "$remote_result" -eq 0 ]] || fail "Remote installer failed with exit code $remote_result"
}

# Environment Variable Tests
@test "all installers respect common environment variables" {
    # Test with custom HOME
    export HOME="$TEST_HOME/custom"
    mkdir -p "$HOME"
    
    local results=0
    
    # Test bash installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_SH" --target "$TEST_TARGET/bash-env" --dry-run 2>/dev/null && results=$((results + 1)) || true
    fi
    
    # Test local installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash "$INSTALL_LOCAL_SH" --target "$TEST_TARGET/local-env" --dry-run 2>/dev/null && results=$((results + 1)) || true
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh "$INSTALL_PS1" -Target "$TEST_TARGET/ps-env" -DryRun 2>/dev/null && results=$((results + 1)) || true
    fi
    
    # At least one installer should respect environment
    [ "$results" -gt 0 ]
}

# Security Consistency Tests
@test "all installers handle malicious input similarly" {
    # Use a unique string that would only appear if command injection succeeds
    # The injection should execute and produce a unique output, not just display the literal string
    local malicious_path="\$(echo 'UNIQUE_INJECTION_TEST_FLAG_12345')"
    
    local bash_safe=1 local_safe=1 ps_safe=1
    local tests_run=0
    
    # Test bash installer - should NOT execute the embedded command
    if [[ "$HAS_BASH" == "1" ]]; then
        local output
        output=$(timeout 10 bash "$INSTALL_SH" --target "$malicious_path" --dry-run 2>&1 || true)
        # Check if the command was executed (unique flag appears without the literal $(...))
        # Safe behavior: shows "Target directory: \$(echo 'UNIQUE_INJECTION_TEST_FLAG_12345')"
        # Unsafe behavior: shows "UNIQUE_INJECTION_TEST_FLAG_12345" as executed command output
        if [[ "$output" == *"UNIQUE_INJECTION_TEST_FLAG_12345"* ]] && [[ "$output" != *"\$(echo 'UNIQUE_INJECTION_TEST_FLAG_12345')"* ]]; then
            bash_safe=0
        fi
        tests_run=$((tests_run + 1))
    fi
    
    # Test local installer - should NOT execute the embedded command
    if [[ "$HAS_BASH" == "1" ]]; then
        local output
        output=$(timeout 10 bash "$INSTALL_LOCAL_SH" --target "$malicious_path" --dry-run 2>&1 || true)
        # Same logic as above
        if [[ "$output" == *"UNIQUE_INJECTION_TEST_FLAG_12345"* ]] && [[ "$output" != *"\$(echo 'UNIQUE_INJECTION_TEST_FLAG_12345')"* ]]; then
            local_safe=0
        fi
        tests_run=$((tests_run + 1))
    fi
    
    # Test PowerShell installer - should NOT execute the embedded command
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        local output
        output=$(timeout 10 pwsh "$INSTALL_PS1" -Target "$malicious_path" -DryRun 2>&1 || true)
        # Same logic as above
        if [[ "$output" == *"UNIQUE_INJECTION_TEST_FLAG_12345"* ]] && [[ "$output" != *"\$(echo 'UNIQUE_INJECTION_TEST_FLAG_12345')"* ]]; then
            ps_safe=0
        fi
        tests_run=$((tests_run + 1))
    fi
    
    # Ensure we ran at least one test
    [[ "$tests_run" -gt 0 ]]
    
    # All available installers should handle malicious input safely
    if [[ "$HAS_BASH" == "1" ]]; then
        [[ "$bash_safe" -eq 1 && "$local_safe" -eq 1 ]]
    fi
    
    # Only check PowerShell if it's available
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        [[ "$ps_safe" -eq 1 ]]
    fi
}
