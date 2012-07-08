#!/bin/sh

file=$HOME/.concatenate/config

[ -f "$file" ] || exit 1

diff=$(diff cat.expected "$file" | wc -l)

[ "$diff" = 0 ] || exit 1

exit 0
