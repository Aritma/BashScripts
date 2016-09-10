#!/bin/bash
echo "ENTER FILENAME: "
read filename
ls $filename &> /dev/null

if [ $? -gt 0 ]
then
    echo "File in not valid"
else
    originalsize=$(cat ./$filename | wc -c)
    echo "total: $originalsize"

    for i in {a..z}
    do
        newsize=$(cat ./$filename | tr [:upper:] [:lower:] | tr -d "\n" | tr -d $i | wc -c)
        val=$((originalsize-newsize))
        echo "$(echo $i | tr [:lower:] [:upper:]),$i: $val / $(((val*100)/originalsize)).$(printf "%02d\n" $((((val*100)%originalsize)*100/originalsize)))%"
    done
    
    otherwithspace=$(cat $filename | tr -d '\n[:alpha:]' | wc -c)
    other=$(cat $filename | tr -d '\n" "[:alpha:]' | wc -c)
    lower=$(($(cat $filename | tr -d '\n" "[:upper:]' | wc -c)-other))
    upper=$(($(cat $filename | tr -d '\n" "[:lower:]' | wc -c)-other))
    empty=$((otherwithspace-other))
    EoL=$(cat $filename | wc -l)
    
    echo "----------"
    echo "lower: $lower / $(((lower*100)/originalsize)).$(printf "%02d\n" $((((lower*100)%originalsize)*100/originalsize)))%"
    echo "upper: $upper / $(((upper*100)/originalsize)).$(printf "%02d\n" $((((upper*100)%originalsize)*100/originalsize)))%"
    echo "other: $other / $(((other*100)/originalsize)).$(printf "%02d\n" $((((other*100)%originalsize)*100/originalsize)))%"
    echo "space: $empty / $(((empty*100)/originalsize)).$(printf "%02d\n" $((((empty*100)%originalsize)*100/originalsize)))%"
    echo "end-of-lines: $EoL / $(((EoL*100)/originalsize)).$(printf "%02d\n" $((((EoL*100)%originalsize)*100/originalsize)))%"
fi
