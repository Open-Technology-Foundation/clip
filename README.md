# Clip Utility

A simple command-line tool for clipboard operations in Linux. Easily copy file contents to clipboard or paste clipboard contents to files.

## Features

- Copy content from multiple files to clipboard
- Paste clipboard content to files or stdout
- Auto-installs required dependencies
- Verbose and quiet modes

## Installation

Clone this repository and make the scripts executable:

```bash
git clone <repository-url>
cd clip
chmod +x clip
ln -s $(pwd)/clip /usr/local/bin/clip
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

- `-p, --paste`: Paste mode
- `-v, --verbose`: Verbose output (default)
- `-q, --quiet`: Quiet mode
- `-V, --version`: Display version information
- `-h, --help`: Display help message

## Examples

```bash
# Copy a file to clipboard
clip myfile.txt

# Copy multiple files to clipboard
clip file1.txt file2.txt

# Paste clipboard contents to stdout
clip -p

# Paste clipboard contents to a file
clip -p output.txt

# Copy silently (no confirmation or informational messages)
clip -q myfile.txt
```

## License

GPL-3

