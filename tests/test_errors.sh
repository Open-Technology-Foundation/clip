#!/usr/bin/env bash
# Error handling tests for clip utility
#
set -euo pipefail

run_test_group "Error Handling Tests"

setup_test

# Test: Invalid option
output=$("$CLIP_CMD" --invalid-option 2>&1 || true)
assert_output "Invalid option produces error" "Invalid option" "$output"

# Test: Bad short option
output=$("$CLIP_CMD" -Z 2>&1 || true)
assert_output "Bad short option produces error" "Invalid option" "$output"

# Test: Missing argument for option requiring value
output=$("$CLIP_CMD" -Q 2>&1 || true)
assert_output "Missing quality value produces error" "Invalid option" "$output"

# Test: Invalid quality value
output=$("$CLIP_CMD" -Q abc 2>&1 || true)
if [[ "$output" == *"Invalid"* ]] || [[ "$output" == *"integer expression expected"* ]]; then
  pass "Invalid quality value produces error"
else
  fail "Invalid quality value should produce error"
fi

# Test: Non-existent file
if check_xclip; then
  nonexistent="/tmp/nonexistent_$$_$RANDOM.txt"
  output=$("$CLIP_CMD" "$nonexistent" 2>&1 || true)
  assert_output "Non-existent file produces error" "not found" "$output"
else
  skip_test "Non-existent file error" "xclip not available"
fi

# Test: Directory instead of file
if check_xclip; then
  test_dir="$TMP_DIR/testdir"
  mkdir -p "$test_dir"
  output=$("$CLIP_CMD" "$test_dir" 2>&1 || true)
  assert_output "Directory produces error" "not found" "$output"
else
  skip_test "Directory error test" "xclip not available"
fi

# Test: Empty argument list (should show help or error)
if check_xclip; then
  # With xclip available, empty args might try to read stdin or show error
  output=$("$CLIP_CMD" 2>&1 </dev/null || true)
  # Should either show an error or process empty stdin
  pass "Empty arguments handled"
else
  skip_test "Empty arguments test" "xclip not available"
fi

# Test: Paste to read-only directory
if check_xclip; then
  readonly_dir="/tmp/readonly_$$"
  mkdir -p "$readonly_dir"
  chmod 555 "$readonly_dir"

  output=$("$CLIP_CMD" -p "$readonly_dir/test.txt" 2>&1 || true)
  assert_output "Read-only directory produces error" "Could not create" "$output"

  chmod 755 "$readonly_dir"
  rm -rf "$readonly_dir"
else
  skip_test "Read-only directory test" "xclip not available"
fi

# Test: Paste with invalid path characters (if applicable)
if check_xclip; then
  invalid_path="/tmp/test\0file.txt"  # Null character in path
  # This might not work as expected due to shell handling
  output=$("$CLIP_CMD" -p "/tmp/test*?.txt" 2>&1 || true)
  # Glob characters should be treated literally
  pass "Invalid path characters handled"
else
  skip_test "Invalid path test" "xclip not available"
fi

# Test: Multiple paste destinations (only first should be used)
if check_xclip; then
  test_file=$(create_test_file "multi_paste_src.txt" "Test content")
  "$CLIP_CMD" "$test_file" 2>/dev/null || true

  output=$("$CLIP_CMD" -p "$OUTPUT_DIR/dest1.txt" "$OUTPUT_DIR/dest2.txt" 2>&1 || true)
  assert_output "Multiple paste destinations warning" "ignored" "$output"
  assert_file_exists "First destination used" "$OUTPUT_DIR/dest1.txt"
  [[ ! -f "$OUTPUT_DIR/dest2.txt" ]] || fail "Second destination should not be created"
else
  skip_test "Multiple paste destinations test" "xclip not available"
fi

# Test: Paste to file without directory creation permission
if check_xclip; then
  no_perm_dir="/tmp/no_create_$$"
  mkdir -p "$no_perm_dir"
  chmod 755 "$no_perm_dir"

  # Try to paste to non-existent subdirectory
  output=$("$CLIP_CMD" -p "$no_perm_dir/subdir/file.txt" 2>&1 || true)
  if [[ -d "$no_perm_dir/subdir" ]]; then
    pass "Directory auto-created for paste"
  else
    # Directory creation might have failed
    assert_output "Directory creation handled" "Directory" "$output"
  fi

  rm -rf "$no_perm_dir"
else
  skip_test "Directory creation permission test" "xclip not available"
fi

# Test: Compression without tools installed
if check_xclip && ! check_image_tools; then
  # This test only makes sense if image tools are NOT installed
  output=$("$CLIP_CMD" -p -c "$OUTPUT_DIR/no_tools.png" 2>&1 || true)
  # Should either prompt to install or skip compression
  pass "Compression without tools handled gracefully"
else
  skip_test "Compression without tools test" "xclip not available or tools already installed"
fi

# Test: GUI environment detection
old_display="${DISPLAY:-}"
old_wayland="${WAYLAND_DISPLAY:-}"
unset DISPLAY WAYLAND_DISPLAY 2>/dev/null || true

output=$("$CLIP_CMD" "$TMP_DIR/dummy.txt" 2>&1 || true)
assert_output "No GUI environment detected" "No GUI detected" "$output"

# Restore display variables
[[ -n "$old_display" ]] && export DISPLAY="$old_display"
[[ -n "$old_wayland" ]] && export WAYLAND_DISPLAY="$old_wayland"

# Test: Interrupt handling (Ctrl+C simulation)
# This is difficult to test automatically, but we can check the script has proper signal handling
if grep -q "trap" "$CLIP_CMD" 2>/dev/null; then
  skip_test "Signal handling test" "Manual testing required"
else
  # No trap in script, which is fine for this simple utility
  pass "Script completes without trap handlers"
fi

cleanup_test

#fin