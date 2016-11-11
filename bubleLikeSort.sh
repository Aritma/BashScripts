#!/bin/bash
#basic buble-like sorting algorithm

#initial valu
arr=( $(echo $@ | tr [:upper:] [:lower:] ) )
cache=0
maxposition=$(($#-1))
switched=1

echo "ORIG: " ${arr[*]}

while true
do
    switched=0
    for i in `seq 0 $(($maxposition-1))`
    do
        #compare actual neighbour values, if left is greater than right, switch them
        n=0
        while true
        do
            str1=${arr[i]}
            str2=${arr[$((i+1))]}
            
            val1=$(printf %d "'${str1:$n:1}")
            val2=$(printf %d "'${str2:$n:1}")
            
            if [ $val1 -eq $val2 ]
            then
                n=$((n+1))
            elif [ $val1 -gt $val2 ]
            then
                cache=${arr[$i]}
                arr[$i]=${arr[$(($i+1))]}
                arr[$(($i+1))]=$cache
                switched=1
                break
            else
                break
            fi
            
            if [ $x > 100 ]
            then
                break
            fi
        done
    done
    
    if [ $switched -eq 0 ]
    then
        break
    fi
done
################
echo "FINAL: " ${arr[*]}
