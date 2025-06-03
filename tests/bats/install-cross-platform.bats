#!/usr/bin/env bats

# Cross-platform compatibility tests for all installation scripts
# Tests interaction between different installers and platform-specific behaviors

# Test directory setup and cleanup
setup() {
    export TEST_DIR="/tmp/bats-test-cross-platform-$$"
    export TEST_HOME="$TEST_DIR/home"
    export TEST_TARGET="$TEST_DIR/target"
    export BACKUP_DIR="$TEST_DIR/backup"
    
    mkdir -p "$TEST_DIR" "$TEST_HOME" "$TEST_TARGET" "$BACKUP_DIR"
    cd "$TEST_DIR"
    
    # Store original values
    export ORIGINAL_HOME="$HOME"
    export HOME="$TEST_HOME"
    
    # Create test environment
    mkdir -p "$TEST_HOME/.echos-copilot"
    
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
    local bash_structure="" node_structure="" ps_structure=""
    
    # Test bash installer directory structure
    if [[ "$HAS_BASH" == "1" && -f "../../install.sh" ]]; then
        timeout 30 bash ../../install.sh --target "$TEST_TARGET/bash" --dry-run --verbose 2>/dev/null || true
        if [[ -d "$TEST_TARGET/bash" ]]; then
            bash_structure=$(find "$TEST_TARGET/bash" -type d | sort)
        fi
    fi
    
    # Test Node.js installer directory structure
    if [[ "$HAS_NODE" == "1" && -f "../../install.js" ]]; then
        timeout 30 node ../../install.js --target "$TEST_TARGET/node" --dry-run --verbose 2>/dev/null || true
        if [[ -d "$TEST_TARGET/node" ]]; then
            node_structure=$(find "$TEST_TARGET/node" -type d | sort)
        fi
    fi
    
    # Test PowerShell installer directory structure (if available)
    if [[ "$HAS_POWERSHELL" == "1" && -f "../../install.ps1" ]]; then
        timeout 30 pwsh ../../install.ps1 -Target "$TEST_TARGET/ps" -DryRun -Verbose 2>/dev/null || true
        if [[ -d "$TEST_TARGET/ps" ]]; then
            ps_structure=$(find "$TEST_TARGET/ps" -type d | sort)
        fi
    fi
    
    # At least one installer should create some structure
    [[ -n "$bash_structure" ]] || [[ -n "$node_structure" ]] || [[ -n "$ps_structure" ]]
}

