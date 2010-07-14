#!/bin/sh
# Copyright (c) 2010
# Frank Terbeck <ft@bewatermyfriend.org>, All rights reserved.
# Terms for redistribution and use can be found in `LICENCE'.

die() {
    printf '%s\n' "$1"
    exit 1
}

find_binary() {
    prog="$1"
    [ -z "$prog" ] && return 1

    case "$prog" in
        /*)
            if [ -x "$prog" ]; then
                printf '%s' "$dir/$prog"
                return 0
            fi
            ;;
    esac

    ret=1
    oifs="$IFS"
    IFS=:
    for dir in $PATH; do
        [ -z "$dir" ] && continue
        if [ -x "$dir/$prog" ]; then
            printf '%s' "$dir/$prog"
            ret=0
            break
        fi
    done

    IFS="$oifs"
    unset oifs
    return "$ret"
}

resolv_path() {
    [ -d "$1" ] || return 1
    (
        cd "$1" || exit 1
        printf '%s' "$(pwd)"
        exit 0
    )
    return $?
}

__is_dewified() {
    [ -e "$1"/Dewifile ] && [ -e "$1"/Makefile ] && return 0
    return 1
}
