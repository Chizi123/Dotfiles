#!/bin/sh

install_links() {
    . ./DICT
    if [ -n "$FILES" ]; then
	for i in `seq 1 $(echo "$FILES" | wc -w)`; do
	    file=$(echo "$FILES" | cut -d' ' -f $i)
	    loc=$(echo "$LOCATIONS" | cut -d' ' -f $i)
        while [ 1 ]; do
            CHOICE="overwrite"
            if [ -a "$loc" ] && [ "$FORCE" = "0" ]; then
                echo "WARNING: \"$loc\" exists, (overwrite, change, nothing): "
                read CHOICE
            fi
            case "$CHOICE" in
                o|overwrite)
	                dir=$(dirname "$loc")
	                mkdir -p "$dir"
	                ln -sf "$(pwd)/$file" "$loc"; break;;
                c|change)
                    tmpfile=$(mktemp)
                    echo "$loc" >> $tmpfile
                    $EDITOR "$tmpfile"
                    loc=$(cat $tmpfile)
                    rm $tmpfile
                    unset tmpfile;;
                n|nothing)
                    break;;
                *)
                    echo "INVALID CHOICE \"$CHOICE\", (overwrite, change, nothing)"
                    read CHOICE
            esac
        done
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
    . ./DICT
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
    if [ "$INSTALL" = "1" ] || ([ "$INSTALL" = "0" ] && [ "$REMOVE_DEPS" = "1" ]); then
	    for i in $DEPS; do
            if ! grep -q "$i" "$PACKAGE_CACHE"; then
	            (handle_package $i)
            fi
	    done
    fi
    echo "$1" >> "$PACKAGE_CACHE"
	(cd "$1"; "$([ \"$INSTALL\" = \"1\" ] && echo install || echo remove)_links")
    else
	echo "No configuration found for $i"
    fi
}

usage() {
    echo "Install dotfiles with symlinks"
    echo "Usage with -h|--help"
    echo "Install with -i|--install (default)"
    echo "Remove with -r|--remove"
    echo "Force install with -f|--force"
    echo "Directories have the configurations for their programs/use cases"
    echo "List all configurations to be installed in the command line"
    echo "If there is a file at the install location, you will be prompted to change it"
    echo "Example usage: $0 -i bash zsh"
}

INSTALL=1
FORCE=0
REMOVE_DEPS=0
PACKAGE_CACHE=$(mktemp)
DOTFILES_PATH="$(dirname $0)"

cd $DOTFILES_PATH

if [ -z "$1" ]; then
    usage
    exit
fi

while [ -n "$1" ]; do
      case "$1" in
	  -h|--help|"") usage; exit;;
	  -i|--install) INSTALL=1;;
	  -r|--remove) INSTALL=0;;
      -d|--deps) REMOVE_DEPS=1;;
      -f|--force) FORCE=1;;
	  --) shift; break;;
	  -*) echo "Invalid argument"; usage; exit;;
	  *) handle_package "$1" "$([ \"$INSTALL\" = \"1\" ] && echo install || echo remove)_links";;
      esac
      shift
done

while [ -n "$1" ]; do
    handle_package "$1"
done

rm $PACKAGE_CACHE
