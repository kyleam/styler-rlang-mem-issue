#!/bin/sh

set -eu

usage () {
    printf >&2 'check.sh [--styler=(unreleased|revert)] <case>\n'
    exit 1
}

styler=
case "$1" in
    --styler=unreleased)
        styler=unreleased
        shift
        ;;
    --styler=revert)
        styler=revert
        shift
        ;;
    -*)
        usage
        ;;
esac

test $# = 1 || usage
case=$1

if test -n "$styler"
then
    rm /styler_1.9.1.tar.gz
    git clone https://github.com/r-lib/styler /styler
    git -C /styler checkout 8e9ac82333c2a0036a1653a029b6437008650f34

    if test "$styler" = revert
    then
        git -C /styler revert -n 99d502fcf634088f8ae4f09a17c71a7ae7a03b65
    fi

    (
        cd /
        R CMD build styler
    )
fi

NO_COLOR=1
export NO_COLOR

used_mem () {
    free -b | grep '^Mem:' | tr -s ' ' '\t' | cut -f3
}

print_mem () {
    printf '%d %d\n' "$(date '+%s')" "$(used_mem)"
}

printf >&2 'Writing used memory to %s.mem.std{out,err}\n' "$case"
printf 'time mem_used\n' >"$case".mem.stdout
:>"$case".mem.stderr
print_mem >>"$case".mem.stdout 2>>"$case".mem.stderr

printf >&2 'Writing check output to %s.check.std{out,err}\n' "$case"
Rscript /check.R >"$case".check.stdout 2>"$case".check.stderr &
while ! test -e /tmp/styler-check-done
do
    printf >&2 '.'
    print_mem >>"$case".mem.stdout 2>>"$case".mem.stderr
    sleep 5
done
printf >&2 'finished\n'
