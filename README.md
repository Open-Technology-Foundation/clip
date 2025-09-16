# clip

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/Open-Technology-Foundation/clip)
[![License](https://img.shields.io/badge/license-GPL--3.0-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-5.2%2B-orange.svg)](https://www.gnu.org/software/bash/)

A command-line clipboard utility for Linux systems that enables seamless data transfer between terminal and GUI applications. Supports both text and image operations with built-in compression capabilities.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Text Operations**: Copy single or multiple files to clipboard, paste text with formatting preservation
- **Image Support**: Handle PNG images with intelligent compression and optimization
- **Compression Modes**: Choose between optimize mode (pngquant/optipng) or resize mode (ImageMagick)
- **Smart Installation**: Auto-install missing dependencies with user confirmation
- **Flexible Output**: Paste to stdout or directly to files with automatic directory creation
- **Custom Formatting**: Add headers/footers when copying files (useful for documentation)
- **Bash Completion**: Full tab completion support for all options and file paths
- **Operation Modes**: Verbose (default) and quiet modes for different use cases
- **Cross-tool Integration**: Works seamlessly with other CLI tools via pipes

## Requirements

- Linux with X11 display server
- Bash shell
- apt package manager (Debian/Ubuntu based systems)

## Installation

### Basic Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/Open-Technology-Foundation/clip.git
cd clip
chmod +x clip
```

### System-wide Installation

Make the script available globally:

```bash
sudo ln -s $(pwd)/clip /usr/local/bin/clip
```

### Bash Completion Setup

Enable tab completion for the clip command:

```bash
# For current session
source .bash_completion

# For permanent installation (user-specific)
echo "source $(pwd)/.bash_completion" >> ~/.bashrc

# For system-wide installation
sudo cp .bash_completion /etc/bash_completion.d/clip
```

## Dependencies

The script will automatically prompt to install missing dependencies:

- **xclip** - Required for all clipboard operations
- **pngquant** - Optional, for lossy PNG compression
- **optipng** - Optional, for lossless PNG optimization
- **imagemagick** - Optional, for resize-based compression

## Usage

### Basic Operations

Copy file to clipboard:
```bash
clip filename.txt
```

Copy multiple files (concatenated):
```bash
clip file1.txt file2.txt file3.txt
```

Paste clipboard to stdout:
```bash
clip -p
```

Paste clipboard to file:
```bash
clip -p output.txt
```

### Image Operations

Paste clipboard image to PNG file:
```bash
clip -p screenshot.png
```

Paste with PNG optimization (lossless):
```bash
clip -p -c optimized.png
```

Paste with resize compression (50% size):
```bash
clip -p -r -Q 50 thumbnail.png
```

### Command Line Options

| Option | Long Form | Description |
|--------|-----------|-------------|
| `-p` | `--paste` | Paste mode (default is copy) |
| `-c` | `--compress` | Enable PNG optimization |
| `-r` | `--resize` | Use resize-based compression |
| `-Q N` | `--quality N` | Set compression quality (1-100, default: 90) |
| `-v` | `--verbose` | Enable verbose output (default) |
| `-q` | `--quiet` | Disable verbose output |
| `-f` | `--use-file-header` | Add headers when copying files |
| `-H` | `--file-header` | Custom header format |
| `-F` | `--file-footer` | Custom footer format |
| `-V` | `--version` | Display version information |
| `-h` | `--help` | Display help message |

## Examples

### Text Operations

Copy configuration file:
```bash
clip ~/.bashrc
```

Copy command output:
```bash
ls -la | xclip -selection clipboard
clip -p directory-listing.txt
```

Copy multiple log files:
```bash
clip error.log warning.log info.log
```

### Image Workflows

Screenshot workflow:
```bash
# Take screenshot with external tool
gnome-screenshot -a

# Paste and optimize
clip -p -c screenshot.png
```

Batch image processing:
```bash
# Copy image to clipboard
xclip -selection clipboard -t image/png < input.png

# Paste with different compressions
clip -p -c optimized.png
clip -p -r -Q 75 resized.png
```

### Scripting Integration

Silent operation in scripts:
```bash
#!/bin/bash
clip -q important.txt
if (($? == 0)); then
    echo 'Successfully copied to clipboard'
fi
```

Pipeline integration:
```bash
# Use clipboard content as input
clip -p | grep ERROR | wc -l

# Save processed clipboard content
clip -p | sed 's/old/new/g' > processed.txt
```

### Real-World Use Cases

Code snippet sharing:
```bash
# Copy function with markdown formatting
clip myfunction.py -f -H '```python\n' -F '\n```'

# Copy SQL query with custom header
clip query.sql -f -H '-- Query: {}\n' -F '\n-- End of query\n'
```

Documentation workflow:
```bash
# Combine multiple markdown files for review
clip intro.md features.md api.md -f

# Copy test results with formatting
clip test_output.txt -f -H '### Test Results: {}\n' -F '\n---\n'
```

Image workflow optimization:
```bash
# Screenshot → Optimize → Save
gnome-screenshot -a  # Take screenshot
clip -p -c -Q 85 screenshot.png  # Paste and optimize at 85% quality

# Batch process clipboard images
for quality in 60 70 80 90; do
  clip -p -c -Q $quality "image_q${quality}.png"
done
```

Development tasks:
```bash
# Copy all Python files in a directory
clip *.py -f -H '\n# File: {}\n' -F ''

# Quick backup before changes
clip config.json && cp config.json config.json.bak

# Copy error logs with timestamp
clip error.log -f -H "# Captured at $(date)\n"
```

### Advanced Usage

Copy with custom formatting:
```bash
# XML format
clip data.txt -f -H '<file name="{}"><![CDATA[\n' -F ']]></file>\n'

# Markdown code blocks
clip script.sh -f -H '```bash\n' -F '\n```\n'
```

## Testing

The project includes a comprehensive test suite with over 50 tests covering all functionality.

### Running Tests

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test categories
./tests/run_tests.sh -b    # Basic functionality
./tests/run_tests.sh -t    # Text operations
./tests/run_tests.sh -i    # Image handling
./tests/run_tests.sh -c    # Compression
./tests/run_tests.sh -e    # Error handling

# Combine test categories
./tests/run_tests.sh -t -i  # Text and image tests

# Verbose output
./tests/run_tests.sh -v
```

### Test Coverage

- **Basic Tests**: Help display, version info, option parsing, GUI detection
- **Text Tests**: Single/multiple file copying, custom headers/footers, special characters
- **Image Tests**: PNG/JPEG handling, clipboard detection, paste operations
- **Compression Tests**: All compression modes, quality levels, size optimization
- **Error Tests**: Invalid options, missing files, permission issues, dependency checks

### Test Framework

The test suite uses a custom framework (`tests/test_lib.sh`) with:
- Color-coded output (✓ pass, ✗ fail, ⊘ skip)
- Assertion functions for comprehensive validation
- Automatic cleanup and environment setup
- Support for skipping tests based on dependencies

## Project Structure

```
clip/
├── clip                # Main script (v1.0.0)
├── README.md           # This documentation
├── LICENSE             # GPL-3.0 license
├── .bash_completion    # Bash completion script
└── tests/              # Test suite
    ├── fixtures/       # Test data files
    ├── test_lib.sh     # Test framework
    ├── run_tests.sh    # Test runner
    ├── test_basic.sh   # Basic functionality tests
    ├── test_text.sh    # Text operation tests
    ├── test_images.sh  # Image handling tests
    ├── test_compression.sh # Compression tests
    ├── test_errors.sh  # Error handling tests
    └── README.md       # Test documentation
```

## Exit Codes

- `0` - Success
- `1` - General error
- `22` - Invalid command-line argument

## Troubleshooting

### Clipboard not working

Ensure X11 display is properly set:
```bash
echo $DISPLAY  # Should show something like :0
```

### Permission denied

Make sure the script is executable:
```bash
chmod +x clip
```

### Package installation fails

Manually install dependencies:
```bash
sudo apt update
sudo apt install xclip pngquant optipng imagemagick
```

### Image paste not working

Verify clipboard contains image data:
```bash
xclip -selection clipboard -t TARGETS -o | grep image
```

### Common Issues

**No display environment**:
```bash
# Check if DISPLAY is set
echo $DISPLAY

# For SSH sessions, enable X11 forwarding
ssh -X user@host
```

**Compression not working**:
```bash
# Check available compression tools
which pngquant optipng convert

# Install missing tools
sudo apt install pngquant optipng imagemagick
```

**Permission denied errors**:
```bash
# Check file permissions
ls -l clip

# Make executable if needed
chmod +x clip
```

**Large file handling**:
```bash
# Use quiet mode for better performance
clip -q largefile.txt

# Split very large files before copying
split -b 10M largefile.txt part_
clip part_* -f
```

## Performance Notes

- For large files, consider using quiet mode (`-q`) to reduce overhead
- PNG compression intelligently skips if result would be larger
- Multiple files are processed sequentially, not in parallel
- Compression quality affects both file size and processing time

## Limitations

- Linux/X11 only (Wayland support experimental)
- Requires apt package manager for auto-installation
- Image support limited to PNG format for pasting
- No built-in clipboard history or monitoring
- Text encoding assumed to be UTF-8

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Development

### Code Style

This project follows strict Bash coding standards:
- Shebang: `#!/usr/bin/env bash`
- Error handling: `set -euo pipefail`
- Indentation: 2 spaces (no tabs)
- Variable declarations: Use `declare` with proper types (`-i` for integers)
- Conditionals: Prefer `[[` over `[`
- Functions: Snake_case with descriptive names

## Contributing

We welcome contributions! Please follow these guidelines:

### Before Submitting

1. **Test Your Changes**:
   ```bash
   # Run the full test suite
   ./tests/run_tests.sh

   # Verify shellcheck passes
   shellcheck clip
   ```

2. **Follow Code Style**:
   - Match existing indentation (2 spaces)
   - Use meaningful variable and function names
   - Add comments for complex logic
   - Include error handling

3. **Update Documentation**:
   - Update README.md if adding features
   - Add tests for new functionality
   - Document any new dependencies

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes with clear messages
4. Push to your fork (`git push origin feature/amazing-feature`)
5. Open a Pull Request with:
   - Clear description of changes
   - Any related issue numbers
   - Test results or screenshots

### Development Tips

- Use `clip -v` for debugging output
- Test with various file types and sizes
- Verify both X11 and Wayland compatibility when possible
- Check memory usage with large files
- Test error conditions thoroughly

## Support

For issues, feature requests, or questions, please open an issue on the [GitHub repository](https://github.com/Open-Technology-Foundation/clip).

## Acknowledgments

Built upon the foundation of xclip, with compression capabilities leveraging pngquant, optipng, and ImageMagick.
