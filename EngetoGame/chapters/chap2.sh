#!/bin/bash
source ./data/functions
#CHAPTER 2

getVar TEXTSPEED
getVar PLAYERNAME
getVar AI

#TODO
#GAME STATUS CHECK - NEED UPDATE

clear
sleep 2
text "CHAPTER 2 - JOURNEY BEGINS" $TEXTSPEED
sleep 1
text "$PLAYERNAME? When I found you, you have had some files with you.\nMaybe it could help you remember." $TEXTSPEED "<$AI>"
text "Files? Like items?." $TEXTSPEED "<$PLAYERNAME>"
text "No, as I said. FILES.\nThis is linux system, everything is a file." $TEXTSPEED "<$AI>"

#TODO - CONSIDER VARIANT WITH OWNER BASED ON PLAYERS NAME AS NEW USER - DELETE AFTER GAME END

if [[ ! -d "Loot" ]];then mkdir Loot;fi
cd Loot
> data_storage
> diary.txt
> key.card
cd ..

echo "SYSTEM:"
echo -e "New file: data_storage\nNew file: diary.txt\nNew file: key.card"

text "All items you find, are stored in Loot directory. Don't forget it!" $TEXTSPEED "<$AI>"

text "##########" 0.02
echo "Use command to see files in working directory (use single long-list option):"
useCommand "ls -l"

text "See? There is \"Loot\" directory here! Look inside!" $TEXTSPEED "<$AI>"
text "##########" 0.02
echo "Now use command to see files in Loot directory (use single long-list option):"
useCommand "ls -l Loot"

text "I don't remember any of those items." $TEXTSPEED "<$PLAYERNAME>"
text "All of those items are some kinds of data containers or logs.\nBut all empty.\nMaybe we can find some backup parts in system." $TEXTSPEED "<$AI>"
text "You will need inventory directory to store it.\nCreate one please." $TEXTSPEED

text "##########" 0.02
echo "Create empty directory called \"Inventory\":"
useCommand "mkdir Inventory"

text "Great, now just move those three files from working directory to your new Inventory" $TEXTSPEED "<$AI>"
echo "Move data_storage, diary.txt and key.card files from Loot directory to Inventory:"
solveTime

while true;do
text "Let's check it..." $TEXTSPEED "<$AI>"
if [[ ! -f "Loot/diary.txt" || ! -f "Loot/data_storage" || ! -f "Loot/key.card" ]];then
	if [[ -f "Inventory/diary.txt" && -f "Inventory/data_storage" && -f "Inventory/key.card" ]]; then
		text "Good job." $TEXTSPEED "<$AI>"
		break
	else
		text "There are still some mistakes, try again." $TEXTSPEED "<$AI>"
		solveTime
	fi
else
	text "There are still some mistakes, try again." $TEXTSPEED "<$AI>"
	solveTime
fi
done

text "Let's leave this place, I am sure that there is nothing more to do." $TEXTSPEED "<$AI>"
pressKey

clear
echo ""
echo "*** CAUTION!!! ***"
sleep 1
clear
echo ""
sleep 1
echo "*** CAUTION!!! ***"
sleep 1
clear
echo ""
sleep 1
echo "*** CAUTION!!! ***"
sleep 0.5
clear
text "Dangerous elements detected! Preparing clearing procedure!" $TEXTSPEED "<Antivirus>"
text "Damn, you have some viruses on you! Hurry!\nLook at the hidden files in your inventory, it must be inside!" $TEXTSPEED "<$AI>"
> Inventory/.virus-AN01

text "##########" 0.02
echo "Use command to see hidden files in Inventory directory:"
useCommand "ls -la Inventory" "ls -a Inventory"

text "I see it! This .virus-AN01 file! Delete it quickly!" $TEXTSPEED "<$AI>"

text "##########" 0.02
echo "Delete dangerous file:"
useCommand "rm Inventory/.virus-AN01" "rm -r Inventory/.virus-AN01" "rm -f Inventory/.virus-AN01" "rm -rf Inventory/.virus-AN01" "rm -fr Inventory/.virus-AN01"

sleep 1
text "Clearing check activated\nNo problems to clear\nClearing process terminated" $TEXTSPEED "<Antivirus>"
sleep 1

text "That was dangerous! You nearly got deleted!\nI hate those pesky viruses." $TEXTSPEED "<$AI>"
text "When did I catch it?" $TEXTSPEED "<$PLAYERNAME>"
text "I did not finished my security corrutine.\nIt must have slipped in at the moment." $TEXTSPEED "<$AI>"
text "Isn't it dangerous to move out?" $TEXTSPEED "<$PLAYERNAME>"
text "No, just make yourself simple firewall file in your Inventory.\nI will upload some data inside to protect you from specific types of viruses." $TEXTSPEED "<$AI>"

text "##########" 0.02
echo "Create file \"firewall\" inside your Inventory:"
useCommand "touch Inventory/firewall" "touch ./Inventory/firewall" "> Inventory/firewall" "> ./Inventory/firewall"

text "Now I add some data inside..." $TEXTSPEED "<$AI>"
text "..." 1
echo -e "*virus-AN-01*\nseverity=4\nremovable=Y\nprotected=Y\ncheckID=AN01S4\n#***" >> Inventory/firewall
text "Done! You can check it. Read the file." $TEXTSPEED "<$AI>"

text "##########" 0.02
echo "Read contents of firewall file (located in your Inventory directory):"
useCommand "cat Inventory/firewall" "cat ./Inventory/firewall"

text "Now you are ready to go!" $TEXTSPEED "<$AI>"

pressKey
clear