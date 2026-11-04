# Makefile - Install clip (BCS1212)
#
# Targets:  install uninstall check test help
# Usage:    sudo make install
#           make DESTDIR=/tmp/pkg install     # staged install for packaging
#           make PREFIX=$$HOME/.local install  # per-user install

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man/man1
COMPDIR ?= /etc/bash_completion.d
DESTDIR ?=

# Directory of this Makefile (trailing slash). Anchors source paths so
# 'make install' works regardless of invoking CWD and never picks up a
# like-named file from a parent directory.
srcdir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: all install uninstall check test help

all: help

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(srcdir)clip $(DESTDIR)$(BINDIR)/clip
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 $(srcdir)clip.1 $(DESTDIR)$(MANDIR)/clip.1
	@# Bash completion: skip gracefully when COMPDIR does not exist
	@if [ -d $(DESTDIR)$(COMPDIR) ]; then \
	  install -m 644 $(srcdir)clip.bash_completion $(DESTDIR)$(COMPDIR)/clip; \
	fi
	@if [ -z "$(DESTDIR)" ]; then $(MAKE) --no-print-directory check; fi

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/clip
	rm -f $(DESTDIR)$(MANDIR)/clip.1
	rm -f $(DESTDIR)$(COMPDIR)/clip

check:
	@command -v clip >/dev/null 2>&1 || { echo 'clip: NOT FOUND (check PATH)'; exit 1; }
	@echo 'clip: OK'
	@command -v xclip >/dev/null 2>&1 || { echo 'xclip: NOT FOUND (sudo apt install xclip)'; exit 1; }
	@echo 'xclip: OK'

test:
	cd $(srcdir)tests && ./run_tests.sh

help:
	@echo 'Usage: make [target] [VARIABLE=value ...]'
	@echo ''
	@echo 'Targets:'
	@echo '  install     Install clip, manpage and bash completion to $(PREFIX)'
	@echo '  uninstall   Remove installed files'
	@echo '  check       Verify clip and xclip are callable'
	@echo '  test        Run test suite'
	@echo '  help        Show this message'
	@echo ''
	@echo 'Variables:'
	@echo '  PREFIX      $(PREFIX)'
	@echo '  BINDIR      $(BINDIR)'
	@echo '  MANDIR      $(MANDIR)'
	@echo '  COMPDIR     $(COMPDIR)'
	@echo '  DESTDIR     $(DESTDIR)'
	@echo ''
	@echo 'Requires xclip at runtime:  sudo apt install xclip'
