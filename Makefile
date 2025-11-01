# Makefile for clip - Terminal clipboard utility
#
# Targets:
#   make help          - Show this help message (default)
#   make install       - Install system-wide (requires sudo/root)
#   make install-user  - Install for current user only (no sudo)
#   make uninstall     - Remove system-wide installation
#   make uninstall-user - Remove user installation
#   make test          - Run test suite
#   make check         - Run shellcheck on all scripts
#   make clean         - Remove temporary files
#
# Variables:
#   PREFIX            - Installation prefix (default: /usr/local)
#   DESTDIR           - Staging directory for package managers
#
# Examples:
#   sudo make install                    # Install to /usr/local
#   sudo make install PREFIX=/usr        # Install to /usr
#   make install-user                    # Install to ~/.local
#
# Version: 1.0.1
# License: GPL-3.0

# Installation directories
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
COMPDIR = $(PREFIX)/share/bash-completion/completions
MANDIR = $(PREFIX)/share/man/man1

# User installation directories
USER_BINDIR = $(HOME)/.local/bin
USER_COMPDIR = $(HOME)/.local/share/bash-completion/completions
USER_MANDIR = $(HOME)/.local/share/man/man1

# Files to install
SCRIPT = clip
COMPLETION = clip.bash_completion
MANPAGE = clip.1
COMPLETION_INSTALLED = clip

# Default target
.PHONY: help
help:
	@echo "clip v1.0.1 - Makefile targets:"
	@echo ""
	@echo "  make install        Install system-wide (requires sudo)"
	@echo "  make install-user   Install for current user"
	@echo "  make uninstall      Uninstall system-wide installation"
	@echo "  make uninstall-user Uninstall user installation"
	@echo "  make test           Run test suite"
	@echo "  make check          Run shellcheck on all scripts"
	@echo "  make clean          Remove temporary files"
	@echo "  make help           Show this help (default)"
	@echo ""
	@echo "Installation paths (system-wide):"
	@echo "  Binary:     $(DESTDIR)$(BINDIR)/$(SCRIPT)"
	@echo "  Completion: $(DESTDIR)$(COMPDIR)/$(COMPLETION_INSTALLED)"
	@echo "  Man page:   $(DESTDIR)$(MANDIR)/$(MANPAGE).gz"
	@echo ""
	@echo "Installation paths (user):"
	@echo "  Binary:     $(USER_BINDIR)/$(SCRIPT)"
	@echo "  Completion: $(USER_COMPDIR)/$(COMPLETION_INSTALLED)"
	@echo "  Man page:   $(USER_MANDIR)/$(MANPAGE).gz"

# System-wide installation (requires sudo/root)
.PHONY: install
install:
	@echo "◉ Installing clip v1.0.1 (system-wide)..."
	@# Check for root privileges
	@if [ "$$(id -u)" != "0" ]; then \
		echo "✗ Error: System-wide installation requires root privileges"; \
		echo "  Run: sudo make install"; \
		exit 1; \
	fi
	@# Create directories
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(COMPDIR)
	install -d $(DESTDIR)$(MANDIR)
	@# Remove existing installation if present
	@rm -f $(DESTDIR)$(BINDIR)/$(SCRIPT)
	@rm -f $(DESTDIR)$(COMPDIR)/$(COMPLETION_INSTALLED)
	@rm -f $(DESTDIR)$(MANDIR)/$(MANPAGE).gz
	@# Install binary
	install -m 755 $(SCRIPT) $(DESTDIR)$(BINDIR)/$(SCRIPT)
	@# Install bash completion
	install -m 644 $(COMPLETION) $(DESTDIR)$(COMPDIR)/$(COMPLETION_INSTALLED)
	@# Install and compress man page
	install -m 644 $(MANPAGE) $(DESTDIR)$(MANDIR)/$(MANPAGE)
	gzip -f $(DESTDIR)$(MANDIR)/$(MANPAGE)
	@echo "✓ Installation complete!"
	@echo ""
	@echo "Installed files:"
	@echo "  $(DESTDIR)$(BINDIR)/$(SCRIPT)"
	@echo "  $(DESTDIR)$(COMPDIR)/$(COMPLETION_INSTALLED)"
	@echo "  $(DESTDIR)$(MANDIR)/$(MANPAGE).gz"
	@echo ""
	@echo "Usage:"
	@echo "  man clip                           # View manual page"
	@echo "  source $(COMPDIR)/$(COMPLETION_INSTALLED)  # Enable bash completion"

