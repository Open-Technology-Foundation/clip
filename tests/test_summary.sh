#!/usr/bin/env bash
# Quick test summary for clip utility
#
set -euo pipefail

echo "============================================"
echo " Clip Test Suite - Quick Summary"
echo "============================================"
echo

# Run each test category with timeout
run_category() {
  local category="$1"
  local name="$2"
  echo -n "$name: "

  if timeout 5 ./run_tests.sh "$category" 2>&1 | grep -q "✓ All tests passed"; then
    echo "✓ PASSED"
  else
    local results=$(timeout 5 ./run_tests.sh "$category" 2>&1 | grep -E "^(Passed|Failed|Skipped):" | tail -3)
    echo "⚠ Issues"
    echo "$results" | sed 's/^/  /'
  fi
}

run_category "-b" "Basic Tests     "
run_category "-t" "Text Tests      "
run_category "-e" "Error Tests     "

echo
echo "Note: Image and Compression tests may hang due to xclip clipboard operations"
echo "      These require manual verification"

#fin