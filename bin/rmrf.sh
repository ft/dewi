#!/bin/sh
# Copyright (c) 2010-2011
# Frank Terbeck <ft@bewatermyfriend.org>, All rights reserved.
# Terms for redistribution and use can be found in `LICENCE'.

set +x
rc=0
for i in "$@"; do
    command rm -Rf "$i" || rc=1
done
exit "$rc"
