# Installation Scripts Test Suite

Comprehensive [Bats](https://github.com/bats-core/bats-core) test suite for all Echo Protocol installation scripts.

## Overview

This test suite provides thorough testing coverage for all installation scripts in the Echo Protocol project:

- `install.sh` - Main shell-based installer
- `install-local.sh` - Local development installer
- `install.js` - Node.js cross-platform installer
- `install.ps1` - PowerShell installer for Windows
- Cross-platform compatibility testing
- Edge cases and integration scenarios

## Test Files

### Core Installation Tests

| Test File               | Description                  | Test Count |
| ----------------------- | ---------------------------- | ---------- |
| `install-sh.bats`       | Tests for `install.sh`       | 60+ tests  |
| `install-local-sh.bats` | Tests for `install-local.sh` | 50+ tests  |
| `install-js.bats`       | Tests for `install.js`       | 50+ tests  |
| `install-ps1.bats`      | Tests for `install.ps1`      | 40+ tests  |

### Integration Tests

| Test File                     | Description                   | Test Count |
| ----------------------------- | ----------------------------- | ---------- |
| `install-cross-platform.bats` | Cross-platform compatibility  | 30+ tests  |
| `install-edge-cases.bats`     | Edge cases and stress testing | 40+ tests  |

## Prerequisites

### Required

- **Bats** - Testing framework

  ```bash
  # Install via npm
  npm install -g bats

  # Install via Homebrew (macOS)
  brew install bats-core

  # Install via package manager (Linux)
  sudo apt-get install bats  # Ubuntu/Debian
  sudo yum install bats      # RHEL/CentOS
  ```

- **Bash** - For shell script testing
  ```bash
  bash --version  # Should be 4.0+
  ```

### Optional (for complete testing)

- **Node.js** - For `install.js` testing

  ```bash
  node --version  # Any recent version
  ```

- **PowerShell** - For `install.ps1` testing

  ```bash
  # Install PowerShell Core
  # https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell
  pwsh --version
  ```

- **Network tools** - For download testing
  ```bash
  # At least one of:
  curl --version
  wget --version
  ```

## Quick Start

### Run All Tests

```bash
# From the project root
./tests/bats/run-tests.sh

# Or from the tests directory
cd tests/bats
./run-tests.sh
```

### Run Specific Test Suite

```bash
# Test only the main installer
./run-tests.sh install-sh

# Test Node.js installer
./run-tests.sh install-js

# Test cross-platform compatibility
./run-tests.sh install-cross-platform
```

### Enable Additional Tests

```bash
# Enable network tests (slow, requires internet)
BATS_SKIP_NETWORK_TESTS=0 ./run-tests.sh

# Enable slow tests (resource intensive)
BATS_SKIP_SLOW_TESTS=0 ./run-tests.sh

# Enable both
./run-tests.sh --enable-network --enable-slow
```

## Test Categories

### 1. Basic Functionality Tests

- Help and usage display
- Argument parsing and validation
- Basic installation flow
- Error handling
- Exit codes

### 2. Installation Mode Tests

- Instructions mode
- Comprehensive mode
- Dry-run mode
- Force installation
- Quiet/verbose modes

### 3. File System Tests

- Directory creation
- File permissions
- Backup creation
- Path handling (spaces, special characters)
- Symlink handling

### 4. Network Tests (Optional)

- URL validation
- Download functionality
- Network timeout handling
- Fallback mechanisms
- Security validation

### 5. Cross-Platform Tests

- Platform detection
- Path separator handling
- Permission models
- Shell compatibility
- Command availability

### 6. Edge Cases

- Resource exhaustion
- Permission denied scenarios
- Malformed input
- Signal handling
- Environment corruption

### 7. Integration Tests

- Multiple installer interaction
- Backup/restore workflows
- Validation processes
- Real-world scenarios

## Test Configuration

### Environment Variables

| Variable                  | Default | Description                          |
| ------------------------- | ------- | ------------------------------------ |
| `BATS_SKIP_NETWORK_TESTS` | `1`     | Skip tests requiring internet access |
| `BATS_SKIP_SLOW_TESTS`    | `1`     | Skip resource-intensive tests        |

### Test Options

```bash
# Show available tests
./run-tests.sh --list

# Verbose output
./run-tests.sh --verbose

# Quiet output
./run-tests.sh --quiet

# Show help
./run-tests.sh --help
```

## Test Structure

Each test file follows this structure:

```bash
#!/usr/bin/env bats

# Test setup and cleanup
setup() {
    # Create isolated test environment
    export TEST_DIR="/tmp/bats-test-$$"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
}

teardown() {
    # Clean up test environment
    rm -rf "$TEST_DIR"
}

# Individual tests
@test "description of test" {
    run command_to_test
    [ "$status" -eq 0 ]
    [[ "$output" =~ expected_pattern ]]
}
```

## Safety Features

### Test Isolation

- Each test runs in isolated temporary directories
- Original system state is preserved
- Automatic cleanup after each test

### Non-Destructive

- All tests use `--dry-run` mode by default
- No permanent system modifications
- Safe to run on development machines

### Resource Protection

- Timeouts prevent hanging tests
- Memory and disk usage limits
- Network test rate limiting

## Continuous Integration

The test suite is designed for CI/CD environments:

```yaml
# Example GitHub Actions
- name: Install Bats
  run: npm install -g bats

- name: Run Installation Tests
  run: ./tests/bats/run-tests.sh
  env:
    BATS_SKIP_NETWORK_TESTS: 1
    BATS_SKIP_SLOW_TESTS: 1
```

## Troubleshooting

### Common Issues

**Test timeouts**

```bash
# Increase timeout or skip slow tests
BATS_SKIP_SLOW_TESTS=1 ./run-tests.sh
```

**Permission errors**

```bash
# Run in isolated environment (tests already do this)
# Check that /tmp is writable
ls -la /tmp
```

**Missing dependencies**

```bash
# Check prerequisites
./run-tests.sh --help
```

**Network test failures**

```bash
# Disable network tests
BATS_SKIP_NETWORK_TESTS=1 ./run-tests.sh
```

### Debug Mode

```bash
# Enable debug output
BATS_DEBUG=1 ./run-tests.sh

# Run single test with verbose output
bats --verbose tests/bats/install-sh.bats
```

## Test Results

### Success Example

```
✓ All installers create compatible directory structures
✓ installers handle same target directory consistently
✓ all installers handle Unix-style paths
✓ all installers handle paths with spaces

Test Suite Summary
Total test files: 6
Passed: 6
Failed: 0
Total duration: 45s
```

### Failure Example

```
✗ installer handles network timeouts gracefully
  Expected status 0, got 1
  Output: Connection timeout after 10 seconds

Test Suite Summary
Total test files: 6
Passed: 5
Failed: 1
Check the log file for details: test-results-20231201-143022.log
```

## Contributing Tests

### Adding New Tests

1. **Identify test category** - Basic, integration, edge case
2. **Choose appropriate file** - Or create new one for new functionality
3. **Follow naming convention** - Descriptive test names
4. **Include proper setup/teardown** - Isolated test environment
5. **Add timeouts** - Prevent hanging tests
6. **Test both success and failure** - Comprehensive coverage

### Test Guidelines

- **Descriptive names**: `@test "installer handles spaces in target path"`
- **Isolated execution**: Each test should be independent
- **Proper assertions**: Use appropriate Bats assertions
- **Error handling**: Test both success and failure cases
- **Documentation**: Comment complex test logic
- **Performance**: Keep tests reasonably fast

### Example New Test

```bash
@test "installer validates configuration files" {
    # Setup test configuration
    echo "invalid_config=true" > "$TEST_DIR/config.txt"

    # Run installer with invalid config
    run timeout 30 bash ../../install.sh --config "$TEST_DIR/config.txt" --dry-run

    # Should fail with validation error
    [ "$status" -ne 0 ]
    [[ "$output" =~ "configuration.*invalid" ]]
}
```

## Test Coverage

The test suite aims for comprehensive coverage:

- **Functionality**: All features and options
- **Error conditions**: All error paths
- **Edge cases**: Boundary and unusual conditions
- **Integration**: Component interaction
- **Performance**: Resource usage and timeouts
- **Security**: Input validation and safe handling

## Reporting Issues

When reporting test failures:

1. **Include environment details**

   - OS and version
   - Shell version
   - Node.js version (if applicable)
   - PowerShell version (if applicable)

2. **Provide test output**

   - Full test output
   - Log file contents
   - Error messages

3. **Describe expected behavior**
   - What should happen
   - What actually happened
   - Steps to reproduce

## License

This test suite is part of the Echo Protocol project and follows the same license terms.
