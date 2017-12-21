#!/bin/bash

#verze skriptu 
VERSION="1.1"

#-----------------------------------
#Převod bankovního kurzu používající online data České Národní banky k danému datu
#CZ varinata: http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt
#EN varianta: http://www.cnb.cz/en/financial_markets/foreign_exchange_market/exchange_rate_fixing/daily.txt
#Data jsou pouze pro převod České koruny (CZK)
#
#Data budou získána online
#Pokud data pro daný den existují, budou použita bez stahování nových.
#Uživatel si může vybrat přímý převod nebo pouze výpis známých kurzů
#Výsledky budou zaokrouhlené na 3 desetinná místa
#
#Skript bere 0-3 argumenty.
#0 argumentů: uživateli bude nabídnut výpis kompletního kurzovního lístku s potvrzovacím y/n
#	./prevod_meny.sh
#1 argument: vypíše jednu tabulku pro specifikovanou měnu
#	./prevod_meny.sh JPY
#2 argumenty: výpis tabulky pro přímý převod mezi měnami, vždy převádí do CZK
#	./prevod_meny.sh GBP 123
#	./prevod_meny.sh CZK 345
#3 argumenty: přímý převod měny (první argument) o dané hodnotě (druhý argument) na jinou měnu (třetí argument)
#	./prevod_meny.sh CZK 23 USD
#	./prevod_meny.sh USD 123 JPY
#-----------------------------------


#-----------------------------------
#Proměnné vytvořené při startu skriptu
#Většinou jsou používané některou z funkcí (uvedeno v komentáři proměnné)
#-----------------------------------
#default EN, varianty CZ,EN, udává jaká jazyková varianta převodové tabulky se bude stahovat
#přidáno s funkcí getRateList
LOCALIZATION=EN

#adresy stránek na stažení
#přidáno s funkcí getRateList
ADRESAEN="http://www.cnb.cz/en/financial_markets/foreign_exchange_market/exchange_rate_fixing/daily.txt"
ADRESACZ="http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt"

#jméno souboru, který se bude daný den zpracovávat
#nastavení dle jazykové varinaty
#přidáno s funkcí getRateList
DATE=$(date +%d%m%y)
LISTNAME=".${DATE}_exchangeRate$LOCALIZATION"

#seznam parametrů, používaných ve skriptu, uložených jako string
#během psaní skriptu je možné doplňovat další funkcionalitu přidáváním hodnot
#přidáno s funkcí checkArgs
PARAMLIST="-clear -help -version -refresh -valid -table"

#Proměnné pro uložení argumentů, přepíačů a celkového počtu argumentů
#jsou podruhé uvedené i v samotné funkci pro zajištění správné hodnoty
#zde je uvádíme pro lepší zřetelnost a také pro případné testování kódu
#přidáno s funkcí checkArgs
PARAMS=""
ARGUMENTS=""
ARGNUM=0

#exit identifikátor určuje, zda je po zpracování parametrů ukončen program
#hodnoty TRUE a FALSE (pravda nebo nepravda)
#používáme řetězce TRUE a FALSE velkými písmeny aby nemohlo dojít k záměně s příkazy true/false
#přidáno ve verzi 1.1 po odstranění interaktivního výstupu u varianty bez vstupů
#přednastavená hodnota je FALSE, ve skriptu provádíme pouze jednorázovou změnu na TRUE pokud je potřeba
PARAMEXIT="FALSE"


#-----------------------------------
#Pro řešení různých částí skriptu si napíšeme sadu funkcí
#Vybrat správné funkce může být u většího skriptu náročné, pište si jaké prvky potřebujete,
#pokud dvě funkce obsahují obdobnou funkcionalitu, rozmyslete se, jak funkce rozdělit na specifické varianty.
#Může se stát, že budete funkce několikrát přepisovat, snažte se tedy, držet si v kódu pořádek.
#K funkcím si dopíšeme vstupy a výstupy, pokud je chceme předělat, měli bychom tvar vstupů a výstupů dodržet
#abychom nepoškodili činnost funkcí, které na naše upravené funkce navazují.(tento krok je pouze pro přehlednost)


