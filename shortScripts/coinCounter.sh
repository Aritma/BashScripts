#!/bin/bash

################
#Coint counter - počítání mincí
#Krok 2 - ošetření vstupních hodnot
#skript bere jako argument číslo a vypíše minimální počet mincí ve kterých lze sumu vrátit
#Mince jsou v CZK: 50,20,10,5,2,1
#
#Ošetření vstupů:
#Vstupní hodnota musí existovat nebo bude zadána ručně
#Vstupní hodnota musí být kladné celé číslo
#Vstupní hodnota může být 0
################

VAL=$1

#Test vstupu pomocí regulárního výrazu
while true;do           #nekonečný cyklus bude přerušen pouze pokud bude vstup platný
	if [[ "$VAL" =~ ^[0-9]+$ ]]; then       #kontrola hodnoty VAL, že je kladné číslo pomocí regulárního výrazu
		break   #pokud je hodnota platná, ukončíme cyklus a hodnotu si necháme uloženou v proměnné VAL
	fi

	echo "Vstupní hodnota neexistuje nebo není kladným celým číslem." #informační hláška
	read -p "Zadej hodnotu: " VAL   #požadavek na vstup
done

#Pokud je hodnota 0, provede se pouze jednoduchý výpis"
if [ $VAL -eq 0 ];then
        echo "Hodnota je 0"
        exit
fi

#Samotný algoritmus se provede až v okamžiku, kdy máme k dispozici validní hodnotu
for coin in 50 20 10 5 2 1
do
        hodnota=$(($VAL / $coin))
        VAL=$(($VAL % $coin))
	echo "Počet mincí hodnoty $coin:" $hodnota
done
