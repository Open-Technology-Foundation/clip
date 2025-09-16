# Clip Utility Test Suite

Comprehensive test suite for the `clip` clipboard utility.

## Directory Structure

```
tests/
├── fixtures/           # Test data files
│   ├── shen2.jpg      # Test JPEG image
│   └── sim-indonesia.png  # Test PNG image
├── output/            # Test output directory
├── tmp/               # Temporary test files
├── test_lib.sh        # Test framework and utilities
├── run_tests.sh       # Main test runner
├── test_basic.sh      # Basic functionality tests
├── test_text.sh       # Text copy/paste tests
├── test_images.sh     # Image handling tests
├── test_compression.sh # Image compression tests
└── test_errors.sh     # Error handling tests
```

## Running Tests

### Run all tests
```bash
./run_tests.sh
```

### Run specific test groups
```bash
./run_tests.sh -b    # Basic functionality tests only
./run_tests.sh -t    # Text copy/paste tests only
./run_tests.sh -i    # Image tests only
./run_tests.sh -c    # Compression tests only
./run_tests.sh -e    # Error handling tests only
```

### Combine test groups
```bash
./run_tests.sh -t -i  # Run text and image tests
```

### Options
- `-a, --all` - Run all tests (default)
- `-b, --basic` - Run basic functionality tests
- `-t, --text` - Run text copy/paste tests
- `-i, --image` - Run image tests
- `-c, --compress` - Run compression tests
- `-e, --error` - Run error handling tests
- `-v, --verbose` - Enable verbose output
- `-q, --quiet` - Disable verbose output
- `-h, --help` - Display help message

## Test Categories

### Basic Functionality Tests (`test_basic.sh`)
- Help option display
- Version information
- Invalid option handling
- Quiet/verbose modes
- Combined short options
- GUI environment detection

### Text Copy/Paste Tests (`test_text.sh`)
- Copy single file to clipboard
- Copy multiple files to clipboard
- Paste clipboard to file
- File headers and footers
- Custom headers/footers
- Empty file handling
- Large file handling
- Special character preservation
- Quiet/verbose modes

### Image Tests (`test_images.sh`)
- JPEG file handling
- PNG file operations
- Image detection in clipboard
- Basic paste operations
- Image tool availability checks

### Compression Tests (`test_compression.sh`)
- PNG optimization with pngquant
- PNG optimization with optipng
- ImageMagick resize operations
- Quality level variations (20-100)
- File size comparisons
- Upscaling tests
- Compression fallback mechanisms
- Skip compression when not beneficial

### Error Handling Tests (`test_errors.sh`)
- Invalid options
- Missing arguments
- Non-existent files
- Directory instead of file
- Read-only directory operations
- Invalid path characters
- Multiple paste destinations
- GUI environment errors
- Missing dependencies

## Test Framework Features

The test framework (`test_lib.sh`) provides:

### Assertion Functions
- `assert_success` - Assert command succeeds
- `assert_failure` - Assert command fails
- `assert_equal` - Assert string equality
- `assert_file_exists` - Assert file exists
- `assert_file_contains` - Assert file contains text
- `assert_output` - Assert output contains expected text
- `skip_test` - Skip test with reason

### Utility Functions
- `setup_test` - Prepare test environment
- `cleanup_test` - Clean up after tests
- `create_test_file` - Create test files with content
- `check_xclip` - Check if xclip is available
- `check_image_tools` - Check for image optimization tools
- `run_test_group` - Group test output
- `print_summary` - Display test results summary

### Output Formatting
- Color-coded test results (✓ pass, ✗ fail, ⊘ skip)
- Informational messages with ℹ symbol
- Clear test grouping and summaries

## Requirements

### Required
- Bash 5.2+
- xclip (for clipboard operations)

### Optional
- pngquant (for lossy PNG compression)
- optipng (for lossless PNG optimization)
- imagemagick (for resize operations)
- X11 or Wayland display (for clipboard tests)

## Known Limitations

1. **Display Required**: Many tests require an X11 or Wayland display for clipboard operations. Tests will be skipped if no display is available.

2. **Image Tests**: Image clipboard tests require manual clipboard population or xclip with proper display setup. Some tests may be skipped in headless environments.

3. **Permission Tests**: Some error handling tests require specific filesystem permissions that may not be testable in all environments.

4. **Tool Dependencies**: Compression tests require optional tools (pngquant, optipng, imagemagick). Tests will be skipped if tools are not installed.

## Test Development

To add new tests:

1. Create a new test file following the naming convention `test_*.sh`
2. Source the test library: `source "$(dirname "${BASH_SOURCE[0]}")/test_lib.sh"`
3. Use `run_test_group` to label your tests
4. Use assertion functions for test validation
5. Add the test to `run_tests.sh` if needed

Example test structure:
```bash
#!/usr/bin/env bash
set -euo pipefail

run_test_group "My Test Group"

# Setup
setup_test

# Test
output=$("$CLIP_CMD" -h 2>&1 || true)
assert_output "Test description" "expected text" "$output"

# Cleanup
cleanup_test

#fin
```

## Continuous Integration

The test suite can be integrated into CI/CD pipelines. Use exit codes to determine success:
- 0: All tests passed
- 1: One or more tests failed

For headless CI environments, many clipboard tests will be automatically skipped.

#fin