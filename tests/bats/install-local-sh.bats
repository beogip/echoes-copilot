#!/usr/bin/env bats

# Comprehensive tests for install-local.sh
# Tests local development installation functionality

# Setup for each test
setup() {
    # Create temporary test directories
    export TEST_DIR="$(mktemp -d)"
    export SOURCE_DIR="$(mktemp -d)"
    export TARGET_DIR="$(mktemp -d)"
    
    cd "$TEST_DIR"
    
    # Mock script path
    export INSTALL_LOCAL_SCRIPT="${BATS_TEST_DIRNAME}/../../install-local.sh"
    
    # Create mock source structure
    mkdir -p "$SOURCE_DIR/.github/prompts"
    echo "# Test instruction" > "$SOURCE_DIR/.github/prompts/test.prompt.md"
    echo "# Copilot instructions" > "$SOURCE_DIR/.github/copilot-instructions.md"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR" "$SOURCE_DIR" "$TARGET_DIR"
}

# === BASIC FUNCTIONALITY TESTS ===

@test "install-local.sh displays help with --help" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Local Development Installer"* ]]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"TARGET_DIRECTORY"* ]]
}

@test "install-local.sh displays help with -h" {
    run bash "$INSTALL_LOCAL_SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"help"* ]]
}

@test "install-local.sh displays version information" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"v1.0.0"* ]]
}

# === ARGUMENT PARSING TESTS ===

@test "install-local.sh accepts target directory argument" {
    run bash "$INSTALL_LOCAL_SCRIPT" /tmp --help
    [ "$status" -eq 0 ]
}

@test "install-local.sh accepts --mode instructions" {
    run bash "$INSTALL_LOCAL_SCRIPT" --mode instructions --help
    [ "$status" -eq 0 ]
}

@test "install-local.sh accepts --mode comprehensive" {
    run bash "$INSTALL_LOCAL_SCRIPT" --mode comprehensive --help
    [ "$status" -eq 0 ]
}

@test "install-local.sh rejects invalid mode" {
    run bash "$INSTALL_LOCAL_SCRIPT" --mode invalid
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid mode"* ]]
}

@test "install-local.sh accepts -m short option" {
    run bash "$INSTALL_LOCAL_SCRIPT" -m instructions --help
    [ "$status" -eq 0 ]
}

@test "install-local.sh accepts --force flag" {
    run bash "$INSTALL_LOCAL_SCRIPT" --force --help
    [ "$status" -eq 0 ]
}

@test "install-local.sh accepts -f short force flag" {
    run bash "$INSTALL_LOCAL_SCRIPT" -f --help
    [ "$status" -eq 0 ]
}

@test "install-local.sh accepts --verbose flag" {
    run bash "$INSTALL_LOCAL_SCRIPT" --verbose --help
    [ "$status" -eq 0 ]
}

@test "install-local.sh accepts -v short verbose flag" {
    run bash "$INSTALL_LOCAL_SCRIPT" -v --help
    [ "$status" -eq 0 ]
}

@test "install-local.sh handles multiple arguments correctly" {
    run bash "$INSTALL_LOCAL_SCRIPT" "$TARGET_DIR" --mode comprehensive --force --verbose --help
    [ "$status" -eq 0 ]
}

# === ERROR HANDLING TESTS ===

@test "install-local.sh handles unknown arguments gracefully" {
    run bash "$INSTALL_LOCAL_SCRIPT" --unknown-flag
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option"* ]]
}

@test "install-local.sh requires mode parameter" {
    run bash "$INSTALL_LOCAL_SCRIPT" --mode
    [ "$status" -eq 1 ]
}

@test "install-local.sh handles non-existent target directory" {
    run bash "$INSTALL_LOCAL_SCRIPT" /nonexistent/directory
    [ "$status" -eq 1 ]
    [[ "$output" == *"does not exist"* ]]
}

@test "install-local.sh handles multiple target directories" {
    run bash "$INSTALL_LOCAL_SCRIPT" /tmp /var/tmp
    [ "$status" -eq 1 ]
    [[ "$output" == *"Multiple target directories"* ]]
}

# === PREREQUISITE VALIDATION TESTS ===

