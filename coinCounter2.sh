#!/bin/bash
echo "Set value:"
read moneyValue
echo "Inserted value>" $x
coin=(50 20 10 5 2 1)
for item in ${coin[*]}
do
        val=$(($moneyValue / $item))
        moneyValue=$(($moneyValue % $item))
        echo "Coin value" $item ":" $val
done
