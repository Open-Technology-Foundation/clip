#!/usr/bin/env bash
# Test library for clip utility tests
#
# Provides common test functions and utilities
#
set -euo pipefail

# Test configuration
TEST_VERSION='1.0.0'
# Get the directory of this test_lib.sh file
TEST_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paths
declare -- CLIP_CMD="${TEST_LIB_DIR}/../clip"
declare -- FIXTURES_DIR="${TEST_LIB_DIR}/fixtures"
declare -- OUTPUT_DIR="${TEST_LIB_DIR}/output"
declare -- TMP_DIR="${TEST_LIB_DIR}/tmp"
readonly -- CLIP_CMD FIXTURES_DIR OUTPUT_DIR TMP_DIR

# Test counters
declare -i TESTS_RUN=0 TESTS_PASSED=0 TESTS_FAILED=0 TESTS_SKIPPED=0

# Color support
[[ -t 2 ]] && declare -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m' || declare -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
readonly -- RED GREEN YELLOW CYAN NC

# Test framework functions
# --------------------------------------------------------------------------------

# Core message function
_msg() {
  local -- status="${FUNCNAME[1]}" prefix="TEST" msg
  case "$status" in
    pass)    prefix+="${GREEN} ✓${NC}" ;;
    fail)    prefix+="${RED} ✗${NC}" ;;
    skip)    prefix+="${YELLOW} ⊘${NC}" ;;
    info)    prefix+="${CYAN} ℹ${NC}" ;;
    error)   prefix+="${RED} ✗${NC}" ;;
    *)       prefix+=" •" ;;
  esac
  for msg in "$@"; do >&2 printf '%s %s\n' "$prefix" "$msg"; done
}

# Test outcome functions
pass() { _msg "$@"; }
fail() { _msg "$@"; }
skip() { _msg "$@"; }
info() { _msg "$@"; }
error() { _msg "$@"; }

# Test assertion functions
# --------------------------------------------------------------------------------

# Assert that a command succeeds
assert_success() {
  local -- description="$1"
  shift
  ((TESTS_RUN+=1))

  if "$@" &>/dev/null; then
    ((TESTS_PASSED+=1))
    pass "$description"
    return 0
  else
    ((TESTS_FAILED+=1))
    fail "$description"
    error "Command failed: $*"
    return 1
  fi
}

# Assert that a command fails
assert_failure() {
  local -- description="$1"
  shift
  ((TESTS_RUN+=1))

  if ! "$@" &>/dev/null; then
    ((TESTS_PASSED+=1))
    pass "$description"
    return 0
  else
    ((TESTS_FAILED+=1))
    fail "$description"
    error "Command succeeded unexpectedly: $*"
    return 1
  fi
}

# Assert that two strings are equal
assert_equal() {
  local -- description="$1" expected="$2" actual="$3"
  ((TESTS_RUN+=1))

  if [[ "$expected" == "$actual" ]]; then
    ((TESTS_PASSED+=1))
    pass "$description"
    return 0
  else
    ((TESTS_FAILED+=1))
    fail "$description"
    error "Expected: '$expected'"
    error "Actual:   '$actual'"
    return 1
  fi
}

# Assert that a file exists
assert_file_exists() {
  local -- description="$1" file="$2"
  ((TESTS_RUN+=1))

  if [[ -f "$file" ]]; then
    ((TESTS_PASSED+=1))
    pass "$description"
    return 0
  else
    ((TESTS_FAILED+=1))
    fail "$description"
    error "File does not exist: $file"
    return 1
  fi
}

# Assert that a file contains expected content
assert_file_contains() {
  local -- description="$1" file="$2" expected="$3"
  ((TESTS_RUN+=1))

  if [[ ! -f "$file" ]]; then
    ((TESTS_FAILED+=1))
    fail "$description"
    error "File does not exist: $file"
    return 1
  fi

  if grep -q "$expected" "$file"; then
    ((TESTS_PASSED+=1))
    pass "$description"
    return 0
  else
    ((TESTS_FAILED+=1))
    fail "$description"
    error "File '$file' does not contain: $expected"
    return 1
  fi
}

# Assert that output matches expected
assert_output() {
  local -- description="$1" expected="$2" actual="$3"
  ((TESTS_RUN+=1))

  if [[ "$actual" == *"$expected"* ]]; then
    ((TESTS_PASSED+=1))
    pass "$description"
    return 0
  else
    ((TESTS_FAILED+=1))
    fail "$description"
    error "Output does not contain expected text"
    error "Expected: '$expected'"
    error "Actual:   '$actual'"
    return 1
  fi
}

# Skip a test with reason
skip_test() {
  local -- description="$1" reason="${2:-No reason given}"
  ((TESTS_RUN+=1))
  ((TESTS_SKIPPED+=1))
  skip "$description - SKIPPED: $reason"
}

# Utility functions
# --------------------------------------------------------------------------------

# Setup test environment
setup_test() {
  # Clean and create temp directories
  rm -rf "${TMP_DIR:?}"/*
  rm -rf "${OUTPUT_DIR:?}"/*
  mkdir -p "$TMP_DIR" "$OUTPUT_DIR"
}

# Cleanup test environment
cleanup_test() {
  # Optional: Clean temp files after each test
  rm -rf "${TMP_DIR:?}"/* 2>/dev/null || true
}

# Create a test file with content
create_test_file() {
  local -- filename="$1" content="${2:-Test content}"
  echo "$content" > "$TMP_DIR/$filename"
  echo "$TMP_DIR/$filename"
}

# Check if xclip is available
check_xclip() {
  if ! command -v xclip &>/dev/null; then
    return 1
  fi
  # Check if we can actually use xclip (need X server)
  if [[ -z ${DISPLAY:-} ]] && [[ -z ${WAYLAND_DISPLAY:-} ]]; then
    return 1
  fi
  return 0
}

# Check if image tools are available
check_image_tools() {
  local -i has_tools=0
  command -v pngquant &>/dev/null && ((has_tools+=1))
  command -v optipng &>/dev/null && ((has_tools+=1))
  command -v convert &>/dev/null && ((has_tools+=1))
  ((has_tools > 0))
}

# Run a test group
run_test_group() {
  local -- group_name="$1"
  echo
  echo "=================================================================================="
  echo " $group_name"
  echo "=================================================================================="
}

# Print test summary
print_summary() {
  echo
  echo "=================================================================================="
  echo " Test Summary"
  echo "=================================================================================="
  echo
  printf "Total tests:  %3d\n" "$TESTS_RUN"
  printf "${GREEN}Passed:       %3d${NC}\n" "$TESTS_PASSED"
  printf "${RED}Failed:       %3d${NC}\n" "$TESTS_FAILED"
  printf "${YELLOW}Skipped:      %3d${NC}\n" "$TESTS_SKIPPED"
  echo

  if ((TESTS_FAILED == 0)); then
    echo "${GREEN}✓ All tests passed!${NC}"
    return 0
  else
    echo "${RED}✗ Some tests failed${NC}"
    return 1
  fi
}

# Export functions for use in test scripts
export -f assert_success assert_failure assert_equal assert_file_exists
export -f assert_file_contains assert_output skip_test
export -f setup_test cleanup_test create_test_file
export -f check_xclip check_image_tools
export -f run_test_group print_summary
export -f pass fail skip info error _msg

#fin