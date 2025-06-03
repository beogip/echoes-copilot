# filepath: /Users/beogip/Github/echos-copilot/tests/bats/cleanup.bats
#!/usr/bin/env bats

# File: tests/bats/cleanup.bats

setup() {
  TEST_DIR="$(dirname "$BATS_TEST_FILENAME")/.."
  CLEANUP_SH="$TEST_DIR/cleanup.sh"
}

@test "cleanup.sh runs in dry-run mode and outputs expected text" {
  run bash "$CLEANUP_SH" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN]"* ]]
  [[ "$output" == *"No files deleted."* ]]
}
