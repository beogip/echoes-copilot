#!/bin/bash

# Comprehensive test runner for installation script Bats tests
# This script runs all installation-related Bats tests and provides detailed reporting

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TESTS_DIR="$SCRIPT_DIR"

# Test configuration
export BATS_SKIP_NETWORK_TESTS=${BATS_SKIP_NETWORK_TESTS:-1}
export BATS_SKIP_SLOW_TESTS=${BATS_SKIP_SLOW_TESTS:-1}

# Logging
LOG_FILE="$SCRIPT_DIR/test-results-$(date +%Y%m%d-%H%M%S).log"

# Print banner
print_banner() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                     Installation Scripts Test Suite                          ║${NC}"
    echo -e "${BLUE}║                  Comprehensive Bats Testing Framework                        ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Print section header
print_section() {
    local title="$1"
    echo -e "${CYAN}▶ $title${NC}"
    echo -e "${CYAN}$(printf '─%.0s' $(seq 1 ${#title}))${NC}"
}

# Print test result
print_result() {
    local status="$1"
    local message="$2"
    
    case "$status" in
        "PASS")
            echo -e "  ${GREEN}✓${NC} $message"
            ;;
        "FAIL")
            echo -e "  ${RED}✗${NC} $message"
            ;;
        "SKIP")
            echo -e "  ${YELLOW}⚠${NC} $message"
            ;;
        "INFO")
            echo -e "  ${BLUE}ℹ${NC} $message"
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"
    
    local all_good=true
    
    # Check if bats is available
    if command -v bats >/dev/null 2>&1; then
        local bats_version=$(bats --version 2>/dev/null | head -n1 || echo "unknown")
        print_result "PASS" "Bats is available ($bats_version)"
    else
        print_result "FAIL" "Bats is not installed"
        echo -e "  ${YELLOW}Install with: npm install -g bats || brew install bats-core${NC}"
        all_good=false
    fi
    
    # Check for shell interpreters
    if command -v bash >/dev/null 2>&1; then
        local bash_version=$(bash --version | head -n1 | cut -d' ' -f4 | cut -d'(' -f1)
        print_result "PASS" "Bash is available (v$bash_version)"
    else
        print_result "FAIL" "Bash is not available"
        all_good=false
    fi
    
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version)
        print_result "PASS" "Node.js is available ($node_version)"
    else
        print_result "SKIP" "Node.js is not available (install.js tests will be skipped)"
    fi
    
    if command -v pwsh >/dev/null 2>&1; then
        local ps_version=$(pwsh --version 2>/dev/null | head -n1 || echo "unknown")
        print_result "PASS" "PowerShell is available ($ps_version)"
    else
        print_result "SKIP" "PowerShell is not available (install.ps1 tests will be limited)"
    fi
    
    # Check for network tools
    if command -v curl >/dev/null 2>&1; then
        print_result "PASS" "curl is available"
    elif command -v wget >/dev/null 2>&1; then
        print_result "PASS" "wget is available"
    else
        print_result "SKIP" "No network download tools available"
    fi
    
    # Check for installation scripts
    for script in install.sh install-local.sh install.js install.ps1; do
        if [[ -f "$PROJECT_ROOT/$script" ]]; then
            print_result "PASS" "$script exists"
        else
            print_result "FAIL" "$script is missing"
            all_good=false
        fi
    done
    
    echo
    
    if [[ "$all_good" != "true" ]]; then
        echo -e "${RED}Some prerequisites are missing. Tests may fail or be skipped.${NC}"
        echo
    fi
    
    return 0  # Don't fail on missing optional components
}

# Show test configuration
show_configuration() {
    print_section "Test Configuration"
    
    print_result "INFO" "Project root: $PROJECT_ROOT"
    print_result "INFO" "Tests directory: $TESTS_DIR"
    print_result "INFO" "Log file: $LOG_FILE"
    
    if [[ "$BATS_SKIP_NETWORK_TESTS" == "1" ]]; then
        print_result "INFO" "Network tests: DISABLED (set BATS_SKIP_NETWORK_TESTS=0 to enable)"
    else
        print_result "INFO" "Network tests: ENABLED (may be slow)"
    fi
    
    if [[ "$BATS_SKIP_SLOW_TESTS" == "1" ]]; then
        print_result "INFO" "Slow tests: DISABLED (set BATS_SKIP_SLOW_TESTS=0 to enable)"
    else
        print_result "INFO" "Slow tests: ENABLED (may take a long time)"
    fi
    
    echo
}

