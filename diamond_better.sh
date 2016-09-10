#!/bin/bash

#Diamond script

if [ $1 ]
then number=$1
else echo -n "Enter number: "
     read number
     
fi
limit=$((number*2+1))
si=$((0-number))
i=0

#space input test
charlimit=${#number}
charcount=0

for ((a=1; a<=$limit; a++))
do  
    i=$si
    for ((b=1; b<=$limit; b++))
    do
        var=$i
        
        #space input test
        if [ $var -lt 0 ]
        then testvar=0
        else testvar=$var
        fi
        
        charcount=${#testvar}
        chardif=$((charlimit-charcount))
        for ((c=0; c<chardif; c++))
        do
            echo -n " "
        done
        #end space input test
        
        if [ $var -ge 0 ]
        then echo -n $var
        else echo -n " "
        fi
        
        if [ $b -gt $number ]
        then i=$((i-1))
        else i=$((i+1))
        fi
    done
    
    echo -ne "\n"
    
    if [ $a -gt $number ]
    then si=$((si-1))
    else si=$((si+1))
    fi
done