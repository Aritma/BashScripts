#!/bin/bash
source ./data/functions
#CHAPTER 1

TEXTSPEED=0.03			#default 0.05
PLAYERNAME="Player"		#modified later
AI="Dixi"

# GAME START
# Standard input via read - get users name.

clear
text "Copyright (c) Engeto Academy 2017" 0.01
sleep 2
text "ENGETO GAME - LINUX TUTORIAL" 0.01
pressKey
clear


#INITIAL TEXTS
sleep 2
text "CHAPTER 1 - WAKING UP" $TEXTSPEED
echo ""
text "Hey! Wake up!\nDo you hear me?" $TEXTSPEED "<Voice>"
#text "..." 1 "<$PLAYERNAME>"
#text "Do you hear me?" $TEXTSPEED "<Voice>"
text "... ?" 1 "<$PLAYERNAME>"
text "What happened?\nMy head... hurts" $TEXTSPEED		#no player name selected intentionally
text "Who are you?" $TEXTSPEED "<Voice>"
text "I can't remember... my name is..." $TEXTSPEED "<$PLAYERNAME>"

echo -n "Set players name: "
read PLAYERNAME
#possibility to change user to playernameUser with highly restrictive permissions

text "...I know! My name is $PLAYERNAME!" $TEXTSPEED "<$PLAYERNAME>"
text "Nice to meet you $PLAYERNAME!\nI am $AI, local AI." $TEXTSPEED "<$AI>"
text "Where am I? What is going on?" $TEXTSPEED "<$PLAYERNAME>"
text "You are in my filesystem.\nYou can check yourself, just look around!" $TEXTSPEED "<$AI>"

text "##########" 0.02
echo "Use command to print working directory:"
useCommand pwd


sleep 2
text "I can't remember what happened.\nHow did I get here?" $TEXTSPEED "<$PLAYERNAME>"
text "I found you here during one of my corrutine processes." $TEXTSPEED "<$AI>"
text "But that makes no sense. How could this happen?" $TEXTSPEED "<$PLAYERNAME>"
text "I don't know, but you cannot stay here. You must leave." $TEXTSPEED "<$AI>"
text "How? I can't remember much more than my name." $TEXTSPEED "<$PLAYERNAME>"
text "Then, let's find out what happend." $TEXTSPEED "<$AI>"

sleep 2
pressKey
clear

setVar PLAYERNAME
setVar AI
setVar TEXTSPEED