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

cp lib/parent.mk "$basedir"/Makefile
