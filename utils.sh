#! /usr/bin/env bash

if [ -t 0 ]
then
    NORMAL=$(tput sgr0)
fi

# Utils
_success () {
    if [ -t 0 ]
    then
        local GREEN=$(tput setaf 2)
        echo -e "${GREEN}Done with $1 ${NORMAL}\n"
    else
        printf "Done with $1 \n"
    fi
}
_failure () {
    if [ -t 0 ]
    then
        local RED=$(tput setaf 1)
        echo -e "${RED}FAILURE: $1 ${NORMAL}\n"
    else
        printf "FAILURE: $1 \n"
    fi
}
