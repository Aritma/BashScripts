#!/bin/bash

#-----------------------------------
#Převod bankovního kurzu používající online data České Národní banky k danému datu
#CZ varinata: http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt
#EN varianta: http://www.cnb.cz/en/financial_markets/foreign_exchange_market/exchange_rate_fixing/daily.txt
#Data jsou pouze pro převod České koruny (CZK)
#
#Data budou získána online
#Pokud data pro daný den existují, budou použita bez stahování nových.
#Uživatel si může vybrat přímý převod nebo pouze výpis známých kurzů
#Pokud měna, kterou uživatel zadal neexistuje, může zažádat o výpis použitelných měn
#Výsledky budou zaokrouhlené na 3 desetinná místa
#
#Skript bere 0, 2 nebo 3 argumenty.
#0 argumentů: uživateli bude nabídnut výpis kompletního kurzovního lístku s potvrzovacím Y/N
#	./prevod_meny.sh
#1 argument: vypíše jednu tabulku pro specifikovanou měnu
#	./prevod_meny.sh JPY
#2 argumenty: výpis tabulky pro přímý převod mezi měnami, včetně možnosti mezipřevodu mezi měnami jinými než CZK
#	./prevod_meny.sh GBP USD
#	./prevod_meny.sh CZK USD
#3 argumenty: přímý převod hodnoty v prvním argumentu, měny z druhého argumentu na měnu v třetím argumentu
#	./prevod_meny.sh 23 CZK USD
#	./prevod_meny.sh 123 USD JPY
#-----------------------------------

#Pro řešení různých částí skriptu si napíšeme sadu funkcí
#Vybrat správné funkce může být u většího skriptu náročné, pište si jaké prvky potřebujete,
#pokud dvě funkce obsahují obdobnou funkcionalitu, rozmyslete se, jak funkce rozdělit na specifické varianty.
#Může se stát, že budete funkce několikrát přepisovat, snažte se tedy, držet si v kódu pořádek.
#K funcím si dopíšeme vstupy a výstupy, pokud je chceme předělat, měli bychom tvar vstupů a výstupů dodržet
#abychom nepoškodili činnost funkcí, které na naše upravené funkce navazují.(tento krok je pouze pro přehlednost)

#AUTHOR: zkontrolovat zda je tento blok potrebny
#-----------------------------------
#Seznam funkcí
#formatOutput ["řádek kurzu z tabulky nebo vlastní"]
#	formatOutput "Austrálie|dolar|1|AUD|16,641"
#	POPIS: Vypíše výstup v lépe čitelném formátu.
#printRateList
#	printRateList
#	POPIS: Vypíše kompletní převodní tabulku ve formátovaném tvaru.
#checkArgs [seznam argumentu]
#	checkArgs $@
#	POPIS: Zkontroluje jaký je počet argumentů, zda jsou použitelné a předá je v správné podobě dalším funkcím.
#toCZK [měna] [hodnota]
#	toCZK GBP 123
#	POPIS: Převede hodnotu libovolné měny (existujici v seznamu)  na CZK.
#fromCZK [měna] [hodnota]
#       fromCZK GBP 123
#	POPIS: Převede hodnotu CZK na libovolnou měnu (existujici v seznamu).
#getRateList
#	getRateList
#	POPIS: Vytvoří dočasný soubor s převodní tabulkou staženou ze stránek ČNB.
#clearERFile
#	clearERFile
#	POPIS: Odstraní soubory s převodními tabulkami ze systému. Vyvoláno při použití specifického argumentu.
#getValidCurrencyList
#	getValidCurrencyList
#	POPIS: Vypíše všechny dostupné měny ve zdrojových datech jako seznam. Slouží uživateli jako nápověda.
#isInList [hodnota] [seznam]
#	isInList GBP $(getValidCurrencyList)
#	POPIS: Zkontroluje zda je v zadaném seznamu požadovaná hodnota a vrací 0 ANO, nebo 1 NE.
#-----------------------------------

#POZNAMKA AUTORA
#pozn. zde bylo nutne kod predelat, protoze neustale testovani nam blokovalo pristup na server CNB
#varianta opakovaneho stahovani zmenena na variantu kontrolu data souboru a stahovani pouze pokud je
#soubor starsi nez aktualni datum (nyni nebude skript fungovat v jinych casovych pasmech jak ma)


#---getRateList----
#VSTUPY: /
#VÝSTUPY: skrytý soubor s převodní tabulkou pro daný den
#------------------

