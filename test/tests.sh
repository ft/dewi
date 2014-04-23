#!/bin/sh

RT=$PWD/..
dewi=$RT/dewi

export dewi

cd etc || exit 1

if ! [ -z "$DEWI_TESTS" ]; then
    tests="$DEWI_TESTS"
else
    for i in */; do
        d=${i%/}
        tests="$tests $d"
    done
fi

for t in $tests; do
    sh ../run_test.sh "$t" || exit 1
done

exit 0
