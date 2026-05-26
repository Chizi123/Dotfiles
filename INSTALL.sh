#!/bin/sh
set -e

install_conflict() {
    file="$1";
    loc="$2";
    if [ -n "$3" ]; then
        SUPERUSER="sudo"
    else
        SUPERUSER="";
    fi
    while true; do
        CHOICE="overwrite"
        if [ -e "$loc" ] && [ "$FORCE" = "0" ] && ! diff -q "$loc" "$file" >/dev/null 2>&1; then
            echo "WARNING: \"$loc\" exists, (overwrite, change, nothing): "
            read -r CHOICE
        fi
        case "$CHOICE" in
            o|overwrite)
	            dir=$(dirname "$loc")
	            $SUPERUSER mkdir -p "$dir"
	            $SUPERUSER ln -sf "$DOTFILES_PATH/$file" "$loc"; break;;
            c|change)
                tmpfile=$(mktemp)
                echo "$loc" >> "$tmpfile"
                "${EDITOR:-vi}" "$tmpfile"
                loc=$(cat "$tmpfile")
                rm "$tmpfile"
                unset tmpfile;;
            n|nothing)
                break;;
            *)
                echo "INVALID CHOICE \"$CHOICE\", (overwrite, change, nothing)"
                read -r CHOICE
        esac
    done

}

install_links() {
    . ./DICT
    if [ -n "$FILES" ]; then
	for i in $(seq 1 "$(echo "$FILES" | wc -w)"); do
	    file=$(echo "$FILES" | cut -d' ' -f "$i")
	    loc=$(echo "$LOCATIONS" | cut -d' ' -f "$i")
        install_conflict "$file" "$loc"
	done
    fi
    if [ -n "$SUDO_FILES" ]; then
	    for i in $(seq 1 "$(echo "$SUDO_FILES" | wc -w)"); do
	        file=$(echo "$SUDO_FILES" | cut -d' ' -f "$i")
	        loc=$(echo "$SUDO_LOCATIONS" | cut -d' ' -f "$i")
            install_conflict "$file" "$loc" 1
	    done
    fi
    if command -v custom >/dev/null 2>&1; then
	    custom install
    fi
}

remove_links() {
    . ./DICT
    if [ -n "$FILES" ]; then
	for i in $(seq 1 "$(echo "$FILES" | wc -w)"); do
	    loc=$(echo "$LOCATIONS" | cut -d' ' -f "$i")
	    rm -f "$loc" 2>/dev/null || true
	    loc=$(dirname "$loc")
	    while [ -z "$(ls -A "$loc")" ]; do
		rm -rf "$loc" 2>/dev/null || true
		loc=$(dirname "$loc")
	    done 2>/dev/null
	done
    fi
    if [ -n "$SUDO_FILES" ]; then
	for i in $(seq 1 "$(echo "$SUDO_FILES" | wc -w)"); do
	    loc=$(echo "$SUDO_LOCATIONS" | cut -d' ' -f "$i")
	    sudo rm -f "$loc" 2>/dev/null || true
	    loc=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    while [ -z "$(ls -A "$loc")" ]; do
		sudo rm -rf "$loc" 2>/dev/null || true
		loc=$(echo "$loc" | rev | cut -d'/' -f2- | rev)
	    done 2>/dev/null
	done
    fi
    if command -v custom >/dev/null 2>&1; then
	    custom remove
    fi
}

handle_package() {
    if [ -d "$1" ]; then
	. "$1/DICT"
    if ! [ "$INSTALL" = "0" ] && [ "$REMOVE_DEPS" = "0" ]; then
	    for dep in $DEPS; do
            if ! grep -q "$dep" "$PACKAGE_CACHE"; then
	            (handle_package "$dep")
            fi
	    done
    fi
    echo "$1"
    echo "$1" >> "$PACKAGE_CACHE"
	(cd "$1" && "${action}_links")
    else
	echo "No configuration found for $1"
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
action=install
FORCE=0
REMOVE_DEPS=0
PACKAGE_CACHE="$(mktemp)"
trap 'rm -f "$PACKAGE_CACHE"' EXIT INT TERM HUP
DOTFILES_PATH="$(cd "$(dirname "$0")" && pwd)"

cd "$DOTFILES_PATH"

if [ -z "$1" ]; then
    usage
    exit
fi

while [ -n "$1" ]; do
      case "$1" in
	  -h|--help|"") usage; exit;;
	  -i|--install) INSTALL=1; action=install; FORCE=0;;
      -f|--force) FORCE=1;;
      -if|-fi) INSTALL=1; action=install; FORCE=1;;
	  -r|--remove) INSTALL=0; action=remove; REMOVE_DEPS=0;;
      -d|--deps) REMOVE_DEPS=1;;
      -rd|-dr) INSTALL=0; action=remove; REMOVE_DEPS=1;;
	  --) shift; break;;
	  -*) echo "Invalid argument"; usage; exit;;
	  *) handle_package "$1";; # "$([ \"$INSTALL\" = \"1\" ] && echo install || echo remove)_links";;
      esac
      shift
done

while [ -n "$1" ]; do
    handle_package "$1"
done