#---------------------
#FUNKCE
#---------------------

#Hlavička funkce:
#Každá funkce má svoji hlavičku, která udává rychlý přehled použití funkce
#---<jmeno funkce>---
#VSTUPY: vstupy, které funkce vyžaduje, včetne pořadí a dalších vlastností
#VÝSTUPY: teoretický očekávaný výstup funkce, je důležité ho zachovat kvůli návaznosti funkcí ne sebe
#ZÁVISLOST: 	jaké funkce jsou použité v této funkci, funkce která požaduje jinou funkci musí být v kódu
#		umístěna až po funkci, kterou používá	
#POPIS:	Popis chování a vlastností funkce


#---getRateList----
#VSTUPY: /
#VÝSTUPY: skrytý soubor s převodní tabulkou pro daný den
#ZÁVISLOST: /
#POPIS: Stáhne převodní tabulku pro aktuální den a uloží ji do skrytého souboru v adresáři skriptu.
#	Stahuje data pouze pokud soubor neexistuje a vyvolá chybu při nedostupnosti dat
#	Rozlišuje mezi českou a anglickou verzí dat (default anglická verze)
#	Pozn. stahujeme v minimálním počtu, protože cílový server by mohl časté opakování vyhodnotit jako hrozbu
#------------------

getRateList () {
	#nastavení dle jazykové varinaty
	#DATE=$(date +%d%m%y)
	if [ $LOCALIZATION == "EN" ];then
	#	LISTNAME=".${DATE}_exchangeRateEN"
		ADRESA=$ADRESAEN
	elif [ $LOCALIZATION == "CZ" ];then
	#	LISTNAME=".${DATE}_exchangeRateCZ"
		ADRESA=$ADRESACZ
	else
		echo "ERROR: Neplatná hodnota proměnné LOCALIZATION. Varianty: EN,CZ" >&2
		exit 1
	fi	
	
	#Pro dobře formátovatelný výstup použijeme anglickou verzi tabulky. České znaky by totiž mohli mít vliv na
	#výsledný vzhled (znaky jsou interně jinak zpracované). Pro změnu stačí změnit proměnnou LOCALIZATION
	
	#kontrola zda soubory existují
	#přidána kontrola dostupnosti serveru ČNB
	if [ ! -f $LISTNAME ];then
		echo "Stahuji aktuální data ze stránek ČNB..."

		#níže uvedená metoda vyvolá chybu, pokud se data nepodaří stáhnout, soubor pro data však
		#vznikne ještě před pokusem o čtení dat, proto je nutné při chybové hlášce soubor smazat
		#aby nám neblokoval budoucí použití skriptu
		#Tato metoda není vhodná pro časté zápisy, protože dělá zápis na disku, pro naše potřeby
		#jednoho samostatného zápisu je však dostačující
		
		curl $ADRESA > $LISTNAME 2> /dev/null || (echo -e "CHYBA: Data nejsou dostupná" && rm $LISTNAME)
		
		#verze 1.1 - fix případu stažení prázdných dat
	        if [ $(wc -l $LISTNAME) -eq 0 ];then
		    echo "Pozor, při stahování dat došlo k chybě, opakujte pokus později."
		    rm $LISTNAME
		fi
	fi
}


#---clearRateFiles---
#VSTUPY: /
#VÝSTUPY: Odstranění věch skrytých souborů s převodními tabulkami z adresáře
#ZÁVISLOST: /
#POPIS: Maže soubory s převodními daty.
#	Najde všechny soubory s odpovídajícím tvarem a provede jejich výpis a smazání
#------------------

