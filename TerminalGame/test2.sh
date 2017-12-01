#!/bin/bash
#SAVE VARIABLES IN CONFIG FILE
PROFILEPATH="./profile.conf"
AI="Diri"
TEST="repaired"

function getVar {
	if [[ -f $PROFILEPATH ]]; then
		if [[ $(grep "^$1|" $PROFILEPATH) ]]; then
			eval "$1=$(grep "^$1|" $PROFILEPATH | cut -f2 -d"|")"
		else
			echo "ERROR: Value $1 does not exist"
		fi
	else
		echo "Error: $PROFILEPATH file is missing"
	fi
}

function setVar {
	if [[ -f $PROFILEPATH ]]; then
		if [[ $(grep "^$1|" $PROFILEPATH) ]]; then
			sed -i.bak "s/^$1|.*$/$1|${!1}/" $PROFILEPATH
		else
			echo "$1|${!1}" >> $PROFILEPATH
		fi
	else
		echo "WARNING: $PROFILEPATH file is missing. Creating new file."
		touch $PROFILEPATH
		echo "$1|${!1}" >> $PROFILEPATH
	fi
}

function checkVar {
	if [[ -f $PROFILEPATH && $(grep "^$1|" $PROFILEPATH) ]]; then
		return true
	else
		return false
	fi
}

setVar TEST
