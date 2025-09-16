#!/usr/bin/env bash
# Text copy/paste tests for clip utility
#
set -euo pipefail

run_test_group "Text Copy/Paste Tests"

if ! check_xclip; then
  skip_test "Text copy/paste tests" "xclip not available"
  return 0
fi

setup_test

# Test: Copy single file to clipboard
test_file=$(create_test_file "test1.txt" "Hello, World!")
if assert_success "Copy single file to clipboard" "$CLIP_CMD" "$test_file"; then
  # Try to paste and verify
  output=$("$CLIP_CMD" -p 2>/dev/null || true)
  assert_equal "Clipboard contains file content" "Hello, World!" "$output"
fi

# Test: Copy multiple files to clipboard
test_file1=$(create_test_file "test2.txt" "First file content")
test_file2=$(create_test_file "test3.txt" "Second file content")
if assert_success "Copy multiple files to clipboard" "$CLIP_CMD" "$test_file1" "$test_file2"; then
  output=$("$CLIP_CMD" -p 2>/dev/null || true)
  assert_output "Clipboard contains first file" "First file content" "$output"
  assert_output "Clipboard contains second file" "Second file content" "$output"
fi

# Test: Paste to file
test_file=$(create_test_file "source.txt" "Content to paste")
"$CLIP_CMD" "$test_file" 2>/dev/null
output_file="$OUTPUT_DIR/pasted.txt"
if assert_success "Paste clipboard to file" "$CLIP_CMD" -p "$output_file"; then
  assert_file_exists "Pasted file exists" "$output_file"
  assert_file_contains "Pasted file has correct content" "$output_file" "Content to paste"
fi

# Test: Copy with file headers
test_file=$(create_test_file "header_test.txt" "Test content")
if assert_success "Copy with file headers" "$CLIP_CMD" -f "$test_file"; then
  output=$("$CLIP_CMD" -p 2>/dev/null || true)
  assert_output "Output contains markdown header" '```text' "$output"
  assert_output "Output contains content" "Test content" "$output"
  assert_output "Output contains markdown footer" '```' "$output"
fi

# Test: Custom headers and footers
test_file=$(create_test_file "custom_header.txt" "Custom content")
if assert_success "Copy with custom headers" "$CLIP_CMD" -f -H '=== {} ===' -F '=== END ===' "$test_file"; then
  output=$("$CLIP_CMD" -p 2>/dev/null || true)
  assert_output "Output has custom header" "=== $test_file ===" "$output"
  assert_output "Output has custom footer" "=== END ===" "$output"
fi

# Test: Empty file handling
empty_file=$(create_test_file "empty.txt" "")
if assert_success "Copy empty file" "$CLIP_CMD" "$empty_file"; then
  output=$("$CLIP_CMD" -p 2>/dev/null || true)
  # Output should be empty or just newline
  [[ -z "$output" ]] || [[ "$output" == $'\n' ]] || fail "Empty file produces unexpected output"
fi

# Test: Large file handling
large_content=$(printf '%s\n' {1..1000} | head -c 10000)
large_file=$(create_test_file "large.txt" "$large_content")
if assert_success "Copy large file" "$CLIP_CMD" "$large_file"; then
  output=$("$CLIP_CMD" -p 2>/dev/null || true)
  # Check that at least some content is there
  assert_output "Large file content copied" "1" "$output"
fi

# Test: Special characters in content
special_content=$'Special chars: !@#$%^&*()_+{}[]|\\:";\'<>,.?/~`\nTabs:\t\tand\nnewlines'
special_file=$(create_test_file "special.txt" "$special_content")
if assert_success "Copy file with special characters" "$CLIP_CMD" "$special_file"; then
  output=$("$CLIP_CMD" -p 2>/dev/null || true)
  assert_output "Special characters preserved" '!@#$%^&*()' "$output"
  # Note: Some special chars might be escaped or modified by clipboard
fi

# Test: Quiet mode
test_file=$(create_test_file "quiet_test.txt" "Quiet mode test")
output=$("$CLIP_CMD" -q "$test_file" 2>&1 || true)
assert_equal "Quiet mode produces no output" "" "$output"

# Test: Verbose mode
test_file=$(create_test_file "verbose_test.txt" "Verbose mode test")
output=$("$CLIP_CMD" -v "$test_file" 2>&1 || true)
assert_output "Verbose mode shows status" "copied to clipboard" "$output"

cleanup_test

#fin