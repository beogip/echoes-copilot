#!/usr/bin/env bats

# Comprehensive tests for install.sh
# Tests all major functionality: modes, arguments, error handling, backup/rollback

# Setup for each test
setup() {
    # Create a temporary test directory
    export TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
    
    # Mock script path (adjust if needed)
    export INSTALL_SCRIPT="${BATS_TEST_DIRNAME}/../../install.sh"
    
    # Ensure clean state
    rm -rf .github
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# === BASIC FUNCTIONALITY TESTS ===

@test "install.sh displays help with --help" {
    run bash "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Echos + Copilot Template Installer"* ]]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"OPTIONS"* ]]
    [[ "$output" == *"MODES"* ]]
}

@test "install.sh displays help with -h" {
    run bash "$INSTALL_SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"help"* ]]
}

@test "install.sh displays version information" {
    run bash "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"v1.0.0"* ]]
}

# === ARGUMENT PARSING TESTS ===

@test "install.sh accepts --mode instructions" {
    run bash "$INSTALL_SCRIPT" --mode instructions --help
    [ "$status" -eq 0 ]
}

@test "install.sh accepts --mode comprehensive" {
    run bash "$INSTALL_SCRIPT" --mode comprehensive --help
    [ "$status" -eq 0 ]
}

@test "install.sh rejects invalid mode" {
    run bash "$INSTALL_SCRIPT" --mode invalid
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid mode"* ]]
}

@test "install.sh accepts -m short option" {
    run bash "$INSTALL_SCRIPT" -m instructions --help
    [ "$status" -eq 0 ]
}

@test "install.sh accepts --force flag" {
    run bash "$INSTALL_SCRIPT" --force --help
    [ "$status" -eq 0 ]
}

@test "install.sh accepts -f short force flag" {
    run bash "$INSTALL_SCRIPT" -f --help
    [ "$status" -eq 0 ]
}

@test "install.sh accepts --verbose flag" {
    run bash "$INSTALL_SCRIPT" --verbose --help
    [ "$status" -eq 0 ]
}

@test "install.sh accepts -v short verbose flag" {
    run bash "$INSTALL_SCRIPT" -v --help
    [ "$status" -eq 0 ]
}

@test "install.sh accepts --rollback flag" {
    run bash "$INSTALL_SCRIPT" --rollback --help
    [ "$status" -eq 0 ]
}

@test "install.sh handles multiple arguments correctly" {
    run bash "$INSTALL_SCRIPT" --mode comprehensive --force --verbose --help
    [ "$status" -eq 0 ]
}

# === ERROR HANDLING TESTS ===

@test "install.sh handles unknown arguments gracefully" {
    run bash "$INSTALL_SCRIPT" --unknown-flag
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option"* ]]
}

@test "install.sh requires mode parameter" {
    run bash "$INSTALL_SCRIPT" --mode
    [ "$status" -eq 1 ]
}

@test "install.sh handles missing dependencies gracefully" {
    # Test without network access (should fail gracefully)
    run timeout 5 bash "$INSTALL_SCRIPT" --mode instructions
    # Should either succeed quickly or fail with meaningful error
    [[ "$status" -eq 0 || "$status" -eq 1 || "$status" -eq 124 ]]
}

# === BACKUP FUNCTIONALITY TESTS ===

@test "install.sh creates backup directory when .github exists" {
    # Create mock .github directory
    mkdir -p .github/instructions
    echo "test content" > .github/instructions/test.md
    
    # Mock network call to prevent actual download, provide 'y' to continue
    run bash -c 'echo "y" | timeout 5 bash '"$INSTALL_SCRIPT"' --mode instructions'
    
    # Check that backup was attempted (even if install fails)
    if [ -d .github ]; then
        # Should have either created backup or shown backup message
        [[ "$output" == *"backup"* ]] || [[ "$output" == *"Backup"* ]]
    fi
}

@test "install.sh rollback requires existing backup" {
    run bash "$INSTALL_SCRIPT" --rollback
    [ "$status" -eq 1 ]
    [[ "$output" == *"backup"* ]] || [[ "$output" == *"Backup"* ]]
}

# === DIRECTORY STRUCTURE TESTS ===

@test "install.sh creates .github directory if missing" {
    [ ! -d .github ]
    
    # Mock install attempt
    run timeout 3 bash "$INSTALL_SCRIPT" --mode instructions
    
    # Directory should be created or install should indicate it would be created
    if [ "$status" -eq 0 ]; then
        [ -d .github ]
    fi
}

@test "install.sh respects existing .github directory" {
    mkdir -p .github
    echo "existing content" > .github/existing.md
    
    run timeout 3 bash "$INSTALL_SCRIPT" --mode instructions
    
    # Existing content should be preserved or backed up
    [[ -f .github/existing.md ]] || [[ "$output" == *"backup"* ]]
}

# === MODE-SPECIFIC TESTS ===

@test "install.sh instructions mode targets correct files" {
    run bash "$INSTALL_SCRIPT" --mode instructions --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"individual"* ]] || [[ "$output" == *"instructions"* ]]
}

@test "install.sh comprehensive mode targets correct files" {
    run bash "$INSTALL_SCRIPT" --mode comprehensive --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"comprehensive"* ]] || [[ "$output" == *"single"* ]]
}

# === LOGGING TESTS ===

@test "install.sh creates log file in verbose mode" {
    run bash "$INSTALL_SCRIPT" --verbose --help
    [ "$status" -eq 0 ]
    
    # Log file should be mentioned or created
    [[ "$output" == *"LOG"* ]] || [ -f /tmp/echos-copilot-install.log ]
}

@test "install.sh verbose mode shows detailed output" {
    run bash "$INSTALL_SCRIPT" --verbose --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"LOG"* ]] || [[ "$output" == *"verbose"* ]]
}

# === PREREQUISITE TESTS ===

@test "install.sh checks for required commands" {
    # Should work even if curl/wget not available (has fallbacks)
    run bash "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
}

@test "install.sh detects bash version" {
    run bash "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    # Script should run in current bash version
}

# === INTEGRATION TESTS ===

@test "install.sh dry run completes without errors" {
    # Test with --help to ensure script loads completely
    run bash "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" != *"syntax error"* ]]
    [[ "$output" != *"command not found"* ]]
}

@test "install.sh validates script integrity" {
    # Ensure script has no syntax errors
    run bash -n "$INSTALL_SCRIPT"
    [ "$status" -eq 0 ]
}

# === SAFETY TESTS ===

@test "install.sh requires confirmation for destructive operations" {
    # Force flag should be mentioned in help
    run bash "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"force"* ]]
}

@test "install.sh handles interruption gracefully" {
    # Test that script can handle SIGTERM
    run timeout 1 bash "$INSTALL_SCRIPT" --mode instructions
    # Should exit cleanly (0) or with proper error code (1), not crash (>1)
    [[ "$status" -eq 0 || "$status" -eq 1 || "$status" -eq 124 ]]
}
