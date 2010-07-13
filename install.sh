#!/bin/sh
# Copyright (c) 2010
# Frank Terbeck <ft@bewatermyfriend.org>, All rights reserved.
# Terms for redistribution and use can be found in `LICENCE'.

. ./lib/shell.sh
if [ ! -r ./lib/genshell.sh ]; then
    die 'Please run generate.sh first. See README for details.'
    exit 1
fi
. ./lib/genshell.sh

fail=0

__install() {
    printf '  %s\n' "$2"
    if ! [ "$1" -nt "$2" ]; then
        printf '    INFO: ...not older than %s.\n' "$1"
        printf '    INFO: Forgot to run `generate.sh'\''?\n'
    fi
    cp -- "$1" "$2" || fail=1
}

printf 'Installing...\n'
__install lib/parent.mk "$basedir"/Makefile

if [ "$fail" != "0" ]; then
    printf '\n !!! WARNING !!!\n'
    printf ' Encountered at least one problem during installation!\n'
fi
exit "$fail"
