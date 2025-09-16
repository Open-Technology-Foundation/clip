#!/usr/bin/env bash
# Simple test to verify test framework works
#
set -euo pipefail

# Load test library
source "$(dirname "${BASH_SOURCE[0]}")/test_lib.sh"

echo "Running simple test..."
echo "CLIP_CMD=$CLIP_CMD"
echo "Test directories:"
echo "  FIXTURES_DIR=$FIXTURES_DIR"
echo "  OUTPUT_DIR=$OUTPUT_DIR"
echo "  TMP_DIR=$TMP_DIR"

# Run basic tests that don't require xclip
assert_success "Clip script exists" test -f "$CLIP_CMD"
assert_success "Clip script is executable" test -x "$CLIP_CMD"
assert_success "Fixtures directory exists" test -d "$FIXTURES_DIR"
assert_success "Test images exist" test -f "$FIXTURES_DIR/shen2.jpg"

# Test help output
output=$("$CLIP_CMD" -h 2>&1 || true)
assert_output "Help displays usage" "Terminal clipboard utility" "$output"

# Print summary
print_summary

#fin