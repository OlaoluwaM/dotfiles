PS1='\[\033]0;Olaminal: $PWD\007\]' # Change terminal title

PS1="$PS1"'\n'                      # new line
PS1="$PS1"'\[\033[35m\]'            # change to magenta
PS1="$PS1"'[\A] \w'                 # Show [time] and current working directory

# For git implementation
if test -z "$WINELOADERNOEXEC"
	then
		GIT_EXEC_PATH="$(git --exec-path 2>/dev/null)"
		COMPLETION_PATH="${GIT_EXEC_PATH%/libexec/git-core}"
		COMPLETION_PATH="${COMPLETION_PATH%/lib/git-core}"
		COMPLETION_PATH="$COMPLETION_PATH/share/git/completion"
		if test -f "$COMPLETION_PATH/git-prompt.sh"
		then
			. "$COMPLETION_PATH/git-completion.bash"
			. "$COMPLETION_PATH/git-prompt.sh"
			PS1="$PS1"'\[\033[34m\]'  # change color to purple
			PS1="$PS1"'`__git_ps1`'   # bash function
		fi
	fi

PS1="$PS1"'\[\033[m\]'				 # Reset Color
PS1="$PS1"'\[\033[36m\]'       # change to green
PS1="$PS1"'\n'                 # new line
PS1="$PS1"'➜  '               # change prompt to ->
PS1="$PS1"'\[\033[1m\]'

MSYS2_PS1="$PS1"
