#!/bin/bash

#############
#znaky.sh
#
#Skript vrací počet zadaných znaků v zadaném souboru
# - první agrument je jméno souboru
# - všechny ostatní argumenty jsou chledané znaky
#
#Pokud je znak speciální symbol, je nutné ho zadat v jednoduchých uvozovkách (např. '!')
#Argumentem může být pouze jeden znak. Všechny vstupy delší než jeden znak jsou ignorovány.
#Při zadání vstupu delšího než jeden znak bude vyvolána chybová hláška na stderr.
#
#Použití:
#./znaky [soubor] [znak1] [znak2] [znak3] [...]
#./znaky test.txt a b c x '!' '?'
############# 

#Kontrola zda existují argumenty. Musí být minimálně dva: soubor a znak

if [ $# -lt 2 ];then
	echo "Nedostatek argumentů!" >&2
	echo "Vstup musí obsahovat minimálně dva argumenty:" >&2
	echo "Příklad: ./znaky [soubor] [znak1] [znak2] [znak3] [...]" >&2
	exit 1
fi

#Kontrola existence souboru
#pokud soubor neexistuje, vyvolá skript chybovou hlášku a ukončí se s exit statusem 2

if [ -f $1 ];then
	inputFile=$1
else
	echo "$1 není platné jméno souboru" >&2
	exit 2
fi

#Hlavní cyklus
#část 1:
#pokud existuje více než jeden argument na začátku každého cyklu, posunou se argumenty o jedno místo doleva
#tím v každém cyklu získáme další argument v řadě na pozici prvního argumentu $1
#pokud se jedná o poslední argument, je cyklus ukončen a s ním celý skript
#
#část 2
#Nejprve kontrolujeme, zda se počet znaků v argumentu rovná dvěma. Každý argument se skladá ze své hodnoty a mezery,
#která odděluje argumenty. Hodnota 2 tedy znamená přesně jeden znak.
#Pokud je argument jeden znak, spočítáme počet znaků souboru s daným znakem a bez daného znaku. Rozdíl získaných čísel
#je počet výskytů znaku v souboru.
#Pokud je argument delší než jeden znak, vyvoláme chybovou hlášku pro daný znak a vynecháme ho ze zpracování.
#V případě, že byl alespoň jeden argument neplatný, ukončujeme skript exist statusem 1.

exitStatus=0
while true;do
	#část 1
    if [ $# -gt 1 ];then
        shift
    else
        break
    fi

	#část 2
	if [ $( echo $1 | wc -c ) -eq 2 ];then
		originalSize=$(cat $inputFile | wc -c)
		newSize=$(cat $inputFile | tr -d $1 | wc -c)
		dif=$(($originalSize-$newSize))
		echo -e "Počet znaků \"$1\": $dif"
	else
		echo -e "Argument \"$1\" není platný a bude vynechán. Argument musí být pouze jeden znak." >&2
		exitStatus=1
	fi
done

exit $exitStatus
