#!/bin/sh
# Copyright (c) 2010
# Frank Terbeck <ft@bewatermyfriend.org>, All rights reserved.
# Terms for redistribution and use can be found in `LICENCE'.

. ./lib/shell.sh

basedir_unres=..
posix_sh_unres=sh
perl_unres=perl

while [ $# -gt 0 ]; do
    case "$1" in
        sh=*)
            posix_sh_unres=${1#sh=}
            ;;
        perl=*)
            perl_unres=${1#perl=}
            ;;
        basedir=*)
            basedir_unres=${1#basedir=}
            ;;
        *)
            printf 'unknown parameter: `%s'\''\n' "$1"
            printf 'See the `README'\'' file for details.\n'
            exit 1
            ;;
    esac
    shift
done

die_not_found() {
    rv=$1
    name=$2
    unres_value=$3

    [ "$rv" = 0 ] && return 0
    die '`'"$name"\'' not found: '"$unres_value"
    # does not return
}

basedir=$(resolv_path "$basedir_unres")
die_not_found "$?" basedir "$basedir_unres"
posix_sh=$(find_binary "$posix_sh_unres")
die_not_found "$?" posix_sh "$posix_sh_unres"
perl=$(find_binary "$perl_unres")
die_not_found "$?" perl "$perl_unres"
bindir=$(resolv_path "./bin")
die_not_found "$?" bindir "./bin"
libdir=$(resolv_path "./lib")
die_not_found "$?" libdir "./lib"

printf '%s\n' "Configuration:"
printf '  perl:     %s\n' "$perl"
printf '  posix_sh: %s\n' "$posix_sh"
printf '  basedir:  %s\n' "$basedir"
printf '%s\n' "dewi locations:"
printf '  bindir:   %s\n' "$bindir"
printf '  libdir:   %s\n' "$libdir"

__generate() {
    "$perl" -npe '
        s!\@\@BASEDIR\@\@!'"$basedir"'!;
        s!\@\@BINDIR\@\@!'"$bindir"'!;
        s!\@\@LIBDIR\@\@!'"$libdir"'!;
        s!\@\@PERL5\@\@!'"$perl"'!;
        s!\@\@POSIX_SH\@\@!'"$posix_sh"'!;
    '
}

printf '%s\n' "Generating files:"
for file in "$bindir"/*."in" "$libdir"/*."in"; do
    gen_file=${file%.in}
    printf '  %s\n' "$gen_file"
    __generate < "$file" > "$gen_file"
done
