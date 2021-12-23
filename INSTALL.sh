#!/bin/sh

install_links() {
    source ./DICT
    if [ -n "$FILES" ]; then
	for i in `seq 1 $(echo "$FILES" | wc -w)`; do
	    file=$(echo "$FILES" | cut -d' ' -f $i)
	    loc=$(echo "$LOCATIONS" | cut -d' ' -f $i)
	    dir=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    mkdir -p "$dir"
	    ln -sf "$(pwd)/$file" "$loc"
	done
    fi
    if [ -n "$SUDO_FILES" ]; then
	for i in `seq 1 $(echo "$SUDO_FILES" | wc -w)`; do
	    file=$(echo "$SUDO_FILES" | cut -d' ' -f $i)
	    loc=$(echo "$SUDO_LOCATIONS" | cut -d' ' -f $i)
	    dir=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    sudo mkdir -p "$dir"
	    sudo ln -sf "$(pwd)/$file" "$loc"
	done
    fi
    if [ "$(type -t custom)" = "function" ]; then
	custom install
    fi
}

remove_links() {
    source ./DICT
    if [ -n "$FILES" ]; then
	for i in `seq 1 $(echo $FILES | wc -w)`; do
	    loc=$(echo "$LOCATIONS" | cut -d' ' -f $i)
	    rm "$loc" 2>/dev/null
	    loc=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    while [ -z "$(ls -A $loc)" ]; do
		rm -r "$loc"
		loc=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    done 2>/dev/null
	done
    fi
    if [ -n "$SUDO_FILES" ]; then
	for i in `seq 1 $(echo $SUDO_FILES | wc -w)`; do
	    loc=$(echo "$SUDO_LOCATIONS" | cut -d' ' -f $i)
	    sudo rm "$loc" 2>/dev/null
	    loc=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    while [ -z "ls -A $loc" ]; do
		sudo rm -r "$loc"
		loc=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    done 2>/dev/null
	done
    fi
    if [ "$(type -t custom)" = "function" ]; then
	custom remove
    fi
}

handle_package() {
    echo $1
    if [ -d "$1" ]; then
	unset DEPS
	eval $(grep "DEPS=" $1/DICT)
	for i in $DEPS; do
	    (handle_package $i $2)
	done
	(cd "$1"; $2)
    else
	echo "No configuration found for $i"
    fi
}

usage() {
    echo "Install dotfiles with symlinks"
    echo "Usage with -h|--help"
    echo "Install with -i|--install (default)"
    echo "Remove with -r|--remove"
    echo "Directories have the configurations for their programs/use cases"
    echo "List all configurations to be installed in the command line"
    echo "Example usage: $0 -i bash zsh"
}

INSTALL=1
PACKAGES=""
FUNCTION=""

while [ -n "$1" ]; do
      case "$1" in
	  -h|--help|"") usage; exit;;
	  -i|--install) INSTALL=1;;
	  -r|--remove) INSTALL=0;;
	  --) shift; break;;
	  -*) echo "Invalid argument"; usage; exit;;
	  *) handle_package "$1" "$([ \"$INSTALL\" = \"1\" ] && echo install || echo remove)_links";;
      esac
      shift
done

while [ -n "$1" ]; do
    handle_package "$1" "$([ \"$INSTALL\" = \"1\" ] && echo install || echo remove)_links"
done
