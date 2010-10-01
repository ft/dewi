#!/bin/sh
# Copyright (c) 2010
# Frank Terbeck <ft@bewatermyfriend.org>, All rights reserved.
# Terms for redistribution and use can be found in `LICENCE'.

. ./lib/shell.sh

posix_sh_unres=sh
perl_unres=perl
make_unres=make
data_unres=.

mode=
__set_mode() {
    if [ x"${mode}" != x ]; then
        printf 'mode already set to `%s'\''\n' "${mode}"
        exit 1
    fi
    mode="$1"
}

while [ $# -gt 0 ]; do
    case "$1" in
        sh=*)
            posix_sh_unres=${1#sh=}
            ;;
        perl=*)
            perl_unres=${1#perl=}
            ;;
        make=*)
            make_unres=${1#make=}
            ;;
        data=*)
            data_unres=${1#data=}
            ;;
        here)
            __set_mode here
            ;;
        sys)
            __set_mode sys
            ;;
        *)
            printf 'unknown parameter: `%s'\''\n' "$1"
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

got_perl_module() {
    perl -e 'eval {require '"$1"';}; if ($@) { exit 1; } else { exit 0;}'
}

make=$(find_binary "$make_unres")
die_not_found "$?" make "$make_unres"
posix_sh=$(find_binary "$posix_sh_unres")
die_not_found "$?" posix_sh "$posix_sh_unres"
perl=$(find_binary "$perl_unres")
die_not_found "$?" perl "$perl_unres"

case "$data_unres" in
    /*)
        datadir="$data_unres"
        ;;
    *)
        datadir=$(resolv_path "$data_unres")
        die_not_found "$?" datadir "$data_unres"
        ;;
esac

if got_perl_module "IPC::Run3"; then
    ipcrun3='gotit'
else
    printf '
This system does not appear to have the IPC::Run3 Perl module installed.
`dewi'\'' uses that module to implement external filter functionality.\n\n'
    ipcrun3='sorry, buddy.'
fi

printf '%s\n' "Configuration:"
printf '  make:      %s\n' "$make"
printf '  perl:      %s\n' "$perl"
printf '  posix_sh:  %s\n' "$posix_sh"
printf '  datadir:   %s\n' "$datadir"
if [ "$ipcrun3" = 'gotit' ]; then
    printf '  IPC::Run3: found\n'
else
    printf '  IPC::Run3: not found\n'
fi
printf '\n'

__generate() {
    "$perl" -npe '
        s!\@\@DATADIR\@\@!'"$datadir"'!;
        s!\@\@BIN_MAKE\@\@!'"$make"'!;
        s!\@\@PERL5\@\@!'"$perl"'!;
        s!\@\@POSIX_SH\@\@!'"$posix_sh"'!;
    '
}

printf '%s\n' "Generating files:"
for file in "dewi.in" bin/*."in" lib/*."in"; do
    gen_file=${file%.in}
    printf '  %s\n' "$gen_file"
    __generate < "$file" > "$gen_file"
done
chmod +x "./dewi"

exit 0
