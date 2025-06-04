# Test Infrastructure for Echos Copilot

This directory contains test scripts and documentation for the Echos Copilot project.

## JavaScript Tests (Jest)

- **Location:** `tests/*.test.js`
- **Run all JS tests:**
  ```sh
  npx jest
  ```
- **Configuration:** See `jest.config.js` at project root.

## Shell Script Tests (Bats)

- **Location:** `tests/bats/*.bats`
- **Run all Bats tests:**
  ```sh
  bats tests/bats/
  ```
- **Install Bats:**
  - macOS: `brew install bats-core`
  - Linux: See https://bats-core.readthedocs.io/en/stable/installation.html

## Cleanup Script

- **Script:** `tests/cleanup.sh`
- **Usage:**
  - Dry run (no files deleted):
    ```sh
    bash tests/cleanup.sh --dry-run
    ```
  - Interactive delete:
    ```sh
    bash tests/cleanup.sh
    ```

## Adding Tests

- Place new Jest tests in `tests/` with `.test.js` extension.
- Place new Bats tests in `tests/bats/` with `.bats` extension.

## CI Integration

- (Optional) Integrate both test suites in your CI pipeline for full coverage.
