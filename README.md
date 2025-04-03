# Clip Utility

A simple command-line tool for clipboard operations in Linux. Easily copy file contents to clipboard or paste clipboard contents to files or stdout.

![GitHub license](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Version](https://img.shields.io/badge/version-0.8.3-green.svg)

## Features

- Copy content from multiple files to clipboard
- Paste clipboard content to files or stdout
- Paste and optimize clipboard image data (PNG)
- Auto-installs required dependencies
- Creates destination directories automatically
- Confirmation prompt when overwriting existing files
- Verbose and quiet operation modes

## Installation

Clone this repository and make the script executable:

```bash
git clone https://github.com/okusi-systems/clip.git
cd clip
chmod +x clip
# Optional: make globally available
sudo ln -s $(pwd)/clip /usr/local/bin/clip
```

## Dependencies

- `xclip` (automatically installed if missing)
- Optional dependencies for image compression:
  - `pngquant` (for PNG optimization)
  - `optipng` (for PNG optimization)
  - `imagemagick` (for resize-based compression)

All optional dependencies are automatically installed when needed.

## Usage

### Copy file contents to clipboard

```bash
clip filename [filename ...]
```

### Paste clipboard contents

```bash
clip -p [filename]
```

If no filename is provided, outputs to stdout.

### Options

- `-p, --paste`: Paste clipboard contents to file or stdout
- `-c, --compress`: Optimize PNG image when pasting
- `-r, --resize`: Use resize-based compression instead of optimization
- `-Q, --quality N`: Set compression quality/level (1-100, default: 90)
- `-v, --verbose`: Enable verbose output (default)
- `-q, --quiet`: Disable verbose output
- `-V, --version`: Display version information
- `-h, --help`: Display help message

## Examples

```bash
# Copy a file to clipboard
clip myfile.txt

# Copy multiple files to clipboard (concatenated)
clip file1.txt file2.txt

# Paste clipboard contents to stdout
clip -p

# Paste clipboard contents to a file (creates directory if needed)
clip -p output.txt

# Paste clipboard contents silently (no confirmation or informational messages)
clip -q -p output.txt

# Paste clipboard image data to a PNG file
clip -p screenshot.png

# Paste and optimize clipboard image data (reduces file size)
clip -p -c screenshot.png

# Paste and resize image to 75% of original size
clip -p -r -Q 75 image.png

# Display help information
clip -h
```

## Image Handling

The script can handle both text and image data in the clipboard:

- **Text data**: Copied directly from clipboard to the specified file
- **Image data (PNG)**: Two compression methods are available:
  - **PNG optimization** (`-c` option): Uses specialized tools to reduce file size while maintaining quality
  - **Resize-based compression** (`-r` option): Reduces image dimensions for more aggressive compression

The compression is intelligent - it only uses the compressed version if it's actually smaller than the original.

## Error Handling

- Validates file existence before copying
- Prompts for confirmation when overwriting files
- Creates destination directories automatically when pasting
- Returns appropriate exit codes for error conditions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE) - see the LICENSE file for details.