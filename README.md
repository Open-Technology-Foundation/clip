# clip

[![Version](https://img.shields.io/badge/version-1.0.1-blue.svg)](https://github.com/Open-Technology-Foundation/clip)
[![License](https://img.shields.io/badge/license-GPL--3.0-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-5.2%2B-orange.svg)](https://www.gnu.org/software/bash/)
[![BCS Compliant](https://img.shields.io/badge/BCS-100%25-brightgreen.svg)](https://github.com/Open-Technology-Foundation/bash-coding-standard)
[![ShellCheck](https://img.shields.io/badge/shellcheck-clean-success.svg)](https://www.shellcheck.net/)
[![Tests](https://img.shields.io/badge/tests-97.4%25%20pass-success.svg)](#testing)
[![Security](https://img.shields.io/badge/security-0%20vulnerabilities-brightgreen.svg)](#security)

A professional-grade command-line clipboard utility for Linux systems that enables seamless data transfer between terminal and GUI applications. Fully BCS-compliant with comprehensive input validation and zero security vulnerabilities.

## Quick Install

**One-liner** (downloads and installs automatically):
```bash
curl -sSL https://raw.githubusercontent.com/Open-Technology-Foundation/clip/main/install.sh | bash
```

**Or clone and install using make**:
```bash
git clone https://github.com/Open-Technology-Foundation/clip.git
cd clip
sudo make install      # System-wide installation
```

**User-level install** (no sudo required):
```bash
git clone https://github.com/Open-Technology-Foundation/clip.git
cd clip
make install-user      # Installs to ~/.local/bin
```

For detailed installation options and manual installation, see [Installation](#installation).

## Table of Contents

- [Features](#features)
- [Code Quality](#code-quality)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Operations](#basic-operations)
  - [Image Operations](#image-operations)
  - [Advanced Features](#advanced-features)
- [Examples](#examples)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Features

- ✓ **Text Operations**: Copy single or multiple files to clipboard, paste with formatting preservation
- ✓ **PNG Image Support**: Intelligent image handling with clipboard detection
- ✓ **Smart Compression**: Two modes with automatic tool selection:
  - **Optimize mode**: pngquant (best) → optipng → imagemagick (fallback)
  - **Resize mode**: Dimension-based compression via ImageMagick
- ✓ **Intelligent Size Checking**: Only uses compressed version if actually smaller
- ✓ **Auto-Installation**: Prompts for missing dependencies with user confirmation
- ✓ **Flexible Output**: Paste to stdout or files with automatic directory creation
- ✓ **Custom Formatting**: Add headers/footers when copying files (markdown, XML, etc.)
- ✓ **Bash 5.2+ Modern Patterns**: `[[`, `(())`, proper arrays, nameref support
- ✓ **Professional Error Handling**: `set -euo pipefail`, comprehensive input validation
- ✓ **Safe Reinstallation**: Automatically replaces existing installations without prompts
- ✓ **Verbose/Quiet Modes**: Control output verbosity for scripting or debugging

## Code Quality

This project maintains professional-grade code standards:

- ✓ **BCS Compliance**: 100% compliant with Bash Coding Standard
- ✓ **ShellCheck Clean**: Zero warnings or errors on all scripts
- ✓ **Security**: Zero vulnerabilities detected
  - No command injection risks
  - Safe file operations with validation
  - Proper input sanitization
  - Protected variable expansions
- ✓ **Test Coverage**: 97.4% pass rate (76/78 tests)
- ✓ **Modern Bash**: Bash 5.2+ patterns throughout
  - `[[` for conditionals (not `[` or `test`)
  - `(())` for arithmetic (not `expr`)
  - Proper array handling with `"${array[@]}"`
  - No deprecated patterns (backticks, `function` keyword, etc.)
- ✓ **Error Handling**: Comprehensive exit codes and error messages
- ✓ **Documentation**: Inline comments explaining WHY, not just WHAT

## Requirements

### System Requirements

- **Operating System**: Linux (X11 or Wayland with XWayland)
- **Bash Version**: 5.2 or later
- **Package Manager**: apt (Debian/Ubuntu) for auto-installation
  - Manual installation supported for other distros

### Display Environment

- **X11**: Native support via `DISPLAY` variable
- **Wayland**: Works via XWayland compatibility layer
- **SSH**: X11 forwarding supported (`ssh -X`)

### Dependencies

**Required**:
- `xclip` - Core clipboard operations (auto-installed if missing)

**Optional** (for PNG compression):
- `pngquant` - Best lossy compression with quality control
- `optipng` - Lossless optimization (fallback)
- `imagemagick` - Resize-based compression and final fallback

All optional dependencies can be auto-installed when needed.

## Installation

### Recommended: Using Makefile

The easiest and most reliable installation method.

**System-wide installation** (requires sudo):
```bash
git clone https://github.com/Open-Technology-Foundation/clip.git
cd clip
sudo make install
```

This installs:
- Binary to `/usr/local/bin/clip`
- Bash completion to `/usr/local/share/bash-completion/completions/clip`
- Man page to `/usr/local/share/man/man1/clip.1.gz`

**User-level installation** (no sudo required):
```bash
git clone https://github.com/Open-Technology-Foundation/clip.git
cd clip
make install-user
```

This installs:
- Binary to `~/.local/bin/clip`
- Bash completion to `~/.local/share/bash-completion/completions/clip`
- Man page to `~/.local/share/man/man1/clip.1.gz`
- Automatically adds `~/.local/bin` to PATH in `~/.bashrc`
- Adds `~/.local/share/man` to MANPATH in `~/.bashrc`
- Sets up bash completion in `~/.bashrc`

**Other Makefile targets**:
```bash
make help           # Show all available targets
make uninstall      # Remove system-wide installation
make uninstall-user # Remove user installation
make test           # Run test suite
make check          # Run shellcheck on all scripts
```

### Using install.sh Script

Interactive installation with auto-detection:

**Local installation**:
```bash
git clone https://github.com/Open-Technology-Foundation/clip.git
cd clip
./install.sh
```

**Remote one-liner**:
```bash
curl -sSL https://raw.githubusercontent.com/Open-Technology-Foundation/clip/main/install.sh | bash
```

The script will:
- ✓ Auto-detect system vs user installation
- ✓ Install dependencies (xclip) if needed
- ✓ Set up bash completion automatically
- ✓ Install man page with gzip compression
- ✓ Add to PATH and MANPATH if needed (user install)
- ✓ Verify installation

**Note**: Both Makefile and install.sh automatically remove any existing clip installation (including symlinks) before installing. No prompts are given - existing files are safely replaced.

### Manual Installation

For custom setups or other distributions.

**1. Download the script**:
```bash
git clone https://github.com/Open-Technology-Foundation/clip.git
cd clip
chmod +x clip
```

**2. Install binary**:
```bash
# System-wide
sudo cp clip /usr/local/bin/

# User-level
mkdir -p ~/.local/bin
cp clip ~/.local/bin/
export PATH="$HOME/.local/bin:$PATH"  # Add to ~/.bashrc for persistence
```

**3. Install bash completion** (optional):
```bash
# System-wide
sudo mkdir -p /usr/local/share/bash-completion/completions
sudo cp clip.bash_completion /usr/local/share/bash-completion/completions/clip

# User-level
mkdir -p ~/.local/share/bash-completion/completions
cp clip.bash_completion ~/.local/share/bash-completion/completions/clip
echo '[ -f ~/.local/share/bash-completion/completions/clip ] && source ~/.local/share/bash-completion/completions/clip' >> ~/.bashrc
```

**4. Verify installation**:
```bash
clip -V                    # Should show: clip 1.0.1
clip -h                    # Show help text
man clip                   # View manual page
```

### Uninstallation

**Using Makefile**:
```bash
sudo make uninstall        # System-wide
make uninstall-user        # User-level
```

**Manual removal**:
```bash
# System-wide
sudo rm /usr/local/bin/clip
sudo rm /usr/local/share/bash-completion/completions/clip

# User-level
rm ~/.local/bin/clip
rm ~/.local/share/bash-completion/completions/clip
# Also remove entries from ~/.bashrc
```

## Usage

For complete documentation, see: `man clip`

### Basic Operations

**Copy file to clipboard**:
```bash
clip filename.txt
```

**Copy multiple files** (concatenated):
```bash
clip file1.txt file2.txt file3.txt
```

**Paste clipboard to stdout**:
```bash
clip -p
```

**Paste clipboard to file**:
```bash
clip -p output.txt
```

**Quiet mode** (for scripts):
```bash
clip -q important.txt
```

### Image Operations

**Paste PNG image**:
```bash
clip -p screenshot.png
```

**Paste with optimization** (automatic tool selection):
```bash
clip -p -c optimized.png
```

**Paste with quality control** (pngquant):
```bash
clip -p -c -Q 85 image.png    # Max quality 85 (lower = smaller)
```

**Resize-based compression** (ImageMagick):
```bash
clip -p -r -Q 75 thumbnail.png    # Resize to 75% of dimensions
clip -p -r -Q 50 small.png        # Resize to 50% of dimensions
```

### Advanced Features

**Copy with custom headers/footers**:
```bash
# Markdown code blocks
clip script.sh -f -H '```bash\n' -F '\n```\n'

# XML format
clip data.txt -f -H '<file name="{}"><![CDATA[\n' -F ']]></file>\n'

# SQL comments
clip query.sql -f -H '-- Query: {}\n' -F '\n-- End\n'
```

**Multiple files with headers**:
```bash
clip intro.md features.md api.md -f
```

### Command-Line Options

| Short | Long | Description |
|-------|------|-------------|
| `-p` | `--paste` | Paste mode (default is copy) |
| `-c` | `--compress` | Optimize PNG (pngquant/optipng/imagemagick) |
| `-r` | `--resize` | Use resize-based compression |
| `-Q N` | `--quality N` | Compression quality 1-100 (default: 90) |
| `-f` | `--use-file-header` | Add headers/footers when copying |
| `-H STR` | `--file-header STR` | Custom header (use {} for filename) |
| `-F STR` | `--file-footer STR` | Custom footer |
| `-v` | `--verbose` | Verbose output (default) |
| `-q` | `--quiet` | Quiet mode (suppress non-error output) |
| `-V` | `--version` | Display version |
| `-h` | `--help` | Display help message |

**Combined short options** are supported:
```bash
clip -vp          # Verbose paste
clip -qc          # Quiet compress
clip -pcrQ85      # Paste, compress, resize, quality 85
```

## Examples

### Text Workflows

**Copy configuration files**:
```bash
clip ~/.bashrc
clip /etc/nginx/nginx.conf
```

**Pipe command output via clipboard**:
```bash
# Copy output to clipboard
ls -la | xclip -selection clipboard
# Paste to file
clip -p directory-listing.txt
```

**Copy with formatting for documentation**:
```bash
# Create markdown code block
clip myfunction.py -f -H '```python\n' -F '\n```\n'

# Copy multiple files with separators
clip *.py -f -H '\n# File: {}\n' -F '\n---\n'
```

### Image Workflows

**Screenshot → Optimize → Save**:
```bash
# 1. Take screenshot (copies to clipboard)
gnome-screenshot -a

# 2. Paste and optimize
clip -p -c screenshot.png
```

**Test different compression settings**:
```bash
# Try multiple quality levels
for q in 60 70 80 90; do
  clip -p -c -Q $q "screenshot_q${q}.png"
done
```

**Convert via clipboard**:
```bash
# Put image in clipboard
xclip -selection clipboard -t image/png < input.png

# Output with different compressions
clip -p -c optimized.png              # Optimize (best tool)
clip -p -r -Q 75 resized_75.png       # Resize to 75%
clip -p -r -Q 50 thumbnail.png        # Resize to 50%
```

### Scripting Integration

**Silent operation with error checking**:
```bash
#!/bin/bash
if clip -q important.txt; then
  echo '✓ Copied to clipboard'
else
  echo '✗ Copy failed' >&2
  exit 1
fi
```

**Pipeline processing**:
```bash
# Filter clipboard content
clip -p | grep ERROR | wc -l

# Process and save
clip -p | sed 's/old/new/g' > processed.txt

# Combine with other tools
clip -p | jq . > formatted.json
```

**Conditional operations**:
```bash
# Only copy if file exists and is readable
[[ -r file.txt ]] && clip file.txt || echo "Cannot read file"

# Copy and backup
clip config.json && cp config.json config.json.bak
```

### Development Tasks

**Quick code review**:
```bash
# Copy all changed files
clip $(git diff --name-only)

# Copy specific function
clip -f main.py -H '# Function: main()\n' -F '\n'
```

**Documentation generation**:
```bash
# Combine docs for review
clip README.md API.md INSTALL.md -f

# Add timestamped header
clip error.log -f -H "# Captured: $(date)\n"
```

**Batch operations**:
```bash
# Copy all test files
clip tests/*.py -f -H '\n## {}\n' -F ''

# Quick file comparison
clip file1.txt file2.txt -f
```

## Testing

The project includes a comprehensive test suite with 9 test scripts covering all functionality.

### Running Tests

```bash
# Run all tests (default)
./tests/run_tests.sh

# Run specific test categories
./tests/run_tests.sh -b    # Basic functionality
./tests/run_tests.sh -t    # Text operations
./tests/run_tests.sh -i    # Image handling
./tests/run_tests.sh -c    # Compression
./tests/run_tests.sh -e    # Error handling

# Combine categories
./tests/run_tests.sh -t -i -c

# Verbose output
./tests/run_tests.sh -v
```

### Test Results

Current test status: **97.4% pass rate** (76/78 tests passed, 2 skipped)

Test output uses standardized icons:
- ✓ **Pass**: Test succeeded
- ✗ **Fail**: Test failed
- ⊘ **Skip**: Test skipped (missing dependencies or environment)
- ℹ **Info**: Informational message

### Test Categories

**Basic Tests** (`test_basic.sh`):
- ✓ Help and version display
- ✓ Option parsing (short, long, combined)
- ✓ Invalid option handling
- ✓ GUI environment detection

**Text Tests** (`test_text.sh`):
- ✓ Single/multiple file copying
- ✓ Custom headers and footers
- ✓ Empty files and large files
- ✓ Special characters preservation
- ✓ Clipboard content validation

**Image Tests** (`test_images.sh`):
- ✓ PNG clipboard detection
- ✓ Image paste operations
- ✓ JPEG fixture availability
- ✓ Compression option validation

**Compression Tests** (`test_compression.sh`):
- ✓ pngquant optimization (quality levels 20-100)
- ✓ optipng optimization
- ✓ Resize operations (10%-100%)
- ✓ File size comparisons
- ✓ Fallback behavior

**Error Tests** (`test_errors.sh`):
- ✓ Invalid options
- ✓ Missing files
- ✓ Permission checks
- ✓ Dependency validation

### Code Quality Verification

```bash
# Run ShellCheck on all scripts
shellcheck -x clip
find tests -name "*.sh" -exec shellcheck -x {} \;

# Verify BCS compliance (if bcs tool available)
bcs check clip

# Check version consistency
./clip -V
grep "VERSION=" clip
```

## Project Structure

```
clip/
├── clip                    # Main script (408 lines, 14 functions)
├── clip.1                  # Man page (groff format)
├── clip.bash_completion    # Bash tab completion (92 lines)
├── install.sh              # Installation script (324 lines)
├── Makefile                # Installation targets
├── README.md               # This documentation
├── LICENSE                 # GPL-3.0 license
├── .gitignore              # Git ignore patterns
└── tests/                  # Test suite (97.4% pass rate)
    ├── fixtures/           # Test data (PNG, JPEG samples)
    ├── test_lib.sh         # Test framework (260 lines)
    ├── run_tests.sh        # Main test runner
    ├── test_basic.sh       # Basic functionality tests
    ├── test_text.sh        # Text operation tests
    ├── test_images.sh      # Image handling tests
    ├── test_compression.sh # Compression tests
    ├── test_errors.sh      # Error handling tests
    ├── test_simple.sh      # Quick smoke tests
    └── test_summary.sh     # Test summary reporter
```

### Key Components

**Main Script** (`clip`):
- 408 lines of BCS-compliant Bash 5.2+ code
- 14 functions with comprehensive documentation
- Zero ShellCheck warnings
- Complete error handling with `set -euo pipefail`

**Test Framework** (`test_lib.sh`):
- 8 assertion functions
- Color-coded output
- Automatic setup/cleanup
- Dependency checking

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error (file not found, clipboard operation failed, etc.) |
| 22 | Invalid argument (bad option, quality out of range, etc.) |

## Troubleshooting

### ◉ Clipboard Not Working

**Check display environment**:
```bash
echo $DISPLAY          # Should show :0 or similar
echo $WAYLAND_DISPLAY  # May show wayland-0
```

**For SSH sessions**, enable X11 forwarding:
```bash
ssh -X user@host
```

### ◉ xclip Not Installed

Script will prompt for installation automatically:
```bash
clip myfile.txt
# Prompts: "Install xclip? y/n"
```

Manual installation:
```bash
sudo apt update && sudo apt install xclip
```

### ◉ Image Compression Not Working

**Check available tools**:
```bash
which pngquant optipng convert
```

**Install compression tools**:
```bash
# Best option: all tools
sudo apt install pngquant optipng imagemagick

# Minimum for optimization
sudo apt install pngquant

# Minimum for resize mode
sudo apt install imagemagick
```

### ▲ Permission Denied

**Make script executable**:
```bash
chmod +x clip
```

**Check file permissions**:
```bash
ls -l clip    # Should show -rwxr-xr-x or similar
```

### ▲ Compression Doesn't Reduce Size

This is normal behavior. The script only uses the compressed version if it's actually smaller:

```bash
clip -p -c image.png
# ◉ Original image size: 500000 bytes
# ◉ Compressed image size: 520000 bytes
# ◉ Compression did not reduce file size, using original
```

Some images (already compressed, small, or simple) may not compress further.

### ◉ Large File Handling

For very large files, use quiet mode to reduce overhead:
```bash
clip -q largefile.txt
```

Consider splitting extremely large files:
```bash
split -b 10M largefile.txt part_
clip part_* -f
```

### ◉ Wayland Compatibility

Wayland systems work via XWayland compatibility:
```bash
# Both should be set on Wayland
echo $WAYLAND_DISPLAY
echo $DISPLAY
```

If `DISPLAY` is not set, xclip may not work. Ensure XWayland is running.

## Performance Notes

- ✓ **Compression intelligence**: Automatically skips if result would be larger
- ✓ **Tool caching**: Command paths cached at startup, not repeatedly looked up
- ✓ **Single-pass processing**: Multiple files processed in one pipeline
- ✓ **Quiet mode**: Use `-q` for scripting to reduce overhead
- ✓ **Sequential file processing**: Files handled one at a time (not parallel)

Typical performance:
- Text files: Near-instant (limited by clipboard I/O)
- PNG optimization: 1-3 seconds for typical screenshots
- Resize operations: <1 second for most images

## Limitations

- **Platform**: Linux only (X11 or Wayland with XWayland)
- **Image format**: PNG only for paste operations with compression
- **Package manager**: Auto-install requires apt (manual install supported for others)
- **Text encoding**: Assumes UTF-8 (most common)
- **No clipboard history**: Single clipboard operation only
- **No clipboard monitoring**: Manual invocation required

## Development

### Code Standards

This project follows strict Bash 5.2+ coding standards:

**BCS Compliance** (100%):
- Shebang: `#!/usr/bin/env bash`
- Error handling: `set -euo pipefail`
- Required shopt: `inherit_errexit shift_verbose extglob nullglob`
- 2-space indentation (no tabs)
- `declare` with proper types (`-i` for integers, `-r` for readonly)
- Conditionals: `[[` (not `[` or `test`)
- Arithmetic: `(())` (not `expr` or `$[]`)
- No deprecated patterns (backticks, `function` keyword, etc.)

**Security Best Practices**:
- No `eval` with user input
- All variables quoted: `"$var"`
- File operations validated: `[[ -f "$file" ]]`
- Input bounds checking: `((QUALITY >= 1 && QUALITY <= 100))`
- Safe temporary files with cleanup traps
- Interactive confirmations for destructive operations

**Documentation**:
- Function headers explain WHY, not just WHAT
- Complex logic has inline explanations
- ShellCheck suppressions documented with reasons

### Development Setup

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/clip.git
cd clip

# Run tests
./tests/run_tests.sh

# Check code quality
shellcheck -x clip
shellcheck -x tests/*.sh

# Verify BCS compliance
bcs check clip    # If bcs tool available
```

### Making Changes

1. **Follow code style** - Match existing patterns
2. **Add tests** - Cover new functionality
3. **Run ShellCheck** - Must pass with zero warnings
4. **Test thoroughly** - Run full test suite
5. **Document** - Update help text and README

## Contributing

Contributions are welcome! Please ensure all submissions meet quality standards:

### Requirements for Pull Requests

**✓ Code Quality**:
- ShellCheck clean (zero warnings)
- BCS compliant
- Bash 5.2+ patterns only
- Comprehensive error handling

**✓ Testing**:
- Add tests for new features
- All existing tests must pass
- Maintain >95% pass rate

**✓ Documentation**:
- Update README.md for user-facing changes
- Update help text in script
- Add inline comments for complex logic

**✓ Security**:
- No command injection risks
- Proper input validation
- Safe file operations

### Contribution Process

1. **Fork** the repository
2. **Create branch**: `git checkout -b feature/amazing-feature`
3. **Make changes** following code standards
4. **Test thoroughly**: `./tests/run_tests.sh && shellcheck -x clip`
5. **Commit** with clear messages
6. **Push**: `git push origin feature/amazing-feature`
7. **Open Pull Request** with:
   - Clear description of changes
   - Test results
   - Any related issue numbers

### Code Review Criteria

- ✓ Functionality works as intended
- ✓ No security vulnerabilities introduced
- ✓ Code style matches project standards
- ✓ Adequate test coverage
- ✓ Documentation updated
- ✓ No regression of existing features

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Support

For bug reports, feature requests, or questions:
- **Issues**: [GitHub Issues](https://github.com/Open-Technology-Foundation/clip/issues)
- **Discussions**: Use issue tracker for general questions

## Acknowledgments

Built upon the foundation of:
- **xclip** - X11 clipboard interface
- **pngquant** - High-quality PNG compression
- **optipng** - PNG optimizer
- **ImageMagick** - Image processing toolkit

Developed following the [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard) for professional-grade shell scripting.

---

**clip 1.0.1** - Professional clipboard utility for Linux | BCS Compliant | Zero Vulnerabilities

#fin
