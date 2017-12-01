#!/bin/bash
source ./functions
#CHAPTER 1

TEXTSPEED=0.03			#default 0.05
PLAYERNAME="Player"		#modified later
AI="Risi"

# GAME START
# Standard input via read - get users name.

clear
text "Copyright (c) Engeto Academy 2017" 0.01
sleep 2
text "ENGETO GAME - LINUX TUTORIAL" 0.01
pressKey
clear

#####################
# Game start

sleep 2
text "You woke up. Your head hurts and you feel kinda confused." $TEXTSPEED

echo -en "Look around! (use command to print working directory):\n"
useCommand "pwd"

text "You are in small empty room with black walls." $TEXTSPEED
text "There is no light but still you see without any problems." $TEXTSPEED
text "..." 2
text "Who are you?" $TEXTSPEED "<UnknownVoice>"
text "You stay quiet"
text "Hey! Who are you and what are you doing here?" $TEXTSPEED "<UnknownVoice>"
text "Little blue light suddenly appeared next to you."
