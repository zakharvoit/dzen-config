#!/usr/bin/env bash

last=""
while true; do
    title="`gpmdp-remote artist` - `gpmdp-remote title`"
    total=`gpmdp-remote time_total`
    current=`gpmdp-remote time_current`
    if [[ $total -ne 0 ]]; then
        if [[ $title != $last ]]; then
            twmnc -t "Now playing" -c "$title"
        fi
        last=$title
        let "percent=100*$current/$total"
        echo "$title $percent%"
    else
        echo "No song"
    fi
    sleep 2
done