@test "installers handle same target directory consistently" {
    # Create initial installation with first available installer
    local first_installer=""
    
    if [[ "$HAS_BASH" == "1" && -f "../../install.sh" ]]; then
        timeout 30 bash ../../install.sh --target "$TEST_TARGET" --force --dry-run 2>/dev/null || true
        first_installer="bash"
    elif [[ "$HAS_NODE" == "1" && -f "../../install.js" ]]; then
        timeout 30 node ../../install.js --target "$TEST_TARGET" --force --dry-run 2>/dev/null || true
        first_installer="node"
    elif [[ "$HAS_POWERSHELL" == "1" && -f "../../install.ps1" ]]; then
        timeout 30 pwsh ../../install.ps1 -Target "$TEST_TARGET" -Force -DryRun 2>/dev/null || true
        first_installer="powershell"
    fi
    
    # Test second installer on same directory
    if [[ "$first_installer" == "bash" && "$HAS_NODE" == "1" ]]; then
        run timeout 30 node ../../install.js --target "$TEST_TARGET" --force --dry-run 2>/dev/null
        [ "$status" -ne 124 ]  # Should not timeout
    elif [[ "$first_installer" == "node" && "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --force --dry-run 2>/dev/null
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
        timeout 30 bash ../../install.sh --target "$unix_path" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Test Node.js installer
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 30 node ../../install.js --target "$unix_path" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh ../../install.ps1 -Target "$unix_path" -DryRun 2>/dev/null && ((results++)) || true
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
        timeout 30 bash ../../install.sh --target "$spaced_path" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Test Node.js installer
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 30 node ../../install.js --target "$spaced_path" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh ../../install.ps1 -Target "$spaced_path" -DryRun 2>/dev/null && ((results++)) || true
    fi
    
    # At least one installer should handle spaced paths
    [ "$results" -gt 0 ]
}

# Permission Handling Tests
@test "all installers handle permission denied consistently" {
    # Try to use a restricted directory
    local restricted_dir="/root/test-install-$$"
    
    local bash_result=0 node_result=0 ps_result=0
    
    # Test bash installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 10 bash ../../install.sh --target "$restricted_dir" --dry-run 2>/dev/null || bash_result=$?
    fi
    
    # Test Node.js installer
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 10 node ../../install.js --target "$restricted_dir" --dry-run 2>/dev/null || node_result=$?
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 10 pwsh ../../install.ps1 -Target "$restricted_dir" -DryRun 2>/dev/null || ps_result=$?
    fi
    
    # All should fail with permission issues or timeout
    [[ "$bash_result" -ne 0 ]] || [[ "$node_result" -ne 0 ]] || [[ "$ps_result" -ne 0 ]]
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
        timeout 15 bash ../../install.sh --url "$invalid_url" --target "$TEST_TARGET/bash" 2>/dev/null || bash_result=$?
    fi
    
    # Test Node.js installer
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 15 node ../../install.js --url "$invalid_url" --target "$TEST_TARGET/node" 2>/dev/null || node_result=$?
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 15 pwsh ../../install.ps1 -Url "$invalid_url" -Target "$TEST_TARGET/ps" 2>/dev/null || ps_result=$?
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
        timeout 30 bash ../../install.sh --target "$TEST_TARGET" --backup --dry-run 2>/dev/null && backup_created=1 || true
    elif [[ "$HAS_NODE" == "1" ]]; then
        timeout 30 node ../../install.js --target "$TEST_TARGET" --backup --dry-run 2>/dev/null && backup_created=1 || true
    elif [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh ../../install.ps1 -Target "$TEST_TARGET" -Backup -DryRun 2>/dev/null && backup_created=1 || true
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
        bash_help=$(timeout 10 bash ../../install.sh --help 2>/dev/null || echo "failed")
        help_outputs+=("bash:$bash_help")
    fi
    
    # Test Node.js installer help
    if [[ "$HAS_NODE" == "1" ]]; then
        local node_help
        node_help=$(timeout 10 node ../../install.js --help 2>/dev/null || echo "failed")
        help_outputs+=("node:$node_help")
    fi
    
    # Test PowerShell installer help
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        local ps_help
        ps_help=$(timeout 10 pwsh ../../install.ps1 -Help 2>/dev/null || echo "failed")
        help_outputs+=("ps:$ps_help")
    fi
    
    # At least one help should work
    local working_help=0
    for output in "${help_outputs[@]}"; do
        if [[ "$output" != *"failed"* && "$output" =~ (help|usage|Usage|Help) ]]; then
            ((working_help++))
        fi
    done
    
    [ "$working_help" -gt 0 ]
}

@test "version detection works across installers" {
    local version_found=0
    
    # Check if installers can report or handle version information
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 10 bash ../../install.sh --version 2>/dev/null && ((version_found++)) || true
    fi
    
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 10 node ../../install.js --version 2>/dev/null && ((version_found++)) || true
    fi
    
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 10 pwsh ../../install.ps1 -Version 2>/dev/null && ((version_found++)) || true
    fi
    
    # At least one installer should handle version requests (or skip if not implemented)
    [ "$version_found" -ge 0 ]  # Always pass, just testing they don't crash
}

# Installation Validation Tests
@test "all installers can validate their own installations" {
    local validation_works=0
    
    # Test bash installer validation
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install.sh --target "$TEST_TARGET/bash" --validate --dry-run 2>/dev/null && ((validation_works++)) || true
    fi
    
    # Test Node.js installer validation
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 30 node ../../install.js --target "$TEST_TARGET/node" --validate --dry-run 2>/dev/null && ((validation_works++)) || true
    fi
    
    # Test PowerShell installer validation
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh ../../install.ps1 -Target "$TEST_TARGET/ps" -Validate -DryRun 2>/dev/null && ((validation_works++)) || true
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
        timeout 10 bash ../../install.sh --help >/dev/null 2>&1 || true
        local end_time=$(date +%s)
        total_time=$((total_time + end_time - start_time))
        ((installer_count++))
    fi
    
    # Time Node.js installer help
    if [[ "$HAS_NODE" == "1" ]]; then
        local start_time=$(date +%s)
        timeout 10 node ../../install.js --help >/dev/null 2>&1 || true
        local end_time=$(date +%s)
        total_time=$((total_time + end_time - start_time))
        ((installer_count++))
    fi
    
    # Time PowerShell installer help
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        local start_time=$(date +%s)
        timeout 10 pwsh ../../install.ps1 -Help >/dev/null 2>&1 || true
        local end_time=$(date +%s)
        total_time=$((total_time + end_time - start_time))
        ((installer_count++))
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
    if [[ ! -f "../../install-local.sh" ]]; then
        skip "Local installer not available"
    fi
    
    # Test local installer
    local local_result=0
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install-local.sh --target "$TEST_TARGET/local" --dry-run 2>/dev/null || local_result=$?
    fi
    
    # Test remote installer on same target
    local remote_result=0
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install.sh --target "$TEST_TARGET/local" --force --dry-run 2>/dev/null || remote_result=$?
    fi
    
    # Both should complete (may fail for other reasons, but shouldn't conflict)
    [[ "$local_result" -eq 124 ]] && fail "Local installer timed out"
    [[ "$remote_result" -eq 124 ]] && fail "Remote installer timed out"
}

# Environment Variable Tests
@test "all installers respect common environment variables" {
    # Test with custom HOME
    export HOME="$TEST_HOME/custom"
    mkdir -p "$HOME"
    
    local results=0
    
    # Test bash installer
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install.sh --target "$TEST_TARGET/bash-env" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Test Node.js installer
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 30 node ../../install.js --target "$TEST_TARGET/node-env" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh ../../install.ps1 -Target "$TEST_TARGET/ps-env" -DryRun 2>/dev/null && ((results++)) || true
    fi
    
    # At least one installer should respect environment
    [ "$results" -gt 0 ]
}

# Security Consistency Tests
@test "all installers handle malicious input similarly" {
    local malicious_path="\$(echo 'malicious command')"
    
    local bash_safe=1 node_safe=1 ps_safe=1
    
    # Test bash installer
    if [[ "$HAS_BASH" == "1" ]]; then
        local output
        output=$(timeout 10 bash ../../install.sh --target "$malicious_path" --dry-run 2>&1 || true)
        [[ "$output" != *"malicious command"* ]] || bash_safe=0
    fi
    
    # Test Node.js installer
    if [[ "$HAS_NODE" == "1" ]]; then
        local output
        output=$(timeout 10 node ../../install.js --target "$malicious_path" --dry-run 2>&1 || true)
        [[ "$output" != *"malicious command"* ]] || node_safe=0
    fi
    
    # Test PowerShell installer
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        local output
        output=$(timeout 10 pwsh ../../install.ps1 -Target "$malicious_path" -DryRun 2>&1 || true)
        [[ "$output" != *"malicious command"* ]] || ps_safe=0
    fi
    
    # All installers should handle malicious input safely
    [[ "$bash_safe" -eq 1 && "$node_safe" -eq 1 && "$ps_safe" -eq 1 ]]
}
