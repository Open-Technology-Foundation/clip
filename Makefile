# Makefile - Install clip
# BCS1212 compliant

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man/man1
COMPDIR ?= /etc/bash_completion.d
DESTDIR ?=

.PHONY: all install uninstall check test help

all: help

install:
	@if [ -z "$(DESTDIR)" ] && ! command -v xclip >/dev/null 2>&1; then \
	  echo 'Installing required dependency: xclip'; \
	  apt-get install -y xclip; \
	fi
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 clip $(DESTDIR)$(BINDIR)/clip
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 clip.1 $(DESTDIR)$(MANDIR)/clip.1
	@if [ -d $(DESTDIR)$(COMPDIR) ]; then \
	  install -m 644 clip.bash_completion $(DESTDIR)$(COMPDIR)/clip; \
	fi
	@if [ -z "$(DESTDIR)" ]; then $(MAKE) --no-print-directory check; fi

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/clip
	rm -f $(DESTDIR)$(MANDIR)/clip.1
	rm -f $(DESTDIR)$(COMPDIR)/clip

check:
	@command -v xclip >/dev/null 2>&1 \
	  && echo 'xclip: OK' \
	  || echo 'xclip: NOT FOUND (sudo apt install xclip)'
	@command -v clip >/dev/null 2>&1 \
	  && echo 'clip: OK' \
	  || echo 'clip: NOT FOUND (check PATH)'

test:
	./tests/run_tests.sh

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@echo '  install     Install to $(PREFIX)'
	@echo '  uninstall   Remove installed files'
	@echo '  check       Verify installation'
	@echo '  test        Run test suite'
	@echo '  help        Show this message'
	@echo ''
	@echo 'Install from GitHub:'
	@echo '  git clone https://github.com/Open-Technology-Foundation/clip.git'
	@echo '  cd clip && sudo make install'
