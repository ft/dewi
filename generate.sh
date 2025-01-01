#!/bin/sh
# Copyright (c) 2010-2025
# Frank Terbeck <ft@bewatermyfriend.org>, All rights reserved.
# Terms for redistribution and use can be found in `LICENCE'.

# This identifies version 0.1; used to check if we're building from a working
# dewi git repository.
v01id='2475066cebe843978e38cdff9dd3b3a253c24c5b'

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
                printf '%s' "$prog"
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

cli_version='2014-04-06#001'
posix_sh_unres=sh
perl_unres=perl
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

is_git_repository () {
    if ! git rev-parse --is-inside-worktree > /dev/null 2>&1; then
        return 1
    fi
    thisv01=$(git log -1 --pretty=%H v0.1 2> /dev/null)
    if test "$v01id" = "$thisv01"; then
        return 0
    fi
    printf '\n  This is a git repository, but the v0.1 tag checksums do not match!\n'
    printf '     Expected: [%s]\n' "$v01id"
    printf '    Retrieved: [%s]\n' "$thisv01"
    printf '  Falling back to static version information!\n\n'
    return 1
}

get_git_version () {
    base_="$(git describe --abbrev=12)"
    [ -z "$base_" ] && base_="noversion-$(git show -s --pretty='%h')"
    dirty_=""
    git update-index -q --refresh
    [ -z "$(git diff-index --name-only HEAD --)" ] || dirty_="-dirty"
    REPLY="${base_#v}${dirty_}"
}

get_major_version () {
    REPLY="${1%%.*}"
    REPLY="${REPLY#v}"
}

get_minor_version () {
    REPLY="${1#*.}"
    REPLY="${REPLY%%-*}"
}

get_patch_level () {
    REPLY="${1#*-}"
    REPLY="${REPLY%%-*}"
}

get_git_dirty () {
    case "$1" in
    *-dirty) REPLY="dirty" ;;
    *) REPLY="clean" ;;
    esac
}

get_check_sum () {
    REPLY="$(git log -1 --pretty=%H)"
}

get_git_description () {
    REPLY=$(git show -s --pretty="%s")
}

get_git_date () {
    REPLY=$(git show -s --pretty="%ai")
    REPLY="${REPLY%% *}"
}

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

if got_perl_module "Template"; then
    perltemplate='gotit'
else
    printf '
This system does not appear to have the Template Perl module installed.
`dewi'\'' uses that module to implement `template'\'' method.\n\n'
    perltemplate='sorry, buddy.'
fi

if is_git_repository; then
    version_source="Git Repository"

    get_git_version
    full_version="v$REPLY"

    get_major_version "$full_version"
    major_version="$REPLY"

    get_minor_version "$full_version"
    minor_version="$REPLY"

    get_git_dirty "$full_version"
    work_dir_state="$REPLY"

    get_patch_level "$full_version"
    patch_level="${REPLY:-0}"

    get_check_sum
    check_sum="$REPLY"

    get_git_description
    git_description="$REPLY"

    get_git_date
    git_date="$REPLY"

    if ! test "$patch_level" = 0; then
        version_suffix='+git'
    fi

    source_source='git'

else
    version_source="VERSION File"
    . ./VERSION
    check_sum=undef
    git_description=undef
    patch_level=undef
    git_date="$release_date"
    full_version="${major_version}.${minor_version}${version_suffix}"
    work_dir_state='undef'
    source_source='tarball'
fi

printf '%s\n' "Version:"

printf '  source:         %s\n' "$version_source"
printf '  major:          %s\n' "$major_version"
printf '  minor:          %s\n' "$minor_version"
printf '  patch-level:    %s\n' "$patch_level"
printf '  version-suffix: %s\n' "$version_suffix"
printf '  work-dir-state: %s\n' "$work_dir_state"
printf '  check-sum:      %s\n' "$check_sum"
printf '  description:    %s\n' "$git_description"
printf '  date:           %s\n' "$git_date"
printf '  full-version:   %s\n' "$full_version"

printf '\n%s\n' "Configuration:"
printf '  perl:      %s\n' "$perl"
printf '  posix_sh:  %s\n' "$posix_sh"
printf '  datadir:   %s\n' "$datadir"

if [ "$ipcrun3" = 'gotit' ]; then
    printf '  IPC::Run3: found\n'
else
    printf '  IPC::Run3: not found\n'
fi

if [ "$perltemplate" = 'gotit' ]; then
    printf '  Template:  found\n'
else
    printf '  Template:  not found\n'
fi

printf '\n'

__generate() {
    "$perl" -e '
%replaces=( q{@@DATADIR@@} => q{'"$datadir"'},
            q{@@PERL5@@} => q{'"$perl"'},
            q{@@PERL5_QUOTED@@} => q{'"$perl"'},
            q{@@POSIX_SH@@} => q{'"$posix_sh"'},
            q{@@MAJOR_VERSION@@} => q{'"$major_version"'},
            q{@@MINOR_VERSION@@} => q{'"$minor_version"'},
            q{@@VERSION_SUFFIX@@} => q{'"$version_suffix"'},
            q{@@VERSION_DESCRIPTION@@} => q{'"$git_description"'},
            q{@@VERSION_DATE@@} => q{'"$git_date"'},
            q{@@VERSION_CHECKSUM@@} => q{'"$check_sum"'},
            q{@@WORK_DIR_STATE@@} => q{'"$work_dir_state"'},
            q{@@PATCH_LEVEL@@} => q{'"$patch_level"'},
            q{@@SOURCE_CODE_SOURCE@@} => q{'"$source_source"'},
            q{@@FULL_VERSION@@} => q{'"$full_version"'},
            q{@@DOC_VERSION@@} => q{'"${full_version#v}"'} );
while(<>) {
    foreach $key (keys %replaces) {
        $data = $replaces{$key};
        $data = "q{" . $data . "}" unless ($data eq "undef"
                                          || $key eq q{@@PERL5@@}
                                          || $key eq q{@@DOC_VERSION@@});
        s{$key}{$data};
    }
} continue {
    print or die "-p destination: $!\n";
}
    '
}

printf '%s\n' "Generating files:"
for file in "dewi.in" "Dewifile.in"; do
    gen_file=${file%.in}
    printf '  %s\n' "$gen_file"
    __generate < "$file" > "$gen_file"
done
chmod +x "./dewi"
for file in dewi_1.mdwn dewi_7.mdwn dewifile_5.mdwn; do
    in_file="doc/in_$file"
    file="doc/$file"
    printf '  %s\n' "$file"
    __generate < "$in_file" > "$file"
done

exit 0
