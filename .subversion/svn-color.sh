#!/bin/bash
# Coming from JM Lacroix "svn-color" https://github.com/jmlacroix/svn-color

# Check if svn is available
svn status &>/dev/null || return 1

# Keep svn full path to call
fullsvnpath=$(which svn)

function svn {
	# rebuild args to get quotes right
	CMD=
	for i in "$@"
	do
		if [[ "$i" =~ \  ]]
		then
			CMD="$CMD \"$i\""
		else
			CMD="$CMD $i"
		fi
	done

	# pad with spaces to strip --nocol
	CMD=" $CMD "
	CMDLEN=${#CMD}

	# parse disabling arg
	CMD="${CMD/ --nocol / }"

	# check if disabled
	test "$CMDLEN" = "${#CMD}"
	NOCOL=$?
	if [ "$SVN_COLOR" != "always" ] && ( [ $NOCOL = 1 ] || [ "$SVN_COLOR" = "never" ] || [ ! -t 1 ] )
	then
		eval "$fullsvnpath $CMD"
		return
	fi

	# supported svn actions for "status-like" output
	ACTIONS="add|checkout|co|cp|del|export|remove|rm|st"
	ACTIONS="$ACTIONS|merge|mkdir|move|mv|ren|sw|up"

	# actions that outputs "status-like" data
	if [[ "$1" =~ ^($ACTIONS) ]] && [ "$1" != "commit" ]
	then
		eval "$fullsvnpath $CMD" | while IFS= read -r RL
		do
			if   [[ $RL =~ ^\ ?M ]]; then C="\033[34m";
			elif [[ $RL =~ ^\ ?C ]]; then C="\033[41m\033[38;5;15m";
			elif [[ $RL =~ ^A ]]; then C="\033[38;5;10m";
			elif [[ $RL =~ ^D ]]; then C="\033[38;5;9m";
			elif [[ $RL =~ ^X ]]; then C="\033[37m";
			elif [[ $RL =~ ^! ]]; then C="\033[43m\033[38;5;15m";
			elif [[ $RL =~ ^I ]]; then C="\033[33m";
			elif [[ $RL =~ ^R ]]; then C="\033[35m";
			else C=
			fi

			echo -e "$C${RL/\\/\\\\}\033[0m\033[0;0m"
		done

	# actions that outputs "diff-like" data
	elif [[ "$1" =~ ^diff ]]
	then
		eval "$fullsvnpath $CMD" | while IFS= read -r RL
		do
			if   [[ $RL =~ ^Index:\  ]]; then C="\033[38;5;12m";
			elif [[ $RL =~ ^@@ ]]; then C="\033[38;5;14m";

			# removed
			elif [[ $RL =~ ^-\<\<\< ]]; then C="\033[38;5;9m";
			elif [[ $RL =~ ^-\>\>\> ]]; then C="\033[38;5;9m";
			elif [[ $RL =~ ^-=== ]]; then C="\033[38;5;9m";
			elif [[ $RL =~ ^- ]]; then C="\033[31m";

			# added
			elif [[ $RL =~ ^\+\<\<\< ]]; then C="\033[38;5;10m";
			elif [[ $RL =~ ^\+\>\>\> ]]; then C="\033[38;5;10m";
			elif [[ $RL =~ ^\+=== ]]; then C="\033[38;5;10m";
			elif [[ $RL =~ ^\+ ]]; then C="\033[32m";

			else C=
			fi

			echo -e "$C${RL/\\/\\\\}\033[0m\033[0;0m"
		done
	else
		eval "$fullsvnpath $CMD"
	fi
}
