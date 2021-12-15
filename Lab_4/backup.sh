#!/bin/bash
#Name: Waleed Nasr
#Purpose: Complete Lab 4 in CNIT 340 
#Last Revision Date:  12/10/2021
#Variables:
##BACKUPNAMES = holds all the different types of backups
##COMPRESSION = compression program
##EMAIL = the e-mail address who which the daily log should be sent
##BACKUP_TARGET =  filesystem in which to store the backup files
##TARGET_TYPE = type of filesystem used for backup_target
##TARGET_SERVER = DNS name of target server if not local
##TARGET_FS = filesystem/share/export on the target server that will be mounted to backup_target
##USER = username for SMB target
##PASSWORD = password for user
##ARG1=$ name of backup
##ARG2=$2 options
##CHOSENBACKUP= to store the back the user chose
##BACKUPNAMES= to store all configs

declare -A BACKUPNAMES
CHOSENBACKUP=""
ARG1=$1
ARG2=$2

# Function that gets the values of the variable from the file called backup.txt.
getValues () {
    # removes all text that starts with #
    valueList=$(sed '/^\#/d' backup.conf)

    #removes all spaces to make formating much more consistent
    valueList=${valueList// /}

    # Assigning the appropriate value to each variable
    for commandLine in ${valueList[@]}; do
        #string manipulation
        COMMAND="${commandLine%%=*}"
        VALUE="${commandLine##*=}"
        
        # case satement to assign values
        case $COMMAND in
            "COMPRESSION")
                COMPRESSION=$VALUE
                ;;
            "E-MAIL")
                EMAIL=$VALUE
                ;;
            "BACKUP_TARGET")
                BACKUP_TARGET=$VALUE
                ;;
            "TARGET_TYPE")
                TARGET_TYPE=$VALUE
                ;;
            "TARGET_SERVER")
                TARGET_SERVER=$VALUE
                ;;
            "TARGET_FS")
                TARGET_FS=$VALUE
                ;;
            "USER")
                USER=$VALUE
                ;;
            "PASSWORD")
                PASSWORD=$VALUE
                ;;
            *)
                #assigning local varaibles to a list in order to parse it later.
                local temp1=$(echo $COMMAND | cut -d":" -f1)
                local temp2=$(echo $COMMAND | cut -d":" -f2-)
                BACKUPNAMES[$temp1]=$temp2
                ;;
            esac
    done
}

# A simple print function that aids 
printListofDictionary () {
    printf "Current Backups:\n"
    for entry in "${!BACKUPNAMES[@]}"; do
        local optionsList=($(echo ${BACKUPNAMES[$entry]} | tr ':' ' '))
        printf "++Name: $entry\n"
        printf "++++Directory: ${optionsList[0]}\n"
        printf "++++Recursive: ${optionsList[1]}\n"
        printf "++++Daily Backups: ${optionsList[2]}\n"
        printf "++++Weekly Backups: ${optionsList[3]}\n"
        printf "++++Monthly Backups: ${optionsList[4]}\n"
    done
}

# A helper function to format the file name
formatFileName () {
    #storing date and time with proper format
    local dateValue=$(date +"%Y-%m-%d")
    local timeValue=$(date +"%H:%M")

    local format="$HOSTNAME.$CHOSENBACKUP.$dateValue.$timeValue" 
    echo $format
}

# A helper function to select user input option
chooseBackup () {
    for name in "${!BACKUPNAMES[@]}"; do
        if [[ "$name" = "$ARG1" ]]; then
            CHOSENBACKUP="$name"
            return 0    
        fi
    done
    return 1
}

# function to create a log file. Takes in one argument: the directory
createLog () {
    local dateValue=$(date +"%Y-%m-%d")
    local timeValue=$(date +"%H:%M")
    echo "LOGFILE: $dateValue  |  $timeValue
$(ls -R $1)" > "/var/log/backup/$CHOSENBACKUP.$dateValue.$timeValue"
}

#EXTRA CREDIT: removes any extra files specific in te config files.
#Probably one of the worst ways to do it.
removeExtraBackups () {
    local optionsList=($(echo ${BACKUPNAMES[$CHOSENBACKUP]} | tr ':' ' '))
    
    #Stores in the appropriate number and then uses the tail command and then xargs. Done for daily
    local num=$(( ${optionsList[2]} + 1 ))
    cd "$BACKUP_TARGET/daily"
    ls -1t "$BACKUP_TARGET/daily" | tail -n +$num | xargs rm > /dev/null 2>&1
    
    #Stores in the appropriate number and then uses the tail command and then xargs. Done for daily
    local num=$(( ${optionsList[3]} + 1 ))
    cd "$BACKUP_TARGET/weekly"
    ls -1t "$BACKUP_TARGET/weekly" | tail -n +$num | xargs rm > /dev/null 2>&1
    
    #Stores in the appropriate number and then uses the tail command and then xargs. Done for daily
    local num=$(( ${optionsList[4]} + 1 ))
    cd "$BACKUP_TARGET/monthly"
    ls -1t "$BACKUP_TARGET/monthly" | tail -n +$num | xargs rm > /dev/null 2>&1
}

createBackup () {
    #Temp variables to store file name and other values
    local optionsList=($(echo ${BACKUPNAMES[$CHOSENBACKUP]} | tr ':' ' '))
    local tempName=$(formatFileName)
    local tempSubDir=""

    # creating the dirsctories everytime this function is called.
    mkdir -p "$BACKUP_TARGET/adhoc"
    mkdir -p "$BACKUP_TARGET/daily"
    mkdir -p "$BACKUP_TARGET/weekly"
    mkdir -p "$BACKUP_TARGET/monthly"
    mkdir -p "/var/log/backup" 

    #EXTRA CREDIT::
    #Applies the proper directory subdirectory name
    case $ARG2 in
        "daily")
            tempSubDir="daily"
            ;;
        "weekly")
            tempSubDir="weekly"
            ;;
        "monthly")
            tempSubDir="monthly"
            ;;
        *)
            tempSubDir="adhoc"
    esac

    #Chooses compressing subdirectories or not. Currently the subdirectory implementation is too complix 
    case ${optionsList[1]} in
        Y)
            case $COMPRESSION in
                gzip)
                    tar -czf "$BACKUP_TARGET/$tempSubDir/$tempName.tar.gz" ${optionsList[0]}
                    ;;
                bz2)
                    printf "in progress"
                    ;;
            esac
            ;;
        N)
            case $COMPRESSION in
                gzip)
                    tar -czf "$BACKUP_TARGET/$tempSubDir/$tempName.tar.gz" ${optionsList[0]}
                    ;;
                bz2)
                    printf "in progress"
                    ;;
            esac
            ;;
        *)
            printf "Error"
            return 1
    esac

    #calls all helper functions
    createLog ${optionsList[0]}
    removeExtraBackups
    return 0
}

# read and set values
getValues

# parse user input
if ! chooseBackup; then
    printf "Error..Not valid backup..Aborting\n"
    exit 1
fi

# create backup and logs
createBackup
exit 0

# EXTRA CREDIT::
# cron configuration
# 0 14 * * * /usr/local/bin/backup.nasr testing daily
# 0 14 * * 0 /usr/local/bin/backup.nasr testing weekly 
# 0 14 1 * * /usr/local/bin/backup.nasr testing monthly