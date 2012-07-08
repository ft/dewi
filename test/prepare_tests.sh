#!/bin/sh

RT=$PWD/..
dewi=$RT/dewi

mkdir -p home || exit 1

HOME=$PWD/home
export HOME

cd etc || exit 1

"$dewi" init || exit 1

cp ../config.perl .dewi/config.perl || exit 1

for i in */; do
    d=${i%/}
    d=${d##*/}
    "$dewi" add "$d" || exit 1
done

for i in ../Dewifile.*; do
    d=${i##*.}
    cp "$i" $d/Dewifile || exit 1
done
