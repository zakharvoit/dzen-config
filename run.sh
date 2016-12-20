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
kill_like status.py

START=0
#START=1366
#WIDTH=1920
WIDTH=1366
HEIGHT=15
FONT_SIZE=9
FONT="Dejavu Sans Mono"
# Hack for status.py, this font size looks good
let "REAL_FONT_SIZE = $FONT_SIZE - 2"
DATE=/tmp/dzen/date_pipe
BATT=/tmp/dzen/batt_pipe
GMUSIC=/tmp/dzen/gmusic_pipe
XMONAD=/tmp/dzen/xmonad_pipe

init_fifo() {
    rm -f $1
    mkfifo $1
}

run_widget() {
    kill_like $2
    init_fifo $1
    $2 >$1 &
}

mkdir -p /tmp/dzen

run_widget $XMONAD ./xmonad.sh
run_widget $DATE ./date.sh
run_widget $BATT ./batt.sh
run_widget $GMUSIC ./gmusic.sh

./status.py format.txt $WIDTH $REAL_FONT_SIZE | dzen2 -x $START -w $WIDTH -h $HEIGHT -ta l -fn "$FONT-$FONT_SIZE"
kill $(jobs -p)