clearRateFiles () {
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


#-------toCZK-----
#VSTUPY: [měna] [hodnota]
#VÝSTUPY: hodnota dané měny v CZK (Měna->CZK)
#ZÁVISLOST: /
#POPIS: Převede hodnotu zadané měny do CZK
#	Pokud je zadanou měnou CZK neprovádí žádný převod, pouze hodnotu rovnou vypíše
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
#ZÁVISLOST: /
#POPIS: Převede hodnotu zadané hodnoty v CZK do zvolené měny
#       Pokud je zadanou měnou CZK neprovádí žádný převod, pouze hodnotu rovnou vypíše
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


#----currToCurr----
#VSTUPY: [zdrojová měna] [částka] [cílová měna]
#VÝSTUPY: Hodnota cílové měny po převodu ze zdrojové měny
#ZÁVISLOST: toCZK fromCZK
#POPIS: Převod mezi dvěma různými měnami ze zdrojové na cílovou.
#------------------

currToCurr () {
        VYSLEDEK=$(bc -l <<< "scale=3;$(fromCZK $3 $(toCZK $1 $2)) / 1")
        echo $VYSLEDEK
}


#---formatOutput---
#VSTUPY: Neformátovaný řádek ve formátu převodní tabulky ("země|měna|množství|kód|kurz")
#VÝSTUPY: Formátovaný řádek převodní tabulky
#ZÁVISLOST: /
#POPIS: Formátuje data v převodní tabulce do unifikovaného tvaru pro zobrazení
#------------------

formatOutput () {
        format=" %-16s %-10s %-10s %-10s %-10s\n"

        #Příkaz printf zavoláme v subshellu, před samotným printf změníme v daném subshellu
        #proměnnou IFS na hodnotu "|", tím změníme oddělovač slov v daném shellu

        (IFS="|";printf "$format" $1)
}


#---printRateList--
#VSTUPY: [měna] nebo žádný
#VÝSTUPY: výpis formátované převodní tabulky
#ZÁVISLOST: formatOutput
#POPIS: Vypíše převodní tabulku ve formátované variantě
#	Pokud je zadaný argument se spefickou měnou, provede se výpis pouze pro zvolenou měnu
#	Pokud je hodnota CZK, provede se pouze informační výpis že tabulka neexistuje
#------------------

printRateList () {
	if [ $# -eq 0 ];then
		#celý list pokud není zadný argument

		for val in $(cat $LISTNAME | tr " " "_" | tr "\n" " ");do
        		formatOutput $val
		done
	else	
		#pouze hlavička souboru a hledaná měna
		#v tomto případě je zbytečné ošetřovat vstupy, počítáme s tím, že funkci
		#použijeme správně

		if [ $1 == "CZK" ];then
			echo "Hodnota CZK nemá vlastní převodní tabulku CZK -> CZK"
		else
			for val in $(head -2 $LISTNAME | tr " " "_" | tr "\n" " ");do
                        	formatOutput $val
                	done
			formatOutput $(grep $1 $LISTNAME | tr " " "_")
		fi
	fi
}


#--getValidCurrencyList--
#VSTUPY: /
#VÝSTUPY: seznam platných měn včetně CZK
#ZÁVISLOST: /
#POPIS: Vrací seznam platných měn na základě dat z převodní tabulky jako řetězec.
#	Hodnota CZK přidána manuálně
#-----------------------

getValidCurrencyList () {
	#V řetězci použijeme příkaz tail +n, jedná se o zápis specifický pro tail a umožňuje zobrazit
	#vše od n-tého řádku do konce souboru. Na konec seznamu přidáme CZK, protože tato měna je platná
	#ale není uvedena v převodní tabulce
	
	cut -f4 -d"|" $LISTNAME | tail +3 | tr "\n" " "
	echo CZK
}


#-----isInList-----
#VSTUPY: [hodnota] [seznam]
#VÝSTUPY: return 0 nebo return 1
#ZÁVISLOST: /
#POPIS: Vrací úspěch pokud zadaná hodnota existuje v zadaném seznamu hodnot
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


#----separateArgs-----
#VSTUPY: [argumenty skriptu]
#VÝSTUPY: nastavení proměnných ARGUMENTS, OPTIONS a ARGNUM 
#	  případně ukončení skriptu s chybovou hláškou
#ZÁVISLOST: isInList
#POPIS:	Rozdělí argumenty skriptu na ovládací parametry a argumenty, které bude skript zpracovávat
#	Zachovává pořadí argumentů (je důležité pro funkčnost skriptu)
#------------------

separateArgs () {
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

	#přepínače (parametry) zkontrolujeme zda jsou jejich hodnoty platné,
	#případně vyvoláme odpovídající chybu v zadání
	#test provádíme negací výsledku funkce isInList -> není v listu
	#kontrolu argumentů provádíme až při zjišťování pracovního vzoru

	for PAR in $PARAMS;do
                if ! isInList $PAR $PARAMLIST; then
                        echo "Neplatný přepínač $PAR" >&2
                        exit 1
                fi
        done
	
	#DEBUG
	#echo "ARGS: $ARGUMENTS"
	#echo "#ARGS: $ARGNUM"
	#echo "PARAMS: $PARAMS"
}


#---getInputPattern---
#VSTUPY: [seznam agrumentů]
#VÝSTUPY: řetězec vzoru vstupů
#ZÁVISLOST: getValidCurrencyList 
#POPIS: Kontroluje zpracované argumenty a z jejich pořadí složí jaká varianta vstupu byla použita
#	Výstupem je řetězec kombinovaný z variant vstupu c a n.
#	V případě neplatného argumentu vyvolá chybu. Platné argumenty jsou pouze zkratky měn z převodní tabulky
#	a číslo.
#	Číslo může mít hodnoty "n", "n.n", ".n" nebo "n." např. 123. nebo .123 ve smyslu 123.0 resp. 0.123
#---------------------

getInputPattern () {
	CURRENCYLIST="$(getValidCurrencyList)"
	PATTERN=""
	for VALUE in $@;do
		#měna (currency) = c
		#číslo (number) = n
		#ostatní možnosti vyvolají chybu
		
		if isInList $VALUE $CURRENCYLIST;then
			PATTERN="${PATTERN}c"	
		elif [[ "$VALUE" =~ ^\.*[0-9]+\.*[0-9]*$ ]];then
			PATTERN="${PATTERN}n"
		else
			echo "CHYBA: Neplatný vstup <$VALUE>" >&2
			exit 1
		fi
	done
	echo $PATTERN
}

#-----------------------------------
#Běh programu složený z jednotlivých funkcí.
#-----------------------------------

#Při této úrovni složitosti je již výhodné psát jednotlivé části jako funkce abychom mohli
#jednotlivé díly postupně testovat a konečný výsledek poskládat z již otestovaných částí
#také případné úpravy kódu se budou následně provádět na úrovni funkcí a snižuje se šance
#že změnami poškodíme zbytek kódu.

#-----------
#TESTOVANI
#ponechano jako ukazka pouziti a testovani funkci
#----------
#getRateList
#printRateList USD
#toCZK EUR 15
#fromCZK EUR 100 
#getValidCurrencyList
#isInList GBP $(getValidCurrencyList) && echo True || echo False
#separateArgs $@
#getInputPattern $ARGUMENTS
#currToCurr JPY 3456 USD

#clearing
#isInList -clear $PARAMS && clearERFiles

#---------------------------
#HLAVNÍ ŘÍDÍCÍ BLOK PROGRAMU
#--------------------------

#zpracování všech argumentů skriptu

separateArgs $@


#kontrola, zda není použit parametr
#některé parametry ukončují skript přednostně
#pokud přidáváte nové hodnoty, nezapoměňte je přidat i do proměnné PARAMLIST

if isInList "-help" $PARAMS;then
	  [ $ARGNUM -gt 0 ] && echo "Argumenty skriptu byly ignorovány..."
    echo "HELP - PŘEVOD MĚNY - VERZE $VERSION"
	  tail -63 $0
  
    #help varianta rovnou ukončuje skript po vypsání
	  exit
fi

if isInList "-version" $PARAMS;then
    echo "Version: $VERSION"
    echo "..."
fi

if isInList "-refresh" $PARAMS;then
	  [ -f $LISTNAME ] && rm $LISTNAME
    getRateList
	  echo "Data aktualizována (soubor $LISTNAME)"
    echo ...
fi

if isInList "-valid" $PARAMS;then
    [ $ARGNUM -gt 0 ] && echo "Argumenty skriptu byly ignorovány..."
    getValidCurrencyList
    PARAMEXIT="TRUE"
fi

if isInList "-table" $PARAMS;then
    getRateList
	  printRateList
    echo ...
fi

#Ukončení skriptu, pokud to alespoň jeden parametr vyžaduje
if [ PARAMEXIT == "TRUE" ];then
    [ $ARGNUM -gt 0 ] && echo "Argumenty skriptu byly ignorovány..."
    exit
fi

#pokud není zadaný žádný argument nebo parametr, je uživatel vyzván k použizí help nabídky
#v případě, že je zadný alespoň jeden argument, skript se pokusí tento argument zpracovat

if [ $ARGNUM -eq 0 ];then
    if [ "$PARAMS" == "" ];then
        echo "Nejsou zadané platné vstupy, použijte -help pro nápovědu"
        echo "$0 -help"
	exit
    fi
else
    getRateList
    
    #následující blok zpracovává vstup na základě zadaného vzoru, neplatné vzory vyhodnotí jako chybu
    #a vypíše výzvu k zadání parametru -help
    case $(getInputPattern $ARGUMENTS) in
	"c")
		printRateList $ARGUMENTS
		;;
	"cn")
		toCZK $ARGUMENTS
		;;
	"cnc")
		currToCurr $ARGUMENTS
		;;
	*)
		echo "Neplatná kombinace argumentů!"
		echo "Použijte parametr -help pro nápovědu"
		exit
		;;
    esac