getRateList () {
	#nastavení dle jazykové varinaty
	DATE=$(date +%d%m%y)
	if [ $LOCALIZATION == "EN" ];then
		LISTNAME=".${DATE}_exchangeRateEN"
		ADRESA="http://www.cnb.cz/en/financial_markets/foreign_exchange_market/exchange_rate_fixing/daily.txt"
	elif [ $LOCALIZATION == "CZ" ];then
		LISTNAME=".${DATE}_exchangeRateCZ"
		ADRESA="http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt"
	else
		echo "ERROR: Neplatná hodnota proměnné LOCALIZATION. Varianty: EN,CZ" >&2
		exit 1
	fi	
	
	#Pro dobře formátovatelný výstup použijeme anglickou verzi tabulky. České znaky by totiž mohli mít vliv na
	#výsledný vzhled (znaky jsou interně jinak zpracované). Pro změnu stačí změnit proměnnou LOCALIZATION
	
	#kontrola zda soubory existují
	#přidána kontrola dostupnosti serveru ČNB
	if [ -f $LISTNAME ];then
		echo "Aktuální data již existují. Budou použita (soubor $LISTNAME)"
	else
		echo "Stahuji aktuální data ze stránek ČNB..."

		#níže uvedená metoda vyvolá chybu, pokud se data nepodaří stáhnout, soubor pro data však
		#vznikne ještě před pokusem o čtení dat, proto je nutné při chybové hlášce soubor smazat
		#aby nám neblokoval budoucí použití skriptu
		#Tato metoda není vhodná pro časté zápisy, protože dělá zápis na disku, pro naše potřeby
		#jednoho samostatného zápisu je však dostačující
		
		curl $ADRESA > $LISTNAME 2> /dev/null || echo -e "CHYBA: Data nejsou dostupná" && rm $LISTNAME
	fi
}


#---clearERFiles---
#VSTUPY: /
#VÝSTUPY: Odstranění věch skrytých souborů s převodními tabulkami z adresáře
#------------------

clearOldFiles () {
	echo "Odstraňuji soubory s převodními daty..."

        #Musíme použít přepínač -d u ls aby se nepokoušel procházet adresáře ale rovnou hledal
        #názvy souborů začínající tečkou.	

	if ls -d .*_exchangeRate* > /dev/null 2>&1;then
		echo "SOUBORY:"

		for toRemove in $(ls -d .*_exchangeRate*);do
			rm "$toRemove"
			echo $toRemove - ODSTRANĚNO
		done
	else
		echo "Žádné soubory k odstranění nebyly nalezeny."
	fi
}


#---formatOutput---
#VSTUPY: Neformátovaný řádek ve formátu převodní tabulky ("země|měna|množství|kód|kurz")
#VÝSTUPY: Formátovaný řádek převodní tabulky
#------------------

formatOutput () {
	format=" %-16s %-10s %-10s %-10s %-10s\n"

	#Příkaz printf zavoláme v subshellu, před samotným printf změníme v daném subshellu
	#proměnnou IFS na hodnotu "|", tím změníme oddělovač slov v daném shellu

        (IFS="|";printf "$format" $1)
}


#-------toCZK-----
#VSTUPY: [měna] [hodnota]
#VÝSTUPY: hodnota dané měny v CZK (Měna->CZK)
#------------------

toCZK () {
	if [ "$1" == "CZK" ];then
                echo $2
                return 0
        fi
	POLOZKA=$(grep "$1" $LISTNAME)
	KURZ=$(echo $POLOZKA | cut -f5 -d"|")
	JEDNOTEK=$(echo $POLOZKA | cut -f3 -d"|")
	ZAJEDNOTKU=$(bc -l <<< "$KURZ / $JEDNOTEK")

	#Do výsledku přidáváme scale=3 a operaci /1 pro omezení počtu desetinnych mist,
	#protože parametr scale funguje pouze u dělení.

	VYSLEDEK=$(bc -l <<< "scale=3;$ZAJEDNOTKU * $2 / 1")
	echo $VYSLEDEK
}


#-----fromCZK------
#VSTUPY: [měna] [hodnota]
#VÝSTUPY: hodnota CZK v dané měně (CZK->Měna)
#------------------

fromCZK () {
	if [ "$1" == "CZK" ];then
		echo $2
		return 0
	fi
	POLOZKA=$(grep "$1" $LISTNAME)
	KURZ=$(echo $POLOZKA | cut -f5 -d"|")
        JEDNOTEK=$(echo $POLOZKA | cut -f3 -d"|")
        ZAJEDNOTKU=$(bc -l <<< "$KURZ / $JEDNOTEK")
	
	#Obrácený postup než u toCZK funkce
	
	VYSLEDEK=$(bc -l <<< "scale=3;$2 / $ZAJEDNOTKU")
	echo $VYSLEDEK
}


#---printRateList--
#VSTUPY: /
#VÝSTUPY: výpis formátované převodní tabulky
#------------------

printRateList () {
	for val in $(cat $LISTNAME | tr " " "_" | tr "\n" " ");do
        	formatOutput $val
	done
}


#--getValidCurrencyList--
#VSTUPY: /
#VÝSTUPY: seznam platných měn včetně CZK
#-----------------------

getValidCurrencyList () {
	echo "Seznam dostupných měn:"
	
	#V řetězci použijeme příkaz tail +n, jedná se o zápis specifický pro tail a umožňuje zobrazit
	#vše od n-tého řádku do konce souboru. Na konec seznamu přidáme CZK, protože tato měna je platná
	#ale není uvedena v převodní tabulce
	
	cut -f4 -d"|" $LISTNAME | tail +3 | tr "\n" " "
	echo CZK
}