# Run a single test file
run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .bats)
    
    echo -e "${PURPLE}Testing: $test_name${NC}"
    
    if [[ ! -f "$test_file" ]]; then
        print_result "SKIP" "$test_file not found"
        return 0
    fi
    
    # Run the test and capture output
    local start_time=$(date +%s)
    local exit_code=0
    
    # Create a temporary output file
    local temp_output=$(mktemp)
    
    # Run bats with detailed output
    if bats --tap "$test_file" > "$temp_output" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Parse TAP output for summary
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    local skipped_tests=0
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^1\.\.([0-9]+)$ ]]; then
            total_tests=${BASH_REMATCH[1]}
        elif [[ "$line" =~ ^ok\ [0-9]+\ (.*)$ ]]; then
            if [[ "$line" =~ \#\ SKIP ]]; then
                ((skipped_tests++))
            else
                ((passed_tests++))
            fi
        elif [[ "$line" =~ ^not\ ok\ [0-9]+\ (.*)$ ]]; then
            ((failed_tests++))
        fi
    done < "$temp_output"
    
    # Show summary
    if [[ $exit_code -eq 0 ]]; then
        print_result "PASS" "All tests passed ($passed_tests passed, $skipped_tests skipped) - ${duration}s"
    else
        print_result "FAIL" "Some tests failed ($passed_tests passed, $failed_tests failed, $skipped_tests skipped) - ${duration}s"
        
        # Show failed test details
        echo -e "  ${RED}Failed tests:${NC}"
        grep "^not ok" "$temp_output" | sed 's/^/    /' || true
    fi
    
    # Log full output
    echo "=== $test_name ===" >> "$LOG_FILE"
    cat "$temp_output" >> "$LOG_FILE"
    echo >> "$LOG_FILE"
    
    # Cleanup
    rm -f "$temp_output"
    
    echo
    return $exit_code
}

# Run all installation tests
run_all_tests() {
    print_section "Running Installation Script Tests"
    
    local total_files=0
    local passed_files=0
    local failed_files=0
    local overall_start_time=$(date +%s)
    
    # List of test files to run (in logical order)
    local test_files=(
        "install-sh.bats"
        "install-local-sh.bats"  
        "install-js.bats"
        "install-ps1.bats"
        "install-cross-platform.bats"
        "install-edge-cases.bats"
    )
    
    for test_file in "${test_files[@]}"; do
        local full_path="$TESTS_DIR/$test_file"
        ((total_files++))
        
        if run_test_file "$full_path"; then
            ((passed_files++))
        else
            ((failed_files++))
        fi
    done
    
    local overall_end_time=$(date +%s)
    local total_duration=$((overall_end_time - overall_start_time))
    
    # Overall summary
    print_section "Test Suite Summary"
    
    print_result "INFO" "Total test files: $total_files"
    print_result "INFO" "Passed: $passed_files"
    print_result "INFO" "Failed: $failed_files"
    print_result "INFO" "Total duration: ${total_duration}s"
    print_result "INFO" "Detailed log: $LOG_FILE"
    
    echo
    
    if [[ $failed_files -eq 0 ]]; then
        echo -e "${GREEN}🎉 All test files passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ $failed_files test file(s) failed.${NC}"
        echo -e "${YELLOW}Check the log file for details: $LOG_FILE${NC}"
        return 1
    fi
}

# Run individual test file if specified
run_individual_test() {
    local test_name="$1"
    local test_file="$TESTS_DIR/$test_name"
    
    if [[ ! "$test_name" =~ \.bats$ ]]; then
        test_file="$test_file.bats"
    fi
    
    print_section "Running Individual Test: $test_name"
    
    if run_test_file "$test_file"; then
        echo -e "${GREEN}✓ Test passed${NC}"
        return 0
    else
        echo -e "${RED}✗ Test failed${NC}"
        return 1
    fi
}

# Show available tests
show_available_tests() {
    print_section "Available Test Files"
    
    for test_file in "$TESTS_DIR"/*.bats; do
        if [[ -f "$test_file" ]]; then
            local test_name=$(basename "$test_file")
            local test_count=$(grep -c "^@test" "$test_file" 2>/dev/null || echo "0")
            print_result "INFO" "$test_name ($test_count tests)"
        fi
    done
    
    echo
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [TEST_NAME]"
    echo
    echo "Run comprehensive Bats tests for installation scripts."
    echo
    echo "Options:"
    echo "  -h, --help                 Show this help message"
    echo "  -l, --list                 List available test files"
    echo "  -a, --all                  Run all tests (default)"
    echo "  -n, --enable-network       Enable network tests (slow)"
    echo "  -s, --enable-slow          Enable slow tests"
    echo "  -v, --verbose              Verbose output"
    echo "  -q, --quiet                Quiet output"
    echo
    echo "Examples:"
    echo "  $0                         # Run all tests"
    echo "  $0 install-sh              # Run only install-sh.bats"
    echo "  $0 -n -s                   # Run all tests including network and slow tests"
    echo "  $0 --list                  # Show available test files"
    echo
    echo "Environment Variables:"
    echo "  BATS_SKIP_NETWORK_TESTS=0  Enable network tests"
    echo "  BATS_SKIP_SLOW_TESTS=0     Enable slow tests"
}

# Main execution
main() {
    local run_all=true
    local test_name=""
    local show_list=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -l|--list)
                show_list=true
                shift
                ;;
            -a|--all)
                run_all=true
                shift
                ;;
            -n|--enable-network)
                export BATS_SKIP_NETWORK_TESTS=0
                shift
                ;;
            -s|--enable-slow)
                export BATS_SKIP_SLOW_TESTS=0
                shift
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            -q|--quiet)
                exec >/dev/null 2>&1
                shift
                ;;
            -*)
                echo "Unknown option: $1" >&2
                show_usage >&2
                exit 1
                ;;
            *)
                test_name="$1"
                run_all=false
                shift
                ;;
        esac
    done
    
    # Initialize log file
    echo "Installation Scripts Test Run - $(date)" > "$LOG_FILE"
    echo "=======================================" >> "$LOG_FILE"
    echo >> "$LOG_FILE"
    
    print_banner
    
    if [[ "$show_list" == "true" ]]; then
        show_available_tests
        exit 0
    fi
    
    check_prerequisites
    show_configuration
    
    if [[ "$run_all" == "true" ]]; then
        run_all_tests
    else
        run_individual_test "$test_name"
    fi
}

# Run main function with all arguments
main "$@"
