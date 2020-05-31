# Targets for install, can be useful to differentiate between user and headless systems
TARGETS = home

ifeq ($(VERBOSE),1)
	Q =
else
	Q = @
endif

# Commands for operation
MKDIR = $(Q)mkdir -p
STOW  = $(Q)stow
SSTOW = $(Q)sudo stow
ECHO  = @echo

INSTALL_TARGETS   = $(TARGETS)
UNINSTALL_TARGETS = $(TARGETS:=-uninstall)

# List of all applications with stored dotfiles
CONFIGS = aspell emacs git libinput-gestures mailcap mpd ncmpcpp rtv shells wallpaper-reddit zsh

all: help

.PHONY: $(CONFIGS)
$(CONFIGS):
	$(STOW) -t $(HOME) $@

.PHONY: $(CONFIGS:=-del)
$(CONFIGS:=-del):
	$(STOW) --delete -t $(HOME) $(@:-del=)

.PHONY: $(INSTALL_TARGETS)
$(INSTALL_TARGETS): $(CONFIGS)

.PHONY: $(UNINSTALL_TARGETS)
$(UNINSTALL_TARGETS): $(CONFIGS:=-del)

.PHONY: help
help:
	$(ECHO) 'use make "target"'
	$(ECHO) 'targets:'
	$(ECHO)	'	home(-uninstall)'
