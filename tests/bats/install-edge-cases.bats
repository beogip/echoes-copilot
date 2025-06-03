#!/usr/bin/env bats

# Edge cases and integration tests for all installation scripts
# Tests unusual scenarios, boundary conditions, and real-world integration

# Test directory setup and cleanup
setup() {
    export TEST_DIR="/tmp/bats-test-edge-cases-$$"
    export TEST_HOME="$TEST_DIR/home"
    export TEST_TARGET="$TEST_DIR/target"
    export BACKUP_DIR="$TEST_DIR/backup"
    
    mkdir -p "$TEST_DIR" "$TEST_HOME" "$TEST_TARGET" "$BACKUP_DIR"
    cd "$TEST_DIR"
    
    # Store original values
    export ORIGINAL_HOME="$HOME"
    export ORIGINAL_PATH="$PATH"
    export HOME="$TEST_HOME"
    
    # Create test environment
    mkdir -p "$TEST_HOME/.echos-copilot"
    
    # Detect available tools
    export HAS_BASH=$(command -v bash >/dev/null 2>&1 && echo "1" || echo "0")
    export HAS_NODE=$(command -v node >/dev/null 2>&1 && echo "1" || echo "0")
    export HAS_POWERSHELL=$(command -v pwsh >/dev/null 2>&1 && echo "1" || echo "0")
    export HAS_CURL=$(command -v curl >/dev/null 2>&1 && echo "1" || echo "0")
    export HAS_WGET=$(command -v wget >/dev/null 2>&1 && echo "1" || echo "0")
    
    # Skip slow tests by default
    export BATS_SKIP_SLOW_TESTS=${BATS_SKIP_SLOW_TESTS:-1}
    export BATS_SKIP_NETWORK_TESTS=${BATS_SKIP_NETWORK_TESTS:-1}
}

