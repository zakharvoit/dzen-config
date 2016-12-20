#!/usr/bin/env bash

update_freq=10
percents_to_notify=10
max_timeout=10
timeout=$max_timeout
while true; do
    percents=`acpi | cut -d ' ' -f 4`
    percents=${percents%%\%,}
    left=`acpi | cut -d ' ' -f 5`
    status=`acpi | cut -d ' ' -f 3`
    if [[ $status =~ ^Charging ]]; then
        status="(AC) "
    else
        status=""
    fi
    echo -n "${status}$percents%"
    if [[ $status == "" ]]; then
        echo " $left left"
        if [[ $percents -lt $percents_to_notify ]]; then
            # Do not spam too much
            if [[ $timeout -lt $max_timeout ]]; then
                let "timeout++"
            else
                twmnc -t "Battery" -c "Your battery is only $percents%, $left left"
                timeout=$max_timeout
            fi
        fi
    else
        echo
    fi
    sleep $update_freq
done
