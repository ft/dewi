#!/bin/sh

RT=$PWD/..
dewi=$RT/dewi

mkdir -p home || exit 1

HOME=$PWD/home
export HOME

cd etc || exit 1

test -d .dewi && rm -Rf .dewi
"$dewi" init || exit 1
cp ../Dewifile .dewi/Dewifile || exit 1

for i in */; do
    d=${i%/}
    d=${d##*/}
    rm -f ./"$d"/Dewifile
    "$dewi" init "$d" || exit 1
done

for i in ../Dewifile.*; do
    d=${i##*.}
    cp "$i" $d/Dewifile || exit 1
done
