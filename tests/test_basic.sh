#!/usr/bin/env bash
# Basic functionality tests for clip utility
#
set -euo pipefail

run_test_group "Basic Functionality Tests"

# Test: Help option
output=$("$CLIP_CMD" -h 2>&1 || true)
assert_output "Help option (-h) displays usage" "Terminal clipboard utility" "$output"
assert_output "Help contains usage examples" "Examples:" "$output"

# Test: Version option
output=$("$CLIP_CMD" -V 2>&1 || true)
assert_output "Version option (-V) displays version" "clip 0.8" "$output"

# Test: Invalid option handling
assert_failure "Invalid option returns error" "$CLIP_CMD" --invalid-option

# Test: Quiet mode
output=$("$CLIP_CMD" -q -V 2>&1 || true)
assert_equal "Quiet mode suppresses verbose output" "clip 0.8.5" "$output"

# Test: Combined short options
output=$("$CLIP_CMD" -vV 2>&1 || true)
assert_output "Combined short options work (-vV)" "clip 0.8" "$output"

# Test: File not found error
if check_xclip; then
  output=$("$CLIP_CMD" /nonexistent/file.txt 2>&1 || true)
  assert_output "Missing file shows error" "not found" "$output"
else
  skip_test "File not found error" "xclip not available"
fi

# Test: Check for GUI environment variable detection
old_display="${DISPLAY:-}"
old_wayland="${WAYLAND_DISPLAY:-}"
unset DISPLAY WAYLAND_DISPLAY 2>/dev/null || true

output=$("$CLIP_CMD" -h 2>&1 || true)
# The help should still work even without display
assert_output "Help works without display" "Terminal clipboard utility" "$output"

# Restore display variables
if [[ -n "${old_display:-}" ]]; then
  export DISPLAY="$old_display"
fi
if [[ -n "${old_wayland:-}" ]]; then
  export WAYLAND_DISPLAY="$old_wayland"
fi

#fin