fi

#pokud je použit parametr -clear, provede se mazání souborů
isInList -clear $PARAMS && clearRateFiles

exit




#V TUTO CHVÍLI JE SKRIPT UKONČEN
#ZBYTEK SOUBORU JE JIŽ NORMÁLNÍ TEXTOVÝ SOUBOR
#KONEC SOUBORU POUŽIJEME JAKO ZDROJ PRO NÁPOVĚDU

<HELP>
** PŘEVODNÍK MĚN
Skript slouží k převodu měn na základě kurzovního lístku České Národní banky.
Kurzovní lístek se jednou denně stahuje z online podkladů ČNB


POUŽITÍ:
<jmenéno skriptu> [vzor argumentů] [parametry]


[vzor argumentů]
----------------
1) Zobrazení kompletní převodní tabulky (bez argumentu)	./prevod_meny.sh
2) Zobrazení převodní tabulky pro určitou měnu		./prevod_meny.sh [měna]
3) Převod hodnoty platné měny na CZK			./prevod_meny.sh [měna] [hodnota]
4) Převod hodnoty platné měny1 na jinou měnu2 		./prevod_meny.sh [měna1] [hodnota] [měna2]

Musí být zadaná platná měna z kurzovního lístku (lze zjistit parametrem -valid
Všechny nepodporované tvary argumentů budou vyhodnoceny jako neplatné a skript se neprovede


[parametry]
-----------
Nezáleží na pozici parametru v pořadí argumentů, parametry jsou zpracované zvlášť

- help		tato nápověda

- version	informace o verzi

- refresh	samostatné obnovení souboru s daty pro převod (kurzovní lístek ČNB)
		POZOR: Smaže případný starý soubor a nahradí ho nově staženým

- valid		zobrazí použitelné měny, pokud nejsou jsou data k dispozici, automaticky stáhne nová

- clear		smaže všechny existující soubory se staženými daty


Číselné hodnoty pro převod
--------------------------
Skript umí pracovat s desetinnými čísly. Jako separátor používá desetinnou tečku.
Podporuje hodnoty .n a n.

Validní zápisy:
999
999.99
.999	= 0.999
999.	= 999.0


Příklady použití
----------------
./prevod_meny.sh JPY 2843.17
./prevod_meny.sh GBP 122 EUR
./prevod_meny.sh EUR .88 CZK


EXIT STATUS:
0	bez chyby
1	chyba při zpracování dat

=====================================
** AUTOR: Michal Matějka
** ENGETO ACADEMY EDUCATION MATERIALS
