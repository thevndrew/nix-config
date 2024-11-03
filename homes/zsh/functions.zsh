#!/usr/bin/env bash
n () {
    if [ -n $NNNLVL ] && [ "$NNNLVL" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    export NNN_TMPFILE="$HOME/.config/nnn/.lastd"

    nnn -adeHo "$@"

    if [ -f "$NNN_TMPFILE" ]; then
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

take () {
    mkdir -p "$1" && cd "$1"
}

ttake () {
    cd $(mktemp -d)
}

show_path () {
    echo $PATH | tr ':' '\n'
}

