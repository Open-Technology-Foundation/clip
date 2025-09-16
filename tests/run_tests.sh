#!/usr/bin/env bash
# Main test runner for clip utility
#
set -euo pipefail

# Script metadata
VERSION='1.0.0'
PRG0=$(readlink -en -- "$0")
PRG=${PRG0##*/}
PRGDIR=${PRG0%/*}
readonly -- VERSION PRG0 PRG PRGDIR

# Load test library
source "${PRGDIR}/test_lib.sh"

# Test flags
declare -i VERBOSE=1 RUN_ALL=1 RUN_BASIC=0 RUN_TEXT=0 RUN_IMAGE=0 RUN_COMPRESS=0 RUN_ERROR=0

# Parse arguments
while (($#)); do case "$1" in
  -h|--help)
    cat <<EOT
$PRG $VERSION - Test runner for clip utility

Usage: $PRG [options]

Options:
  -a, --all       Run all tests (default)
  -b, --basic     Run basic functionality tests
  -t, --text      Run text copy/paste tests
  -i, --image     Run image tests
  -c, --compress  Run compression tests
  -e, --error     Run error handling tests
  -v, --verbose   Enable verbose output
  -q, --quiet     Disable verbose output
  -h, --help      Display this help message

Examples:
  $PRG            # Run all tests
  $PRG -t         # Run only text tests
  $PRG -t -i      # Run text and image tests
EOT
    exit 0 ;;
  -a|--all)       RUN_ALL=1 ;;
  -b|--basic)     RUN_BASIC=1; RUN_ALL=0 ;;
  -t|--text)      RUN_TEXT=1; RUN_ALL=0 ;;
  -i|--image)     RUN_IMAGE=1; RUN_ALL=0 ;;
  -c|--compress)  RUN_COMPRESS=1; RUN_ALL=0 ;;
  -e|--error)     RUN_ERROR=1; RUN_ALL=0 ;;
  -v|--verbose)   VERBOSE=1 ;;
  -q|--quiet)     VERBOSE=0 ;;
  *)              echo "Unknown option: $1"; exit 1 ;;
esac; shift; done

# Enable all if --all or no specific tests selected
if ((RUN_ALL)) || ((RUN_BASIC + RUN_TEXT + RUN_IMAGE + RUN_COMPRESS + RUN_ERROR == 0)); then
  RUN_BASIC=1
  RUN_TEXT=1
  RUN_IMAGE=1
  RUN_COMPRESS=1
  RUN_ERROR=1
fi

# Check prerequisites
if ! check_xclip; then
  echo "WARNING: xclip not available or no display - some tests will be skipped"
fi

echo "=================================================================================="
echo " Clip Utility Test Suite v${VERSION}"
echo "=================================================================================="

# Run basic functionality tests
if ((RUN_BASIC)); then
  if [[ -f "${PRGDIR}/test_basic.sh" ]]; then
    source "${PRGDIR}/test_basic.sh"
  else
    skip_test "Basic functionality tests" "test_basic.sh not found"
  fi
fi

# Run text copy/paste tests
if ((RUN_TEXT)); then
  if [[ -f "${PRGDIR}/test_text.sh" ]]; then
    source "${PRGDIR}/test_text.sh"
  else
    skip_test "Text copy/paste tests" "test_text.sh not found"
  fi
fi

# Run image tests
if ((RUN_IMAGE)); then
  if [[ -f "${PRGDIR}/test_images.sh" ]]; then
    source "${PRGDIR}/test_images.sh"
  else
    skip_test "Image tests" "test_images.sh not found"
  fi
fi

# Run compression tests
if ((RUN_COMPRESS)); then
  if [[ -f "${PRGDIR}/test_compression.sh" ]]; then
    source "${PRGDIR}/test_compression.sh"
  else
    skip_test "Compression tests" "test_compression.sh not found"
  fi
fi

# Run error handling tests
if ((RUN_ERROR)); then
  if [[ -f "${PRGDIR}/test_errors.sh" ]]; then
    source "${PRGDIR}/test_errors.sh"
  else
    skip_test "Error handling tests" "test_errors.sh not found"
  fi
fi

# Print summary
print_summary
exit $?

#fin