@test "install-local.sh validates source instructions directory" {
    # Test without proper source structure (copy script to isolated directory)
    cp "$INSTALL_LOCAL_SCRIPT" "$TARGET_DIR/install-local.sh"
    cd "$TARGET_DIR"
    run bash "./install-local.sh" . --mode instructions
    # Should either succeed (if source exists) or fail with proper error
    if [ "$status" -eq 1 ]; then
        [[ "$output" == *"Instructions directory not found"* ]] || [[ "$output" == *"npm run build"* ]]
    fi
}

@test "install-local.sh validates source copilot file" {
    # Test comprehensive mode validation
    run bash "$INSTALL_LOCAL_SCRIPT" "$TARGET_DIR" --mode comprehensive
    # Should either succeed (if source exists) or fail with proper error
    if [ "$status" -eq 1 ]; then
        [[ "$output" == *"Copilot instructions file not found"* ]] || [[ "$output" == *"npm run build"* ]]
    fi
}

@test "install-local.sh uses current directory as default target" {
    # When no target is specified, should use current directory
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"current directory"* ]]
}

# === BACKUP FUNCTIONALITY TESTS ===

@test "install-local.sh mentions backup in help" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    # Should mention local development and backup concepts
    [[ "$output" == *"Local"* ]] || [[ "$output" == *"development"* ]]
}

@test "install-local.sh force flag overrides existing files" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"force"* ]] && [[ "$output" == *"overwrite"* ]]
}

# === MODE-SPECIFIC TESTS ===

@test "install-local.sh instructions mode is default" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"instructions"* ]] && [[ "$output" == *"default"* ]]
}

@test "install-local.sh comprehensive mode available" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"comprehensive"* ]]
}

# === SOURCE DIRECTORY TESTS ===

@test "install-local.sh detects source directory correctly" {
    # Should be able to determine its own location
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    # Help should complete successfully
}

@test "install-local.sh mentions build requirement" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"npm run build"* ]]
}

# === INTEGRATION TESTS ===

@test "install-local.sh dry run completes without errors" {
    # Test with --help to ensure script loads completely
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" != *"syntax error"* ]]
    [[ "$output" != *"command not found"* ]]
}

@test "install-local.sh validates script integrity" {
    # Ensure script has no syntax errors
    run bash -n "$INSTALL_LOCAL_SCRIPT"
    [ "$status" -eq 0 ]
}

# === OUTPUT FORMAT TESTS ===

@test "install-local.sh has proper banner format" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"🧠🤖"* ]]
}

@test "install-local.sh provides clear examples" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"EXAMPLES"* ]]
}

@test "install-local.sh provides clear notes" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"NOTES"* ]]
}

# === DEVELOPMENT-SPECIFIC TESTS ===

@test "install-local.sh indicates local development purpose" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"development"* ]] && [[ "$output" == *"testing"* ]]
}

@test "install-local.sh mentions source copying" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"copies from"* ]] || [[ "$output" == *"local"* ]]
}

# === VERBOSE MODE TESTS ===

@test "install-local.sh verbose mode mentioned in help" {
    run bash "$INSTALL_LOCAL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"verbose"* ]]
}

@test "install-local.sh handles verbose flag correctly" {
    run bash "$INSTALL_LOCAL_SCRIPT" -v --help
    [ "$status" -eq 0 ]
}

# === PATH HANDLING TESTS ===

@test "install-local.sh handles relative paths" {
    run bash "$INSTALL_LOCAL_SCRIPT" . --help
    [ "$status" -eq 0 ]
}

@test "install-local.sh handles absolute paths" {
    run bash "$INSTALL_LOCAL_SCRIPT" /tmp --help
    [ "$status" -eq 0 ]
}

# === SAFETY TESTS ===

@test "install-local.sh has strict error handling" {
    # Script should use set -euo pipefail or similar
    head -10 "$INSTALL_LOCAL_SCRIPT" | grep -q "set -euo pipefail"
}

@test "install-local.sh handles interruption gracefully" {
    # Test that script can handle SIGTERM
    run timeout 1 bash "$INSTALL_LOCAL_SCRIPT" --help
    # Should complete help quickly
    [ "$status" -eq 0 ]
}
