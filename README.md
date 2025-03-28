# Clip Utility

A simple command-line tool for clipboard operations in Linux. Easily copy file contents to clipboard or paste clipboard contents to files or stdout.

![GitHub license](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Version](https://img.shields.io/badge/version-0.8.1-green.svg)

## Features

- Copy content from multiple files to clipboard
- Paste clipboard content to files or stdout
- Auto-installs required dependencies (xclip)
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

# Display help information
clip -h
```

## Error Handling

- Validates file existence before copying
- Prompts for confirmation when overwriting files
- Creates destination directories automatically when pasting
- Returns appropriate exit codes for error conditions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE) - see the LICENSE file for details.

