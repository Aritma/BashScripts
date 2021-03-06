#!/bin/bash

WORKING_DIR=$(dirname -- $0)


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
LOG_FILE="${WORKING_DIR}/$LOG_FILE_NAME}"

# FUNCTIONS
# =========

# name_exists: Function tests if name of creature exists in database
# arg: Name of creature (String)
#
function name_exists () {
	if $(sqlite3 $DB_FILE "SELECT name FROM creatures WHERE name='$1' ;" | grep "$1" > /dev/null 2>&1);then
		return 0
	else
		return 1
	fi
}

# new_creature: Creates new creature in database with default attributes
# arg: Name of creature (String)
#
function new_creature () {
	until sqlite3 $DB_FILE "INSERT INTO creatures (name,food,health) VALUES ('$1', 10000, $(( (RANDOM%51) +100)) );"
	do
		add_log "WARNING: SQL Query cannot be processed, DB probably locked, waiting..."
		echo "DB locked, waiting..."
		sleep 1
	done
}

# get_status: Prints current status of creature.
# arg: Name of creature (String)
#
function get_status () {
	data=$(sqlite3 $DB_FILE "SELECT name,food,health,is_dead FROM creatures WHERE name='$1'")
	echo "STATUS:"
	echo "NAME: $(echo $data | cut -f1 -d'|')"
	echo "FOOD: $(echo $data | cut -f2 -d'|')"
	echo "HEALTH: $(echo $data | cut -f3 -d'|')"
	echo -n "IS DEAD: "
	if [ $(echo $data | cut -f4 -d'|') -eq 0 ];then
		echo "FALSE"
	else
		echo "TRUE"
	fi
}

# check_if_name_exists: Check if argument exists, prints defined message if not.
# args: Message to print if argument is missing
#	Any argument passed to the function 
#
check_if_argument_exists () {
	if [ -z $2 ];then
        	echo $1
		add_log "ERROR: Missing argument during request"
                exit 1
        fi
}

# add_log: Write message into the LOG_FILE_NAME file
# arg:	Log message (String)
#
function add_log () {
	echo "$(date -u +%Y-%m-%d_%H:%M:%S_%Z) $1" >> $LOG_FILE_NAME 
}


# MAIN CODE
# =========
case $1 in
	'new')
		check_if_argument_exists "ERROR: You must define creature name" "$2"
		if name_exists $2;then
			echo "ERROR: Creature name already exists"
			exit 1
		fi
		echo "CREATING $2"
		add_log "Creature $2 created in $DB_FILE_NAME"
		new_creature "$2"
		
		;;
	'status')
		check_if_argument_exists "ERROR: You must define creature name" "$2"
                if ! name_exists $2;then
                        echo "ERROR: Invalid creature name"
                        exit 1
                fi
		get_status "$2"
		add_log "Getting status of $2 from $$DB_FILE_NAME"
		;;
	'feed')
                check_if_argument_exists "ERROR: You must define creature name" "$2"
                if ! name_exists $2;then
                        echo "ERROR: Invalid creature name"
                        exit 1
                fi
		echo "FEEDING $2"
		add_log "Creature $2 feeded"
		;;
	'heal')
                check_if_argument_exists "ERROR: You must define creature name" "$2"
                if ! name_exists $2;then
                        echo "ERROR: Invalid creature name"
                        exit 1
                fi
		echo "HEALING $2"
		add_log "Creature $2 healed"
		;;
	*)
		echo "INVALID ARGUMENT!"
		echo "Valid args: new <name>, status <name>, feed <name>, heal <name>"
		;;
esac