#-----isInList-----
#VSTUPY: [hodnota] [seznam]
#VÝSTUPY: return 0 nebo return 1
#------------------

isInList() {
	HLEDANE=$1
	while shift;do
		if [ "$HLEDANE" == "$1" ];then
			return 0
		fi
	done
	return 1
}


#----checkArgs-----
#VSTUPY: [argumenty skriptu]
#VÝSTUPY: nastavení proměnných ARGUMENTS, OPTIONS a ARGNUM platnými oddělenými hodnotami
#	  případně ukončení skriptu s chybovou hláškou
#------------------

checkArgs () {
	#proměnné znovu nastavíme, abychom si byli jistí, že je v nich správná hodnota
	ARGUMENTS=""
	ARGNUM=0
	OPTIONS=""

	#nejdříve od sebe oddělíme argumenty a přepínače
	for ARG in $@;do
		if [[ "$ARG" =~ ^-.*$ ]];then
			PARAMS="$PARAMS $ARG"
		else
			ARGUMENTS="$ARGUMENTS $ARG"
			((ARGNUM++))
		fi
	done

	#nasledně obě skupiny zkontrolujeme zda jsou jejich hodnoty platné,
	#případně vyvoláme odpovídající chybu v zadání
	#test provádíme negací výsledku funkce isInList -> není v listu
	
	for ARG in $ARGUMENTS;do
		if ! isInList $ARG $(getValidCurrencyList); then
			echo "Neplatný argument $ARG" >&2
			exit 1
		fi
	done

	for PAR in $PARAMS;do
                if ! isInList $PAR $PARAMLIST; then
                        echo "Neplatný přepínač $PAR" >&2
                        exit 1
                fi
        done
	
	#TODO: Dopsat predani dalsim funkcim
	
	#DEBUG
	#echo "ARGS: $ARGUMENTS"
	#echo "#ARGS: $ARGNUM"
	#echo "PARAMS: $PARAMS"
}


#----currToCurr----
#VSTUPY: [zdrojová měna] [částka] [cílová měna] 
#VÝSTUPY: Hodnota cílové měny po převodu ze zdrojové měny
#------------------

currToCurr () {
	VYSLEDEK=$(bc -l <<< "scale=3;$(fromCZK $3 $(toCZK $1 $2)) / 1")
        echo $VYSLEDEK	
}


#---


#-----------------------------------
#Proměnné vytvořené při startu skriptu
#Většinou jsou používané některou z funkcí (uvedeno v komentáři proměnné)
#-----------------------------------

#default EN, varianty CZ,EN, udává jaká jazyková varianta převodové tabulky se bude stahovat
#přidíno s funkce getRateList
LOCALIZATION=EN

#seznam parametrů, používaných ve skriptu, uložených jako string
#během psaní skriptu je možné doplňovat další funkcionalitu přidáváním hodnot
#přidáno s funkcí checkArgs
PARAMLIST="-clear -help"

#Proměnné pro uložení argumentů, přepíačů a celkového počtu argumentů
#jsou podruhé uvedené i v samotné funkci pro zajištění správné hodnoty
#zde je uvádíme pro lepší zřetelnost a také pro případné testování kódu
#přidáno s funkcí checkArgs
PARAMS=""
ARGUMENTS=""
ARGNUM=0

#-----------------------------------
#Běh programu složený z jednotlivých funkcí.
#-----------------------------------

#Při této úrovni složitosti je již výhodné psát jednotlivé části jako funkce abychom mohli
#jednotlivé díly postupně testovat a konečný výsledek poskládat z již otestovaných částí
#také případné úpravy kódu se budou následně provádět na úrovni funkcí a snižuje se šance
#že změnami poškodíme zbytek kódu.

#TESTOVANI
getRateList
#printRateList
#toCZK EUR 15
#fromCZK EUR 100 
#getValidCurrencyList
#isInList GBP $(getValidCurrencyList) && echo True || echo False
checkArgs $@
#currToCurr JPY 3456 USD

#clearing
isInList -clear $PARAMS && clearERFiles

#TODO:
#Kontrola dostupnosti dat na serveru CNB
#Kontrola vstupnich argumentu a jejich spravne parsovani : HOTOVO pocitani a rozdeleni argumentu
#	IDEA: pokud je pouzit option, ktery nepotrebuje znat hodnoty agrumentu, bude funkce optionu provedena prvni
#	      a bude zobrazen pouze obsah z daneho option (napriklad -h pro help)
#	      provedese nastaveni promenne SUPPRESS na 1, tim se nevykona funkcni cast programu
#	      pokud bude pouzit option, kteremu nevadi funkce skriptu, bude proveden v poradi dle potreby funkce
#Implementace optionu pro skript na mazani souboru, informacni vypis o stavu a manual
#	Optiony nahrazene parametry, funguji stejne ale vyzaduji kompletni slovo aby byly funcni
#Pokud vybraná měna neexistuje, bude uživateli navrhnuto zobrazení seznamu použitelných měn getValidCurrencyList()
