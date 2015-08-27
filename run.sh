#!/usr/bin/env bash

get_pids() {
	ps aux | grep $1 | perl -nE 'unless (/grep/) { print "$1 " if /^[^\s]*\s+(\d+)\b/ }'
}

kill_like() {
	for pid in `get_pids $1`; do
		kill $pid
	done
}

kill_like dzen2
kill_like subscribe
kill_like status.py

#WIDTH=1366
WIDTH=1920
HEIGHT=15
FONT_SIZE=9
FONT="Dejavu Sans Mono"
# Hack for status.py, this font size looks good
let "REAL_FONT_SIZE = $FONT_SIZE - 2"
DATE=/tmp/dzen/date_pipe
BATT=/tmp/dzen/batt_pipe
BSPWM=/tmp/dzen/bspwm_pipe

run_widget() {
    kill_like $2
    mkfifo $1
    $2 >$1 &
}

mkdir -p /tmp/dzen

mkfifo $BSPWM
(bspc control --subscribe | ~/bin/bspwm_log_to_dzen.pl) >$BSPWM &
run_widget $DATE ./date.sh
run_widget $BATT ./batt.sh

./status.py format.txt $WIDTH $REAL_FONT_SIZE | dzen2 -h $HEIGHT -w $WIDTH -ta l -fn "$FONT-$FONT_SIZE"
kill $(jobs -p)