# User-level installation (no sudo required)
.PHONY: install-user
install-user:
	@echo "◉ Installing clip v1.0.1 (user-level)..."
	@# Create directories
	@mkdir -p $(USER_BINDIR)
	@mkdir -p $(USER_COMPDIR)
	@mkdir -p $(USER_MANDIR)
	@# Remove existing installation if present
	@rm -f $(USER_BINDIR)/$(SCRIPT)
	@rm -f $(USER_COMPDIR)/$(COMPLETION_INSTALLED)
	@rm -f $(USER_MANDIR)/$(MANPAGE).gz
	@# Install binary
	@install -m 755 $(SCRIPT) $(USER_BINDIR)/$(SCRIPT)
	@# Install bash completion
	@install -m 644 $(COMPLETION) $(USER_COMPDIR)/$(COMPLETION_INSTALLED)
	@# Install and compress man page
	@install -m 644 $(MANPAGE) $(USER_MANDIR)/$(MANPAGE)
	@gzip -f $(USER_MANDIR)/$(MANPAGE)
	@# Add ~/.local/bin to PATH if not already present
	@if ! echo "$$PATH" | grep -q "$(USER_BINDIR)"; then \
		echo ""; \
		echo "▲ Warning: $(USER_BINDIR) is not in your PATH"; \
		echo "  Add this to your ~/.bashrc:"; \
		echo "    export PATH=\"$(USER_BINDIR):\$$PATH\""; \
	fi
	@# Setup bash completion in ~/.bashrc if not already present
	@if [ -f $(HOME)/.bashrc ]; then \
		if ! grep -q "$(USER_COMPDIR)/$(COMPLETION_INSTALLED)" $(HOME)/.bashrc 2>/dev/null; then \
			echo "" >> $(HOME)/.bashrc; \
			echo "# clip bash completion" >> $(HOME)/.bashrc; \
			echo "[ -f $(USER_COMPDIR)/$(COMPLETION_INSTALLED) ] && source $(USER_COMPDIR)/$(COMPLETION_INSTALLED)" >> $(HOME)/.bashrc; \
			echo "✓ Added bash completion to ~/.bashrc"; \
		fi \
	fi
	@# Setup MANPATH if not already present
	@if [ -f $(HOME)/.bashrc ]; then \
		if ! grep -q "MANPATH.*$(USER_MANDIR)" $(HOME)/.bashrc 2>/dev/null; then \
			echo "" >> $(HOME)/.bashrc; \
			echo "# Add ~/.local/share/man to MANPATH for clip" >> $(HOME)/.bashrc; \
			echo "export MANPATH=\"$(HOME)/.local/share/man:\$$MANPATH\"" >> $(HOME)/.bashrc; \
			echo "✓ Added $(USER_MANDIR) to MANPATH in ~/.bashrc"; \
		fi \
	fi
	@echo "✓ Installation complete!"
	@echo ""
	@echo "Installed files:"
	@echo "  $(USER_BINDIR)/$(SCRIPT)"
	@echo "  $(USER_COMPDIR)/$(COMPLETION_INSTALLED)"
	@echo "  $(USER_MANDIR)/$(MANPAGE).gz"
	@echo ""
	@echo "To use immediately:"
	@echo "  export PATH=\"$(USER_BINDIR):\$$PATH\""
	@echo "  export MANPATH=\"$(HOME)/.local/share/man:\$$MANPATH\""
	@echo "  source $(USER_COMPDIR)/$(COMPLETION_INSTALLED)"
	@echo ""
	@echo "Or restart your shell to apply changes"

# Uninstall system-wide installation
.PHONY: uninstall
uninstall:
	@echo "◉ Uninstalling clip (system-wide)..."
	@if [ "$$(id -u)" != "0" ]; then \
		echo "✗ Error: System-wide uninstallation requires root privileges"; \
		echo "  Run: sudo make uninstall"; \
		exit 1; \
	fi
	@rm -f $(DESTDIR)$(BINDIR)/$(SCRIPT)
	@rm -f $(DESTDIR)$(COMPDIR)/$(COMPLETION_INSTALLED)
	@rm -f $(DESTDIR)$(MANDIR)/$(MANPAGE).gz
	@echo "✓ Uninstallation complete!"

# Uninstall user-level installation
.PHONY: uninstall-user
uninstall-user:
	@echo "◉ Uninstalling clip (user-level)..."
	@rm -f $(USER_BINDIR)/$(SCRIPT)
	@rm -f $(USER_COMPDIR)/$(COMPLETION_INSTALLED)
	@rm -f $(USER_MANDIR)/$(MANPAGE).gz
	@echo "✓ Uninstallation complete!"
	@echo ""
	@echo "Note: Entries in ~/.bashrc remain (PATH, MANPATH, completion)"
	@echo "You may want to remove them manually"

# Run test suite
.PHONY: test
test:
	@if [ -x tests/run_tests.sh ]; then \
		echo "◉ Running test suite..."; \
		./tests/run_tests.sh; \
	else \
		echo "✗ Test suite not found or not executable"; \
		exit 1; \
	fi

# Run shellcheck on all scripts
.PHONY: check
check:
	@echo "◉ Running shellcheck..."
	@shellcheck -x $(SCRIPT) || exit 1
	@shellcheck $(COMPLETION) || exit 1
	@find tests -name "*.sh" -exec shellcheck -x {} \; || exit 1
	@echo "✓ All scripts passed shellcheck"

# Clean temporary files
.PHONY: clean
clean:
	@echo "◉ Cleaning temporary files..."
	@rm -rf tests/output/* tests/tmp/*
	@echo "✓ Clean complete"

#fin