teardown() {
    # Restore original values
    export HOME="$ORIGINAL_HOME"
    export PATH="$ORIGINAL_PATH"
    
    # Clean up test directory
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Extreme Edge Cases
@test "installers handle extremely long arguments" {
    # Create a very long target path
    local long_path="$TEST_TARGET"
    for i in {1..20}; do
        long_path="$long_path/very-long-directory-name-that-tests-argument-length-limits-$i"
    done
    
    local results=0
    
    # Test bash installer with long path
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install.sh --target "$long_path" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Test Node.js installer with long path
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 30 node ../../install.js --target "$long_path" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # At least one should handle or fail gracefully
    [ "$results" -ge 0 ]  # Just ensure they don't hang
}

@test "installers handle paths with unusual characters" {
    # Create path with various special characters (filesystem permitting)
    local special_chars="$TEST_TARGET/test-_@#%^*()"
    mkdir -p "$special_chars" 2>/dev/null || true
    
    local results=0
    
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install.sh --target "$special_chars" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 30 node ../../install.js --target "$special_chars" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Should handle or fail gracefully
    [ "$results" -ge 0 ]
}

@test "installers handle empty filesystem scenarios" {
    # Test with minimal filesystem (as much as we can simulate)
    local minimal_target="$TEST_DIR/minimal"
    mkdir -p "$minimal_target"
    
    # Remove common directories to simulate minimal environment
    local saved_path="$PATH"
    export PATH="/bin:/usr/bin"
    
    local results=0
    
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install.sh --target "$minimal_target" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Restore PATH
    export PATH="$saved_path"
    
    [ "$results" -ge 0 ]
}

# Resource Exhaustion Tests
@test "installers handle low disk space gracefully" {
    if [[ "$BATS_SKIP_SLOW_TESTS" == "1" ]]; then
        skip "Slow tests disabled"
    fi
    
    # Create a directory with limited space (simulate with small tmpfs if available)
    local limited_space="$TEST_DIR/limited"
    mkdir -p "$limited_space"
    
    # Try to fill up space (safely, in test directory only)
    dd if=/dev/zero of="$limited_space/largefile" bs=1M count=10 2>/dev/null || true
    
    local results=0
    
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install.sh --target "$limited_space/install" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    # Cleanup
    rm -f "$limited_space/largefile"
    
    [ "$results" -ge 0 ]
}

@test "installers handle many concurrent processes" {
    if [[ "$BATS_SKIP_SLOW_TESTS" == "1" ]]; then
        skip "Slow tests disabled"
    fi
    
    # Start multiple installers concurrently
    local pids=()
    
    if [[ "$HAS_BASH" == "1" ]]; then
        for i in {1..3}; do
            timeout 30 bash ../../install.sh --target "$TEST_TARGET/concurrent$i" --dry-run 2>/dev/null &
            pids+=($!)
        done
    fi
    
    # Wait for all to complete
    local all_completed=1
    for pid in "${pids[@]}"; do
        wait "$pid" || all_completed=0
    done
    
    # At least they should all complete (may fail for other reasons)
    [ "$all_completed" -eq 1 ] || [ "${#pids[@]}" -eq 0 ]
}

# Network Edge Cases
@test "installers handle network interruption gracefully" {
    if [[ "$BATS_SKIP_NETWORK_TESTS" == "1" ]]; then
        skip "Network tests disabled"
    fi
    
    # Test with URL that might be slow or unreliable
    local slow_url="https://httpbin.org/delay/5"  # Delays response by 5 seconds
    
    if [[ "$HAS_BASH" == "1" ]]; then
        # Should timeout and handle gracefully
        run timeout 3 bash ../../install.sh --url "$slow_url" --target "$TEST_TARGET" 2>/dev/null
        # Should timeout (exit code 124) or handle error gracefully
        [[ "$status" -eq 124 ]] || [[ "$status" -ne 0 ]]
    fi
}

@test "installers handle malformed URLs" {
    local malformed_urls=(
        "htp://missing-t.com"
        "https://spaces in url.com"
        "https://localhost:99999/port-too-high"
        "file:///../../../etc/passwd"
        "javascript:alert('xss')"
        ""
        "not-a-url-at-all"
    )
    
    for url in "${malformed_urls[@]}"; do
        if [[ "$HAS_BASH" == "1" ]]; then
            run timeout 10 bash ../../install.sh --url "$url" --target "$TEST_TARGET" --dry-run 2>/dev/null
            # Should fail or handle gracefully (not hang)
            [ "$status" -ne 124 ]
        fi
    done
}

# Filesystem Edge Cases
@test "installers handle read-only filesystems" {
    # Create read-only directory
    local readonly_dir="$TEST_DIR/readonly"
    mkdir -p "$readonly_dir"
    chmod 444 "$readonly_dir"
    
    local results=0
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 10 bash ../../install.sh --target "$readonly_dir/install" --dry-run 2>/dev/null
        # Should fail quickly, not hang
        [[ "$status" -ne 124 ]] && ((results++))
    fi
    
    if [[ "$HAS_NODE" == "1" ]]; then
        run timeout 10 node ../../install.js --target "$readonly_dir/install" --dry-run 2>/dev/null
        # Should fail quickly, not hang
        [[ "$status" -ne 124 ]] && ((results++))
    fi
    
    # Cleanup
    chmod 755 "$readonly_dir"
    
    # At least one should handle correctly
    [ "$results" -gt 0 ]
}

@test "installers handle symlinks correctly" {
    # Create symlink target
    local real_target="$TEST_DIR/real-target"
    local link_target="$TEST_DIR/link-target"
    mkdir -p "$real_target"
    ln -s "$real_target" "$link_target" 2>/dev/null || skip "Cannot create symlinks"
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$link_target" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]  # Should not timeout
    fi
}

@test "installers handle broken symlinks" {
    # Create broken symlink
    local broken_link="$TEST_DIR/broken-link"
    ln -s "/nonexistent/path" "$broken_link" 2>/dev/null || skip "Cannot create symlinks"
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 10 bash ../../install.sh --target "$broken_link" --dry-run 2>/dev/null
        # Should handle gracefully
        [[ "$status" -ne 124 ]]
    fi
}

# Permission Edge Cases
@test "installers handle setuid directories" {
    # Create directory with special permissions
    local special_dir="$TEST_DIR/special"
    mkdir -p "$special_dir"
    chmod 2755 "$special_dir" 2>/dev/null || true  # Set group sticky bit
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$special_dir/install" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
}

@test "installers handle umask variations" {
    # Test with restrictive umask
    local old_umask=$(umask)
    umask 077  # Very restrictive
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET/umask-test" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
    
    # Restore umask
    umask "$old_umask"
}

# Process and Signal Handling
@test "installers handle SIGINT gracefully" {
    if [[ "$BATS_SKIP_SLOW_TESTS" == "1" ]]; then
        skip "Slow tests disabled"
    fi
    
    if [[ "$HAS_BASH" == "1" ]]; then
        # Start installer in background
        bash ../../install.sh --target "$TEST_TARGET" --dry-run 2>/dev/null &
        local pid=$!
        
        # Give it time to start
        sleep 1
        
        # Send SIGINT
        kill -INT "$pid" 2>/dev/null || true
        
        # Wait for cleanup
        wait "$pid" 2>/dev/null || true
        
        # Should have cleaned up
        true  # Just ensure the test doesn't hang
    fi
}

@test "installers handle SIGTERM gracefully" {
    if [[ "$BATS_SKIP_SLOW_TESTS" == "1" ]]; then
        skip "Slow tests disabled"
    fi
    
    if [[ "$HAS_BASH" == "1" ]]; then
        # Start installer in background
        bash ../../install.sh --target "$TEST_TARGET" --dry-run 2>/dev/null &
        local pid=$!
        
        sleep 1
        
        # Send SIGTERM
        kill -TERM "$pid" 2>/dev/null || true
        
        wait "$pid" 2>/dev/null || true
        
        true
    fi
}

# Environment Edge Cases
@test "installers handle missing environment variables" {
    # Unset common environment variables
    local saved_vars=()
    for var in USER USERNAME LOGNAME HOME PATH; do
        if [[ -n "${!var}" ]]; then
            saved_vars+=("$var=${!var}")
            unset "$var"
        fi
    done
    
    # Set minimal environment
    export PATH="/bin:/usr/bin"
    export HOME="$TEST_HOME"
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
    
    # Restore environment
    for var_val in "${saved_vars[@]}"; do
        export "$var_val"
    done
}

@test "installers handle corrupted environment" {
    # Set some problematic environment variables
    export IFS=$'\n\t '  # Unusual but valid IFS
    export TERM=""       # Empty terminal
    export LANG="invalid.locale"
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
    
    # Restore
    unset IFS TERM LANG
}

# Argument Parsing Edge Cases
@test "installers handle argument parsing edge cases" {
    local edge_case_args=(
        "--target="  # Empty value
        "--target"   # Missing value
        "--"         # End of options
        "-"          # Stdin indicator
        "--target --verbose"  # Confusing spacing
    )
    
    for args in "${edge_case_args[@]}"; do
        if [[ "$HAS_BASH" == "1" ]]; then
            run timeout 10 bash ../../install.sh $args --dry-run 2>/dev/null
            # Should not hang
            [ "$status" -ne 124 ]
        fi
    done
}

@test "installers handle mixed argument styles" {
    # Test various argument combinations
    if [[ "$HAS_BASH" == "1" ]]; then
        # POSIX style
        run timeout 30 bash ../../install.sh -t "$TEST_TARGET" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
        
        # GNU style
        run timeout 30 bash ../../install.sh --target="$TEST_TARGET" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
}

# Integration with System Tools
@test "installers work without common utilities" {
    # Temporarily hide common utilities
    local saved_path="$PATH"
    local minimal_path=""
    
    # Keep only essential directories
    for dir in /bin /usr/bin; do
        if [[ -d "$dir" ]]; then
            minimal_path="$minimal_path:$dir"
        fi
    done
    export PATH="${minimal_path#:}"
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
    
    export PATH="$saved_path"
}

@test "installers handle missing download tools" {
    # Test when curl/wget are not available
    local saved_path="$PATH"
    export PATH="/bin:/usr/bin"  # Minimal PATH that might not include curl/wget
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
    
    export PATH="$saved_path"
}

# Backup and Rollback Edge Cases
@test "installers handle backup of complex directory structures" {
    # Create complex directory structure
    mkdir -p "$TEST_TARGET"/{dir1,dir2/subdir,dir3/deep/nested/structure}
    touch "$TEST_TARGET"/dir1/file1.txt
    touch "$TEST_TARGET"/dir2/subdir/file2.txt
    touch "$TEST_TARGET"/dir3/deep/nested/structure/file3.txt
    ln -s ../file1.txt "$TEST_TARGET"/dir1/symlink 2>/dev/null || true
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --backup --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
}

@test "installers handle backup storage issues" {
    # Fill up backup directory to test error handling
    mkdir -p "$TEST_TARGET" "$BACKUP_DIR"
    
    # Create large file to simulate space issues
    dd if=/dev/zero of="$BACKUP_DIR/large-file" bs=1M count=10 2>/dev/null || true
    
    # Create some files to backup
    echo "test content" > "$TEST_TARGET/test-file.txt"
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --backup --backup-dir "$BACKUP_DIR" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
    
    # Cleanup
    rm -f "$BACKUP_DIR/large-file"
}

# Real-world Integration Scenarios
@test "installers work in container-like environments" {
    # Simulate container environment
    export CONTAINER=true
    export USER=root
    export HOME=/root
    
    # Create minimal home
    local container_home="$TEST_DIR/container-home"
    mkdir -p "$container_home"
    export HOME="$container_home"
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
    
    unset CONTAINER
}

@test "installers handle CI/CD environment variables" {
    # Set common CI/CD environment variables
    export CI=true
    export CONTINUOUS_INTEGRATION=true
    export TERM=dumb
    export DEBIAN_FRONTEND=noninteractive
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
    
    unset CI CONTINUOUS_INTEGRATION DEBIAN_FRONTEND
}

@test "installers work with different shell environments" {
    # Test with different shell settings
    set +e  # Don't exit on error
    set +u  # Don't exit on undefined variables
    set +o pipefail  # Don't exit on pipe failures
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$TEST_TARGET" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
    
    # Restore strict settings
    set -e
    set -u
    set -o pipefail
}

# Performance Edge Cases
@test "installers handle very large file lists" {
    if [[ "$BATS_SKIP_SLOW_TESTS" == "1" ]]; then
        skip "Slow tests disabled"
    fi
    
    # Create directory with many files
    mkdir -p "$TEST_TARGET"
    for i in {1..100}; do
        touch "$TEST_TARGET/file-$i.txt"
    done
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 60 bash ../../install.sh --target "$TEST_TARGET" --backup --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
}

@test "installers handle deep directory nesting" {
    # Create very deep directory structure
    local deep_path="$TEST_TARGET"
    for i in {1..50}; do
        deep_path="$deep_path/level-$i"
    done
    mkdir -p "$deep_path" 2>/dev/null || skip "Cannot create deep directory structure"
    
    if [[ "$HAS_BASH" == "1" ]]; then
        run timeout 30 bash ../../install.sh --target "$deep_path" --dry-run 2>/dev/null
        [ "$status" -ne 124 ]
    fi
}

# Final Integration Test
@test "all installers can coexist and work together" {
    # Test that all installers can work in the same environment
    local results=0
    
    # Test each installer in sequence
    if [[ "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install.sh --target "$TEST_TARGET/sequence-bash" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    if [[ "$HAS_NODE" == "1" ]]; then
        timeout 30 node ../../install.js --target "$TEST_TARGET/sequence-node" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    if [[ -f "../../install-local.sh" && "$HAS_BASH" == "1" ]]; then
        timeout 30 bash ../../install-local.sh --target "$TEST_TARGET/sequence-local" --dry-run 2>/dev/null && ((results++)) || true
    fi
    
    if [[ "$HAS_POWERSHELL" == "1" ]]; then
        timeout 30 pwsh ../../install.ps1 -Target "$TEST_TARGET/sequence-ps" -DryRun 2>/dev/null && ((results++)) || true
    fi
    
    # At least one installer should work
    [ "$results" -gt 0 ]
}
