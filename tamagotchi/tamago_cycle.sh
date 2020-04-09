#!/bin/bash

WORKING_DIR=$(dirname -- $0)
STATE_FILE=${WORKING_DIR}/.tamago_state

# Config load
CONFIG_FILE_PATH="${WORKING_DIR}/tamago.cfg"
if [ -f $CONFIG_FILE_PATH ];then
	source $CONFIG_FILE_PATH
else
	echo "Config file $CONFIG_FILE_PATH missing..."
	exit 1
fi


# VARIABLES
# =========
DB_FILE="${WORKING_DIR}/${DB_FILE_NAME}"
LOG_FILE="${WORKING_DIR}/${LOG_FILE_NAME}"

# FUNCTIONS
# =========

# add_log: Write message into the LOG_FILE_NAME file
# arg:  Log message (String)
#
function add_log () {
        echo "$(date -u +%Y-%m-%d_%H:%M:%S_%Z) $1" >> $LOG_FILE
}

# check_end: Checks STATE_FILE for number 0, is found, script ends
# 	     Also checks if STATE_FILE exists, if missing, script ends
# args: None
#
check_end () {
	if [ -r $STATE_FILE ];then
		if [ $(head -1 $STATE_FILE) -eq 0 ];then
			add_log "INFO: EXITING on user request..."
			exit 0
		fi
	else
		add_log "ERROR: File $STATE_FILE missing..."
		exit 1
	fi
}

function reduce_food () {
	until sqlite3 $DB_FILE "UPDATE creatures SET food=food-$FOOD_REDUCE_AMOUNT where food>0 AND is_dead=0;"
	do
		add_log "WARNING: SQL Query cannot be processed, DB probably locked, waiting..."
		sleep 1
	done
	add_log "INFO: Food reduced..."
}

function reduce_health () {
	until sqlite3 $DB_FILE "UPDATE creatures SET health=health-$HEALTH_REDUCE_AMOUNT where food<=0 AND health>0 AND is_dead=0;"
        do
		add_log "WARNING: SQL Query cannot be processed, DB probably locked, waiting..."
                sleep 1
        done
	add_log "INFO: Health reduces..."
}

function set_dead () {
	until sqlite3 $DB_FILE "UPDATE creatures SET is_dead=1 WHERE health<=0;"
        do
		add_log "WARNING: SQL Query cannot be processed, DB probably locked, waiting..."
                sleep 1
        done
	add_log "INFO: Killed who should be dead..."
}


# MAIN CODE
echo 1 > $STATE_FILE
add_log "INFO: Initiating tamago_cycle..."

while true;do
	reduce_food
	reduce_health
	set_dead

	for i in $(seq 1 $SLEEP_TIME);do
		check_end
		sleep 1
	done
done
