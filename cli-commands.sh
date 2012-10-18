#Load user set variables
. cli-user-settings.sh

#function - cliCommandsMenu (cliScriptFolder) - menu to show all CLI scripts
function cliCommandsMenu () {

	CLI_SCRIPT_FOLDER=$1
	PARAMS_REQ=
	PARAMS_OPT=

	while true;
	do
		menuHeader "CLI Scripts"
		COUNT=1

		CURRENT_DIR=`pwd`
		CLI_DIR=${CURRENT_DIR}/CLI
		for f in `find ${CLI_DIR} -name "*.js"`
		do
			PARAMS_STRING=
			#Read the required parameters
			PARAMS_REQ=`grep "//Params Required: " $f`
			PARAMS_REQ=${PARAMS_REQ#*\/\/Params Required: }
			for PARAM in $PARAMS_REQ
			do
				PARAMS_STRING="${PARAMS_STRING} ${PARAM}"
			done

			#Read the optional parameters
			PARAMS_OPT=`grep "//Params Optional: " $f`
			PARAMS_OPT=${PARAMS_OPT#*\/\/Params Optional: }
			for PARAM in $PARAMS_OPT
			do
				PARAMS_STRING="${PARAMS_STRING} [${PARAM}]"
			done

			echo "$COUNT. $f"
			USAGE=`grep "//Usage: " $f`
			DESC=`grep "//Description: " $f`
			echo "${USAGE#*\/\/} ${PARAMS_STRING}"
			echo "${DESC#*\/\/}"
			CLI_CMD_ARRAY[$COUNT]=$f
			COUNT=$(( $COUNT + 1 ))
			newLine
		done

		menuFooter
		option=`takeInputOption`
		newLine

		if [[ "$option" == "b" || "$option" == "q" ]]; then
			basicMenuOptions $option
		else
			if [[ "$option" != +([0-9]) || "$option" -lt "1" || "$option" -gt "$COUNT" ]]; then
				echo "Invalid input, please enter a value between 1 and $COUNT"
			else
				PARAMS_STRING=

				#Check for required params
				PARAMS_REQ=`grep "//Params Required: " ${CLI_CMD_ARRAY[$option]}`
				PARAMS_REQ=${PARAMS_REQ#*\/\/Params Required: }

				#Check for optional params				
				PARAMS_OPT=`grep "//Params Optional: " ${CLI_CMD_ARRAY[$option]}`
				PARAMS_OPT=${PARAMS_OPT#*\/\/Params Optional: }
			
				#Read the required parameters
				for PARAM in $PARAMS_REQ
				do
					echo "Input required $PARAM:"
					read INPUT_PARAM
					PARAMS_STRING="${PARAMS_STRING} ${INPUT_PARAM}"
				done

				#Read the optional parameters
				for PARAM in $PARAMS_OPT
				do
					echo "Input optional $PARAM:"
					read INPUT_PARAM
					PARAMS_STRING="${PARAMS_STRING} ${INPUT_PARAM}"
				done
				newLine
			
				#Call the JS script with the appropiate params
				getRHQCLIDetails
 				$CLI_COMMAND -f ${CLI_CMD_ARRAY[$option]} ${PARAMS_STRING}
			fi
		fi

		pause
	done
}

#function - menuHeader (menuTitle) - outputs the menu title, with *s below and a new line 
function menuHeader () {
	MENU_TITLE=$1
	
	clear
	
	echo $MENU_TITLE
	TITLE_LENGTH=${#MENU_TITLE}
	
	for ((  i = 0 ;  i <= $TITLE_LENGTH;  i++  ))
	do
		echo -ne "*"
	done
	newLine	
}

#function - menuFooter () - outputs the quit option and reads the variable
function menuFooter () {

	newLine
	echo Q. Quit

	newLine
	echo Choose an option:
}

#function - takeInputOption () - takes in an option as input and <retuns> the option 
function takeInputOption() {

	read option
	option=`lowercase $option`
	echo $option	
}

#function - basicMenuOptions (option) - case stmt used at the end of every menu *) options, handles (b)ack, (q)uit and wrong inputs
function basicMenuOptions() {
	option=$1
	case $option in
		"q" | "Q" ) 
			exit
			;;
		
		*) 
			newLine
			echo Wrong input... please input correct selection
			;;
	esac
	
}

#function - newLine () - to output an empty line
function newLine () {
	echo -e "\t"
}

#function - pause () - to pause command line
function pause () {
	read -p "Press any key to continue..."
}

#function - lowercase (input) - convert input to lowercase
function lowercase () {
	INPUT=$1
	
	OUTPUT=`tr '[:upper:]' '[:lower:]' <<<"$INPUT"`
	echo $OUTPUT
}

#function - getRHQCLIDetails () - sets up the CLI required variables
function getRHQCLIDetails () {

	export RHQ_CLI_JAVA_HOME=$JAVA_HOME
	RHQ_OPTS="-s $JON_HOST -u $JON_USER -t $JON_PORT -p $JON_PWD"

	if [[ -d $CLI_CLIENT ]]; then
		CLI_COMMAND=`find $CLI_CLIENT -name "rhq*cli.sh"`
	else
		echo "ERROR: JON Tools not installed, quitting."
		exit
	fi
}

cliCommandsMenu
