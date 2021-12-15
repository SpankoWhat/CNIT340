#!/bin/bash
#Name: Waleed Nasr
#Purpose: Complete Lab 3 in CNIT 340 
#Last Revision Date:  11/11/2021
#Variables:
#ARG1 = takes in the desired command
#ARG2 = takes in the first variable
#ARG3 = takes in the second variable

#Resources used
#https://github.com/LeCoupa/awesome-cheatsheets/blob/master/languages/bash.sh
#/mnt/e/Waleed Osama/Documents/_Purdue University/_2021 Fall/CNIT 340/Lab 3/Testing_Ground

#read arguments ..
ARG1=${1,,}  #ARG1 = takes in the desired command 
ARG2=$2  #ARG2 = takes in the first variable
ARG3=$3  #ARG3 = takes in the second variable 
ARGUMENTS=( 
	"author: No arguments required"
	"type:<file path>"
	"copy:<file path> <new name> (use copy! to override)"
	"ren:<file path> <new name> (use ren! to override)"
	"move:<from> <to> (use move! to override)"
	"del:<file path>"
	"perm:<file path> <chmod [07]>"
	"group: <file path> <group ID>"
	"help:No arguments required"
) # Used to loop through the varias function and their required arguments

#COLOR variables
COLOR_OFF="\033[0m"
RED="\033[0;31m" 
GREEN="\033[0;32m"
YELLOW="\033[0;33m"


#Used to go format the arguments properly and displays them
helper () {
	for func in "${ARGUMENTS[@]}" ; do
    	KEY="${func%%:*}"
    	VALUE="${func##*:}"
    	printf "${RED}$KEY${COLOR_OFF} requries: $VALUE.\n"  
	done
}

#helper function make stuff look nice
printColored () {
	case $1 in
		r )
			echo -e "${RED}"
			;;
		g )
			echo -e "${GREEN}"
			;;
		y )	
			echo -e "${YELLOW}"
			;;
	esac

	printf "\n$2\n"
	echo -e "${COLOR_OFF}"
}


#Helper function to print out errors
printError () {
	printColored r "Not a valid file or directory"
	printColored r "Aborting...."
}

#Checks if a user input is a file or not. If file or directory return 0 otherwise 1
typecheck () {
	case $1 in
		f )
			if [[ -f $2 ]]; then 
				return 0
			fi;;
		d )
			if [[ -d $2 ]]; then 
				return 0
			fi;;
	esac
	return 1
}

#A helper fucntion to copy file/directory
copy_me () {
	if typecheck f $2  
	then 
		typecheck f $3
		if [[ $? = 1 || $1 = 0 ]];  then 
			cp $2 $3 > /dev/null 2>&1
			printColored g "+Unix command ran: <cp $2 $3> successfully"
			return 0
		else
			printColored y "-File already exists..Aborting..."
			return 1
		fi
	elif typecheck d $2 
	then
		typecheck d $3
		if [[ $? = 1 || $1 = 0 ]]; then 
			cp -r $2 $3 > /dev/null 2>&1
			printColored g "+Unix command ran: <cp -r $2 $3> successfully"
			return 0
		else
			printColored y "-Directory already exists..Aborting..."
			return 1
		fi
	fi
	printError
}

#Handles the renam logic, including existing files and overides
rename_me () {
	if typecheck f $2  
	then 
		typecheck f $3
		if [[ $? = 1 || $1 = 0 ]]
		then 
			mv $2 $3 > /dev/null 2>&1
			printColored g "+Unix command ran: <mv $2 $3> successfully"
			return 0
		else
			printColored y "-File already exists..Aborting..."
			return 1
		fi
	elif typecheck d $2 
	then
		typecheck f $3
		if [[ $? = 1 || $1 = 0 ]]
		then 
			mv $2 $3 > /dev/null 2>&1
			printColored g "+Unix command ran: <mv $2 $3> successfully"
			return 0
		else
			printColored y "-Directory already exists..Aborting..."
			return 1
		fi
	fi
	printError
}

#Handles the move logic, including existing files and overides
move_me () {
	if typecheck f $2  
	then 
		typecheck f "$3/$2"
		if [[ $? = 1 || $1 = 0 ]]
		then 
			mv $2 $3 > /dev/null 2>&1
			printColored g "+Unix command ran: <mv $2 $3> successfully"
			return 0
		else
			printColored y "-File already exists..Aborting..."
			return 1
		fi
	elif typecheck d $2 
	then
		typecheck d "$3/$2"
		if [[ $? = 1 || $1 = 0 ]]
		then 
			mv $2 $3 > /dev/null 2>&1
			printColored g "Unix command ran: <mv $2 $3> successfully"
			return 0
		else
			printColored y "Directory already exists..Aborting..."
			return 1
		fi
	fi
	printError
}

