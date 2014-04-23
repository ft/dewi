#!/bin/sh

TEST=$1
HOME=$PWD/../home
export HOME

cd "$TEST" || exit 1

"$dewi" deploy || exit 1
if [ -f verify.deploy.sh ]; then
    printf 'run_test.sh: Verifying deployment...\n'
    sh verify.deploy.sh || exit 1
fi

"$dewi" withdraw || exit 1
if [ -f verify.withdraw.sh ]; then
    printf 'run_test.sh: Verifying withdrawal...\n'
    sh verify.withdraw.sh || exit 1
fi

exit 0
