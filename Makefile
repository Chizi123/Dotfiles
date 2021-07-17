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
SHELLS = bash zsh all-shells
UTILS = emacs git aspell
FUN = mpd ncmpcpp mailcap rtv
DESKTOP = libinput-gestures reddit-wallpaper-fetcher
ARCH = paru

CONFIGS = $(SHELLS) $(UTILS) $(FUN) $(DESKTOP) $(ARCH)

all: help

.PHONY: $(CONFIGS)
$(CONFIGS):
	$(STOW) -t $(HOME) $@

.PHONY: $(CONFIGS:=-del)
$(CONFIGS:=-del):
	$(STOW) --delete -t $(HOME) $(@:-del=)

.PHONY: emacs
emacs:
	git submodule update --init
	$(STOW) -t $(HOME) $@

.PHONY: termux
termux: shells
	$(STOW) -t $(HOME) $@

.PHONY: termux-uninstall
termux-uninstall: shells-uninstall
	$(STOW) --delete -t $(HOME) $(@:-uninstall=)

.PHONY: shells
shells: $(SHELLS)

.PHONY: shells-uninstall
shells-uninstall: $(SHELLS:=-del)

.PHONY: utils
utils: $(UTILS)

.PHONY: utils-uninstall
utils-uninstall: $(UTILS:=-del)

.PHONY: fun
fun: $(FUN)

.PHONY: fun-uninstall
fun-uninstall: $(FUN:=-del)

.PHONY: desktop
desktop: $(DESKTOP)

.PHONY: desktop-uninstall
desktop-uninstall: $(DESKTOP:=-del)

.PHONY: arch
arch: $(ARCH)

.PHONY: arch-uninstall
arch-uninstall: $(ARCH:=-del)

.PHONY: $(INSTALL_TARGETS)
$(INSTALL_TARGETS): $(CONFIGS)

.PHONY: $(UNINSTALL_TARGETS)
$(UNINSTALL_TARGETS): $(CONFIGS:=-del)

.PHONY: help
help:
	$(ECHO) 'use make "target"'
	$(ECHO) 'targets:'
	$(ECHO)	'	home(-uninstall)'
	$(ECHO) '	shells(-uninstall)'
	$(ECHO) '	utils(-uninstall)'
	$(ECHO) '	fun(-uninstall)'
	$(ECHO) '	desktop(-uninstall)'
	$(ECHO) '	termux(-uninstall)'
