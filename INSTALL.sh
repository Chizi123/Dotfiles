#!/bin/sh

install_links() {
    . ./DICT
    if [ -n "$FILES" ]; then
	for i in $(seq 1 "$(echo "$FILES" | wc -w)"); do
	    file=$(echo "$FILES" | cut -d' ' -f "$i")
	    loc=$(echo "$LOCATIONS" | cut -d' ' -f "$i")
        while true; do
            CHOICE="overwrite"
            if [ -e "$loc" ] && [ "$FORCE" = "0" ]; then
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
                    echo "$loc" >> "$tmpfile"
                    $EDITOR "$tmpfile"
                    loc=$(cat "$tmpfile")
                    rm "$tmpfile"
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
	for i in $(seq 1 "$(echo "$SUDO_FILES" | wc -w)"); do
	    file=$(echo "$SUDO_FILES" | cut -d' ' -f "$i")
	    loc=$(echo "$SUDO_LOCATIONS" | cut -d' ' -f "$i")
	    dir=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    sudo mkdir -p "$dir"
	    sudo ln -sf "$(pwd)/$file" "$loc"
	done
    fi
    if type custom | grep -q "function" ; then
	    custom install
    fi
}

remove_links() {
    . ./DICT
    if [ -n "$FILES" ]; then
	for i in $(seq 1 "$(echo "$FILES" | wc -w)"); do
	    loc=$(echo "$LOCATIONS" | cut -d' ' -f "$i")
	    rm "$loc" 2>/dev/null
	    loc=$(dirname "$loc")
	    while [ -z "$(ls -A "$loc")" ]; do
		rm -r "$loc"
		loc=$(dirname "$loc")
	    done 2>/dev/null
	done
    fi
    if [ -n "$SUDO_FILES" ]; then
	for i in $(seq 1 "$(echo "$SUDO_FILES" | wc -w)"); do
	    loc=$(echo "$SUDO_LOCATIONS" | cut -d' ' -f "$i")
	    sudo rm "$loc" 2>/dev/null
	    loc=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    while [ -z "$(ls -A "$loc")" ]; do
		sudo rm -r "$loc"
		loc=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    done 2>/dev/null
	done
    fi
    if type custom | grep -q "function"; then
	    custom remove
    fi
}

handle_package() {
    echo "$1"
    if [ -d "$1" ]; then
	unset DEPS
	eval "$(grep "DEPS=" "$1/DICT")"
    if ! [ "$INSTALL" = "0" ] && [ "$REMOVE_DEPS" = "0" ]; then
	    for i in $DEPS; do
            if ! grep -q "$i" "$PACKAGE_CACHE"; then
	            (handle_package "$i")
            fi
	    done
    fi
    echo "$1" >> "$PACKAGE_CACHE"
	(cd "$1" || exit; "$([ "$INSTALL" = "1" ] && echo install || echo remove)_links")
    else
	echo "No configuration found for $i"
    fi
}

usage() {
    cat << EOF
USAGE
    $(basename "$0") [options] configs... ([option] [configs])...

OPTIONS
    -h, --help          Display this help message
    -i, --install       Install packages following this flag (default)
    -r, --remove        Remove packages following this flag
    -f, --force         Force install all packages following this flag
EOF
}

INSTALL=1
FORCE=0
REMOVE_DEPS=0
PACKAGE_CACHE="$(mktemp)"
DOTFILES_PATH="$(dirname "$0")"

cd "$DOTFILES_PATH" || exit

if [ -z "$1" ]; then
    usage
    exit
fi

while [ -n "$1" ]; do
      case "$1" in
	  -h|--help|"") usage; exit;;
	  -i|--install) INSTALL=1; FORCE=0;;
      -f|--force) FORCE=1;;
      -if|-fi) INSTALL=1; FORCE=1;;
	  -r|--remove) INSTALL=0; REMOVE_DEPS=0;;
      -d|--deps) REMOVE_DEPS=1;;
      -rd|-dr) INSTALL=0; REMOVE_DEPS=1;;
	  --) shift; break;;
	  -*) echo "Invalid argument"; usage; exit;;
	  *) handle_package "$1";; # "$([ \"$INSTALL\" = \"1\" ] && echo install || echo remove)_links";;
      esac
      shift
done

while [ -n "$1" ]; do
    handle_package "$1"
done

rm "$PACKAGE_CACHE"
