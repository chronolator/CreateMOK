#!/bin/bash 

#Add this to the scipts that need to include this file
##Includes
#DIR="${BASH_SOURCE%/*}"
#if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
#. "$DIR/include.sh"

#Ansi Escape Colors
be="\e["
c=("30m" "31m" "32m" "33m" "34m" "35m" "36m" "37m" "1;30m" "1;31m" "1;32m" "1;33m" "1;34m" "1;35m" "1;36m" "1;37m")
cm=("30" "31" "32" "33" "34" "35" "36" "37" "1;30" "1;31" "1;32" "1;33" "1;34" "1;35" "1;36" "1;37")
ee="\e[0m"

#FUNCTIONS
#Advanced all-in-one function
#$1 modes include:
#0 = title, command
#1 = title, error message, command
#2 = yellow info message
#Ex: allcheck 0 "Creating a file" touch coolfile.txt
function allcheck() {
    if [[ $1 == "1" ]]; then
        echo -e "$be${c[2]}+$2+$ee"
        "${@:4}" 
        status=$?
        if (( status != 0 )); then
            echo -ne "$be${c[1]}-Error "
            echo -e "$3-$ee" | sed 's/^[A-Z]/\L&/g'
            exit
        fi
    elif [[ $1 == "2" ]]; then
        echo -e "$be${c[11]}$2$ee"
    else
        #"${@:3}" &> /dev/null
        #status=$?
        echo -e "$be${c[2]}+$2+$ee"
        "${@:3}" 
        status=$?
        if (( status != 0 )); then
            echo -ne "$be${c[1]}-Error "
            echo -e "$2-$ee" | sed 's/^[A-Z]/\L&/g'
            exit
        fi
    fi  
    echo "" 
}

#Used by the check() function
#$1 = modes include: 
#0 = display an message
#1 = display an error message
function info() {
    #code=$1
    #name=$2
    if [[ $1 == 0 ]]; then
        echo -e "$be${c[2]}+$2+$ee"
    else
        echo -e "$be${c[1]}-Error "
        echo -e "$2-$ee" | sed 's/^[A-Z]/\L&/g'
        exit
    fi
}

#Basic all-in-one function for running commands and checking the execution status
function check() {
    "${@:2}" 2> /dev/null
    #"${@:2}"
    #local status=$?
    status=$?
    if (( status != 0 )); then
        info 1 "$1"
    fi
    echo ""
}

#Checks if previous command was successful
#$1 = Error message
function ifcheck() {
    if [[ `echo $?` != 0 ]]; then
      echo -e "$be${c[1]}-Error $1-$ee"
      exit 1
    fi
}

#Checks if user is running as root
function rootcheck() {
    if [ "$EUID" -ne 0 ]; then
      echo "Please run as root"
      exit 1
    fi
}

#Does a yes or no phrase 
function yesno() {
    while true; do
        read -p "$(echo -e $be${c[11]}$* [y/n]: $ee)" yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}
