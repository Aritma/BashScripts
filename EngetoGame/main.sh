source ./functions

if [[ -z $1 ]];then
	EPISODE=1
else
	if [ "$1" -eq "$1" ] 2>/dev/null; then
		EPISODE=$1
	else
		echo "ERROR: Wrong parameter, number expected."
	fi
fi

while true; do
	case $EPISODE in
	1)	./chapters/chap1.sh
		((EPISODE++))
		;;
	2)	./chapters/chap2.sh
		((EPISODE++))
		;;
	3)	echo "Chapter 3"
		((EPISODE++))
		;;
	4)	echo "Chapter 4"
		((EPISODE++))
		;;
	5)	echo "Chapter 5"
		((EPISODE++))
		;;
	*)	echo "END"
		break
	esac
done
