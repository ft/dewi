#!/bin/sh
# Copyright (c) 2010-2016
# Frank Terbeck <ft@bewatermyfriend.org>, All rights reserved.
# Terms for redistribution and use can be found in `LICENCE'.

prefix="/usr/local"
datadir="${prefix}/share/dewi"
mandir="${prefix}/share/man"
docdir="${prefix}/share/doc/dewi"

while [ $# -gt 0 ]; do
    case "$1" in
        prefix=*)
            prefix=${1#prefix=}
            ;;
        datadir=*)
            datadir=${1#datadir=}
            ;;
        docdir=*)
            docdir=${1#docdir=}
            ;;
        mandir=*)
            mandir=${1#mandir=}
            ;;
        all-but-doc) break ;;
        doc) break ;;
        uninstall) break ;;
        *)
            printf 'unknown parameter: `%s'\''\n' "$1"
            exit 1
            ;;
    esac
    shift
done

__mkdir() {
    printf 'mkdir "%s"\n' "$1"
    mkdir -p "$1" || exit 1
    chmod 755 "$1" || exit 1
}

__copy() {
    printf 'copy "%s" "%s"\n' "$1" "$2"
    cp "$1" "$2" || exit 1
    chmod 644 "$2" || exit 1
}

__copy_x() {
    printf 'copy_x "%s" "%s"\n' "$1" "$2"
    cp "$1" "$2" || exit 1
    chmod 755 "$2" || exit 1
}

__remove_old() {
    for dir in "${docdir}" "${datadir}"; do
        if [ -d "$dir" ]; then
            rm -R "$dir" || exit 1
        fi
    done
}

__create_dirs() {
    [ ! -d "${prefix}" ] && __mkdir "${prefix}"
    [ ! -d "${prefix}/bin" ] && __mkdir "${prefix}/bin"
    [ ! -d "${prefix}/share" ] && __mkdir "${prefix}/share"
    [ ! -d "${mandir}" ] && __mkdir "${mandir}"
    [ ! -d "${mandir}/man1" ] && __mkdir "${mandir}/man1"
    [ ! -d "${mandir}/man5" ] && __mkdir "${mandir}/man5"
    [ ! -d "${mandir}/man7" ] && __mkdir "${mandir}/man7"
    [ ! -d "${docdir}" ] && __mkdir "${docdir}"
    [ ! -d "${datadir}" ] && __mkdir "${datadir}"
}

__install_tool() {
    __copy_x dewi "${prefix}/bin/dewi"
}

__install_datadir() {
    __copy Dewifile "${datadir}/Dewifile"
}

__install_man() {
    __copy "doc/dewi.1" "${mandir}/man1/dewi.1"
    __copy "doc/dewi.7" "${mandir}/man7/dewi.7"
    __copy "doc/dewifile.5" "${mandir}/man5/dewifile.5"
}

__install_html() {
    __copy "doc/dewiprogram.html" "${docdir}/dewiprogram.html"
    __copy "doc/dewimanual.html" "${docdir}/dewimanual.html"
    __copy "doc/dewifile.html" "${docdir}/dewifile.html"
}

__install_pdf() {
    __copy "doc/dewiprogram.pdf" "${docdir}/dewiprogram.pdf"
    __copy "doc/dewimanual.pdf" "${docdir}/dewimanual.pdf"
    __copy "doc/dewifile.pdf" "${docdir}/dewifile.pdf"
}

__install_doc() {
    __copy "README" "${docdir}/README"
    __copy "LICENCE" "${docdir}/LICENCE"
    __copy "CHANGES" "${docdir}/CHANGES"
    __copy "UPGRADING" "${docdir}/UPGRADING"
}

umask 022
case "$1" in
    all-but-doc)
        __remove_old
        __create_dirs
        __install_datadir
        __install_tool
        ;;
    doc)
        __create_dirs
        __install_man
        __install_doc
        __install_html
        __install_pdf
        ;;
    uninstall)
        __remove_old
        rm -f "${prefix}/bin/dewi" || exit 1
        rm -f "${mandir}/man1/dewi.1" || exit 1
        rm -f "${mandir}/man5/dewifile.5" || exit 1
        rm -f "${mandir}/man7/dewi.7" || exit 1
        ;;
    *)
        printf 'Install what? "all-but-doc" or "doc"?\n'
        exit 1
        ;;
esac

exit 0
