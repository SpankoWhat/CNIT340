#!/bin/bash
#Name: Waleed Nasr
#Purpose: Complete Lab 4 in CNIT 340 
#Last Revision Date:  12/10/2021
#Variables:
##ARG1=$1 takes file

ARG1=$1


if [[ -f $ARG1 ]]; then 
    printf "Are you sure you want to restore backup: $ARG1\n"
    select answer in Yes No; do
        case $answer in
            "Yes")
                tar --overwrite -xzf $ARG1 -C /
                ;;
            "No")
                printf "Aborting..."
                ;;
        esac
        break;
    done
else
    printf "Not a valid file..Aborting"
fi
