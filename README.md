# clip

A command-line clipboard utility for Linux systems that enables seamless data transfer between terminal and GUI applications. Supports both text and image operations with built-in compression capabilities.

## Features

- Copy file contents to system clipboard
- Paste clipboard contents to files or stdout
- Handle both text and PNG image data
- Automatic PNG compression with multiple algorithms
- Auto-installation of required dependencies
- Directory auto-creation for output files
- Verbose and quiet operation modes

## Requirements

- Linux with X11 display server
- Bash shell
- apt package manager (Debian/Ubuntu based systems)

## Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/okusi-systems/clip.git
cd clip
chmod +x clip
```

For system-wide access:

```bash
sudo ln -s $(pwd)/clip /usr/local/bin/clip
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
if [ $? -eq 0 ]; then
    echo "Successfully copied to clipboard"
fi
```

Pipeline integration:
```bash
# Use clipboard content as input
clip -p | grep "ERROR" | wc -l

# Save processed clipboard content
clip -p | sed 's/old/new/g' > processed.txt
```

### Advanced Usage

Copy with custom formatting:
```bash
# XML format
clip data.txt -f -H '<file name="{}"><![CDATA[\n' -F ']]></file>\n'

# Markdown code blocks
clip script.sh -f -H '```bash\n' -F '\n```\n'
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

## Performance Notes

- For large files, consider using quiet mode (`-q`) to reduce overhead
- PNG compression is intelligent - only applies if result is smaller
- Multiple files are processed sequentially, not in parallel

## Limitations

- Linux/X11 only (no Wayland support currently)
- Requires apt package manager for auto-installation
- Supports only text and PNG image formats
- No clipboard history or monitoring features

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome. Please ensure:

1. Code follows existing style conventions
2. Scripts pass shellcheck validation
3. All functions include documentation
4. Error handling is comprehensive
5. Changes maintain backward compatibility

## Support

For issues, feature requests, or questions, please open an issue on the [GitHub repository](https://github.com/okusi-systems/clip).

## Acknowledgments

Built upon the foundation of xclip, with compression capabilities leveraging pngquant, optipng, and ImageMagick.
