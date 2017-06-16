#!/bin/bash

#argument existence test
if [[ $# -eq 0 ]] 
then
        echo "No valid arguments!"
fi

#argument number test
if [[ $1 -eq $1 ]] 2> /dev/null
then
        moneyValue=$1
else
        echo "Invalid argument, must be number!"
fi

#main loop
echo "Value: $1"
for coin in 50 20 10 5 2 1
do
        val=$((moneyValue / coin))
        moneyValue=$((moneyValue % coin))
        echo "Coin value" $item ":" $val
done
