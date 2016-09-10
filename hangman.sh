#!/bin/bash
#Hangman script


#========================================================================================================
#GLOBAL VARS
lives=10
finished=0
guess=""
#set random word from list for new game
WORDS=("linux" "fedora" "ubuntu" "redhat" "torvalds" "engeto" "github" "microsoft" "heckathon" "penguin")
randomnum=${RANDOM:0:1}
randomword=${WORDS[$randomnum]}


#========================================================================================================
#DRAW HANGMAN
drawHangman() {
    case $lives in
    9)
    echo "    "
    echo "    |"
    echo "    |"
    echo "    |"
    echo "    |"
    ;;
    8)
    echo "____"
    echo "    |"
    echo "    |"
    echo "    |"
    echo "    |"
    echo "    |"
    ;;
    7)
    echo "____"
    echo "   \|"
    echo "    |"
    echo "    |"
    echo "    |"
    echo "    |"
    ;;
    6)
    echo "____"
    echo " | \|"
    echo "    |"
    echo "    |"
    echo "    |"
    echo "    |"
    ;;
    5)
    echo "____"
    echo " | \|"
    echo " O  |"
    echo "    |"
    echo "    |"
    echo "    |"
    ;;
    4)
    echo "____"
    echo " | \|"
    echo " O  |"
    echo " |  |"
    echo "    |"
    echo "    |"
    ;;
    3)
    echo "____"
    echo " | \|"
    echo " O  |"
    echo "/|  |"
    echo "    |"
    echo "    |"
    ;;
    2)
    echo "____"
    echo " | \|"
    echo " O  |"
    echo "/|\ |"
    echo "    |"
    echo "    |"
    ;;
    1)
    echo "____"
    echo " | \|"
    echo " O  |"
    echo "/|\ |"
    echo "/   |"
    echo "    |"
    ;;
    0)
    echo "____"
    echo " | \|"
    echo " O  |"
    echo "/|\ |"
    echo "/ \ |"
    echo "    |"
    ;;
    *)
    echo "ERROR: This line should not be visible, check the script code for bugs."
    ;;
    esac
}

#MAIN CODE BLOCK

#========================================================================================================
#prepare empty check array for word
charnum=${#randomword}
CHECKARRAY=()
for (( i=0; i<$charnum; i++ ))
do
    CHECKARRAY[$i]=0
done

#========================================================================================================
#translate input to lowercase only
getInput(){
    read input
    guess=$(echo $input | tr '[:upper:]' '[:lower:]')
}
#========================================================================================================
#print known letters of word
printKnown() {
    echo -n "WORD: "
    for (( i=0; i<$charnum; i++ ))
    do
        if [ ${CHECKARRAY[$i]} == 0 ]
        then
            echo -n "-"
        else
            echo -n ${randomword:i:1}
        fi
    done
    echo -n "          LIVES: ($lives)"
    for (( l=0; l<$lives; l++ ))
    do
        echo -n "♥"
    done
    echo ""
}


#========================================================================================================
#test geuessed word and fill it if it is valid or remove live if not valid
guessLetter() {
    valid=0
    for (( i=0; i<$charnum; i++ ))
    do
        if [ ${randomword:i:1} == $1 ]
        then
            echo ""
            CHECKARRAY[$i]=1
            valid=1
        fi
    done
    if [ $valid -eq 0 ]
    then
        lives=$(($lives-1))
        echo "Not valid letter"
        echo ""
        drawHangman
    else
        echo "Yeah, right. Try more."
    fi
}
#========================================================================================================
#ALREADY USED TEST
alreadyUsed() {
    used=1
    for (( i=0; i<$charnum; i++ ))
    do
        if [ ${randomword:i:1} == $1 ] && [ ${CHECKARRAY[$i]} == 1 ]
        then
            used=0
        fi
    done
    return $used;
}

#========================================================================================================
#script start
echo "Hangman game: Write one letter to guess a letter contained in the word."
echo "Write whole word or finish all letters to win."

echo "Press enter to start..."
read
echo "Total $charnum chars."

#========================================================================================================
#main cycle
while [ $finished -eq 0 ]
do
    printKnown
    echo -n "Your next guess: "
    getInput
    
    while true
    do
        #if input string have same size as word
        if [ ${#guess} -eq $charnum ]
        then
            if [ $guess == $randomword ]
            then
                echo "RIGHT! You win!"
                exit
            else
                echo "No, wrong..."
                lives=$(($lives-1))
                drawHangman
                break
            fi
        #if input string size is 1
        elif [ ${#guess} -eq 1 ]
        then
            if $(alreadyUsed $guess)
            then
                echo -n "You already know this one. Try again: "
                getInput
            else
                guessLetter $guess
                break
            fi
        #if input string have other length
        else
            echo -n "Wrong input, try again: "
            getInput
        fi
    done
    
    finished=1
    for (( i=0; i<$charnum; i++ ))
    do
        if [ ${CHECKARRAY[$i]} == 0 ]
        then
            finished=0
        fi
    done
    
    if [ $finished -eq 1 ]
    then
        echo "RIGHT! You win!"
        exit
    fi
    
    if [ $lives -le 0 ]
    then
        echo "FAIL! You lost."
        exit
    fi
    echo "-------------------------------------------"
done
