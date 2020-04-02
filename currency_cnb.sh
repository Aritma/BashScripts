#!/bin/bash
# Script downloads data from CNB (en) and prints differences in currency value over time.
# Two agruments can be passed:
# get - downloads data (can be set as a crontab job with some modifications)
# print - prints formated table with currency values


#===== CONSTANTS =====
DATAFILE=datafile.cur
ADDR='https://www.cnb.cz/en/financial-markets/foreign-exchange-market/central-bank-exchange-rate-fixing/central-bank-exchange-rate-fixing/daily.txt'

# ARROWS
UP='▲'
DOWN='▼'
NONE='◆'

# COLORS
DEFAULT='\e[39m'
RED='\e[91m'
GREEN='\e[92m'
YELLOW='\e[93m'
GREY='\e[90m'

# ARROWS WITH COLORS
UPARROW="${GREEN}${UP}${DEFAULT}"
DOWNARROW="${RED}${DOWN}${DEFAULT}"
NONEARROW="${YELLOW}${NONE}${DEFAULT}"

touch $DATAFILE

#===== FUNCTIONS =====
function convert_time () {
    echo "$(( $1 / 3600 )) hrs $(( ( $1  % 3600 )  / 60 )) min $(( $1 % 60 )) sec"
}

function get_data () {
	if [[ ! -s $DATAFILE ]];then
		echo "TIMESTAMP|$(date +%s)|$(date +%s)" >> $DATAFILE
	else
		sed -i "1s/$/|$(date +%s)/" $DATAFILE
	fi

	curl -s $ADDR | tail -n +3 | while read line;do
		val=$(echo $line | cut -f4 -d'|')
		linenum=$(grep -n $val $DATAFILE | cut -f1 -d:)

		if [[ -z $linenum ]];then
			echo "${line}|$(echo $line | cut -f5 -d'|')" >> $DATAFILE
		else
			sed -i "${linenum}s/$/|$(echo $line | cut -f5 -d'|')/" $DATAFILE
		fi
	done
}

function print_data () {
	last_timestamp=$(head -1 $DATAFILE | rev | cut -f1 -d'|' | rev)
	prev_timestamp=$(head -1 $DATAFILE | rev | cut -f2 -d'|' | rev)
	
	echo "Compared timestamps:"
	echo "Previous: $prev_timestamp"
	echo "Last: $last_timestamp"
	echo "Time delta: $(convert_time $(($last_timestamp - $prev_timestamp)))"
	
	divider='==============================='
	divider=${divider}${divider}${divider}
	
	header_data=$(printf "%-15s %10s %10s %10s %10s   %6s %19s   %-15s\n" "COUNTRY" "CURRENCY" "AMOUNT" "CODE" "VALUE" "CHANGE" "${GREY}PREVIOUS_VALUE${DEFAULT}" "${GREY}DIFF.${DEFAULT}")
	width=$(echo -en "$header_data" | wc -c)
	echo -e "$header_data"
	printf "%-${width}.${width}s\n" "$divider"	

	tail -n +2 $DATAFILE | while read line;do
		country=$(echo $line | cut -f1 -d'|')
		currency=$(echo $line | cut -f2 -d'|')
		amount=$(echo $line | cut -f3 -d'|')
		code=$(echo $line | cut -f4 -d'|')
		value_last=$(echo $line | rev | cut -f1 -d'|' | rev)
		value_compared=$(echo $line | rev | cut -f2 -d'|' | rev)

		arrow=$NONEARROW
		if [[ $(bc <<< "$value_last > $value_compared") -eq 1 ]];then
			arrow=$UPARROW
		elif [[ $(bc <<< "$value_last < $value_compared") -eq 1 ]];then
			arrow=$DOWNARROW
		fi

		diff=$(printf "%.3f\n" $(bc <<< "$value_last - $value_compared"))
		if [[ $(bc <<< "$diff >= 0") -eq 1 ]];then
			sign='+'
		else
			sign=''
		fi

		data=$(printf "%-15s %10s %10s %10s %10.3f   %-20s %-19s %27s\n" "$country" "$currency" "$amount" "$code" "$value_last" "$arrow" "${GREY}${value_compared}${DEFAULT}" "${GREY}${sign}${diff}${DEFAULT}")
		echo -e "$data"
		#echo -e "$data $arrow ${GREY}${value_compared}${DEFAULT}"
	done
}

case $1 in
	get)
		get_data
		;;
	print)
		print_data
		;;
	*)
		echo -e "Invalid operation '${1}': Supported operation arguments are 'get' and 'print'"
		;;
esac