#Handles the deelte logic, including existing files and overides
delete_me () {
	if typecheck f $1; then 
		rm $1 > /dev/null 2>&1
		printColored g "+Unix command ran: <rm $1> successfully"
		return 0
	elif typecheck d $1; then
		rm -d $1 > /dev/null 2>&1
		printColored g "+Unix command ran: <rm -d $1> successfully"
		return 0
	fi
	printError
}

#changin permissions to a file
changePerm () {
	chmod $2 $1 > /dev/null 2>&1
	if [[ $? = 0 ]]; then 
		printColored g "+Unix command ran: <chmod $2 $1> successfully"
	else
		printColored r "-Unix command ran: <chmod $2 $1> FAILED..."
	fi
}

#changing permissions to a file
changeGroup () {
	chgrp $2 $1 > /dev/null 2>&1
	if [[ $? = 0 ]]; then 
		printColored g "+Unix command ran: <chgrp $3 $2> successfully"
	else
		printColored R "-Unix command ran: <chgrp $3 $2> FAILED..."
	fi
}

sortList () {
	select optionChosen in "name" "age" "size"; do
		case $optionChosen in
				"name")
					ls -l
					;;
				"age")
					ls -lt
					;;
				"size" )
					ls -lS
					;;
			esac
		break;
	done
}

#Uses select to navigate the options
interactiveMenu (){
	#sketchy way of storing the options/should use a smarter way
	args=("author" "type" "sort" "copy" "copy!" "ren" "ren!" "move" "move!" "del" "perm" "group" "help")
	singleLines=("author" "help" "sort")
	#changing the defualt select carrot
	PS3="Select an option: "

	#changing the delimiter to account for spaces in the select loop
	OLD_IFS=${IFS}
	IFS="
	"
	
	#menu options
	select optionChosen in ${args[@]}
	do
		#skips file selection for uncessary options, however implimentation is very limited.
		#Must use a smarter way: check if item is in list rather than an or list
		if [[  "$optionChosen" == "author" || "$optionChosen" == "help"  || "$optionChosen" == "sort" ]]; then 
			case $optionChosen in
				"author")
					printf "Waleed Nasr\n"
					;;
				"help")
					helper
					;;
				"sort" )
					sortList
					;;
			esac
		else
			PS3="Select a file: "
			select fileOne in $(ls); do
				case $optionChosen in
					"type")
						printColored o "$fileOne content:\n $(cat $fileOne)"
						;;
					"del")
						delete_me $fileOne
						;;
					#copies users input
					"copy")
						read -p "Copy name:" inputS
						copy_me 1 $fileOne $inputS 
						;;
					"copy!" )
						read -p "Copy name:" inputS
						copy_me 0 $fileOne $inputS 
						;;
					#renames the file
					"ren")
						read -p "Rename to:" inputS
						rename_me 1 $fileOne $inputS 
						;;
					"ren!")
						read -p "Rename to:" inputS
						rename_me 0 $fileOne $inputS 
						;;
					#moves the file
					"move")
						read -p "Move to:" inputS
						move_me 1 $fileOne $inputS 
						;;
					"move!")
						read -p "Move to:" inputS
						move_me 0 $fileOne $inputS 
						;;
					#changes file permissions
					"perm")
						read -p "CODE:" inputS
						changePerm $fileOne $inputS 
						;;
					#Changes file group owner
					"group")
						read -p "Group/GID:" inputS
						changeGroup $fileOne $inputS 
						;;											
				esac
				break;
			done
		fi
		break;
	done
	IFS=${OLD_IFS}
}

#Chooses a specific set of operations
menuSelector (){
	case $1 in
		#prints author info
		"author")
			printf "Waleed Nasr\n" ;;
		#prints file contents
		"type")
			printColored o "Content:\n $(cat $2)" ;;
		#copies users input
		"copy")
			copy_me 1 $2 $3 ;;
		"copy!" )
			copy_me 0 $2 $3 ;;
		#renames the file
		"ren")
			rename_me 1 $2 $3 ;;
		"ren!")
			rename_me 0 $2 $3 ;;
		#moves the file
		"move")
			move_me 1 $2 $3 ;;
		"move!")
			move_me 0 $2 $3 ;;
		#deletes the file
		"del")
			delete_me $2 ;;
		#changes permisions using chmod
		"perm")
			changePerm $2 $3 ;;
		#changing file group owner
		"group")
			changeGroup $2 $3 ;;
		"sort")
			sortList ;;					
		#helps the user
		"help")
			helper ;;
		#Any other command comes here
		*)
			interactiveMenu ;;
	esac
}

#starter function
menuSelector $ARG1 $ARG2 $ARG3

#successful escape code
exit 0
