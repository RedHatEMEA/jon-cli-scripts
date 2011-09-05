#function - cliCommandsMenu (cliScriptFolder) - menu to show all CLI scripts
function cliCommandsMenu () {

	CLI_SCRIPT_FOLDER=$1
	PARAMS_REQ=
	PARAMS_OPT=
	while true;
	do
		menuHeader "CLI Scripts"
		COUNT=1
		for f in `find $CLI_SCRIPT_FOLDER -name "*.js"`
		do
			echo $COUNT. $f
			USAGE=`grep "//Usage: " $f`
			echo ${USAGE#*\/\/}
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
				echo Invalid input, please enter a value between 1 and $COUNT
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
					echo Input required $PARAM:
					read INPUT_PARAM
					PARAMS_STRING="${PARAMS_STRING} ${INPUT_PARAM}"
				done

				#Read the optional parameters
				for PARAM in $PARAMS_OPT
				do
					echo Input optional $PARAM:
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
