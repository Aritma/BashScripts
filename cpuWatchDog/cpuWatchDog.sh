#!/bin/bash

LOGFILEFINAL="$LOGFILENAME$(date +%s).$LOGFILEEXTENSION"

while [[ $(cat $ENVFILENAME | head -1) -eq 1 ]]; do
	ps aux | tail -n +2 | {
		while IFS=  read -r line; do
			if [[ $(echo "$line" | tr -s " " |  cut -f3 -d" " | cut -f1 -d".") -gt $CPULIMITPERCENT ]]; then
				user=$(echo $line | cut -f1 -d" ")
				pidVal=$(echo $line | cut -f2 -d" ")
				cpuUsage=$(echo $line | cut -f3 -d" ")
				procSource=$(echo $line | cut -f11-99 -d" ")
				#if [[ pidValue -ne $(echo $$) ]]; then
					echo "-------------------------------------" >> $LOGSAVEDIRECTORY/$LOGFILEFINAL
					echo "TIMESTAMP: $(date +%Y/%m/%d-%H:%M:%S)" >> $LOGSAVEDIRECTORY/$LOGFILEFINAL
					echo "USER: $user" >> $LOGSAVEDIRECTORY/$LOGFILEFINAL
					echo "PID: $pidVal" >> $LOGSAVEDIRECTORY/$LOGFILEFINAL
					echo "CPU: $cpuUsage" >> $LOGSAVEDIRECTORY/$LOGFILEFINAL
					echo "SOURCE: $procSource" >> $LOGSAVEDIRECTORY/$LOGFILEFINAL
				#fi
			fi
		done
	}
	for i in $(seq 1 $SAMPLETIMESECONDS); do
		[[ $(cat $ENVFILENAME | head -1) -eq 1 ]] && sleep 1 || break
	done
done
if [[ -f $ENVFILENAME ]]; then
	rm $ENVFILENAME 2> /dev/null
fi
