#!/bin/sh

set -eu

test $# = 1 || {
    printf >&2 'requires one argument, the case label\n'
    exit 1
}
case=$1

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
