# To install source this file from your .zshrc file

# see documentation at http://linux.die.net/man/1/zshexpn
# A: finds the absolute path, even if this is symlinked
# h: equivalent to dirname
export __GIT_PROMPT_DIR=${0:A:h}

export GIT_PROMPT_EXECUTABLE=${GIT_PROMPT_EXECUTABLE:-"python"}

# Initialize colors.
autoload -U colors
colors

# Allow for functions in the prompt.
setopt PROMPT_SUBST

autoload -U add-zsh-hook

add-zsh-hook preexec preexec_update_git_vars
add-zsh-hook precmd precmd_update_git_vars

## Function definitions
function preexec_update_git_vars() {
    case "$2" in
        git*|hub*|gh*|stg*)
        __EXECUTED_GIT_COMMAND=1
        ;;
    esac
}

function precmd_update_git_vars() {
    if [ -n "$__EXECUTED_GIT_COMMAND" ] || [ ! -n "$ZSH_THEME_GIT_PROMPT_CACHE" ]; then
        update_current_git_vars
        unset __EXECUTED_GIT_COMMAND
    fi
}

function update_current_git_vars() {
    unset __CURRENT_GIT_STATUS
    unset GIT_STASHED
    _GIT_STATUS=""
    if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1 ; then
        if [[ "$GIT_PROMPT_EXECUTABLE" == "python" ]]; then
            local gitstatus="$__GIT_PROMPT_DIR/gitstatus.py"
            _GIT_STATUS=`python3 ${gitstatus} 2>/dev/null`
        fi
        if [[ "$GIT_PROMPT_EXECUTABLE" == "haskell" ]]; then
            _GIT_STATUS=`git status --porcelain --branch &> /dev/null | $__GIT_PROMPT_DIR/src/.bin/gitstatus`
        fi
        GIT_STASHED=$(git stash list | wc -l | xargs)
    fi
     __CURRENT_GIT_STATUS=("${(@s: :)_GIT_STATUS}")
	GIT_REMOTE=$__CURRENT_GIT_STATUS[1]
	GIT_BRANCH=$__CURRENT_GIT_STATUS[2]
	GIT_AHEAD=$__CURRENT_GIT_STATUS[3]
	GIT_BEHIND=$__CURRENT_GIT_STATUS[4]
	GIT_STAGED=$__CURRENT_GIT_STATUS[5]
	GIT_CONFLICTS=$__CURRENT_GIT_STATUS[6]
	GIT_CHANGED=$__CURRENT_GIT_STATUS[7]
	GIT_UNTRACKED=$__CURRENT_GIT_STATUS[8]
}


git_super_status() {
  if [ -n "$__CURRENT_GIT_STATUS" ]; then
    STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX"
    
    if [ -n "$GIT_REMOTE" ]; then
     STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_REMOTE$GIT_REMOTE%{${reset_color}%} → " 
    fi
	  
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BRANCH$GIT_BRANCH%{${reset_color}%}"
	  
    if [ "$GIT_BEHIND" -ne "0" ]; then
		  STATUS="$STATUS $ZSH_THEME_GIT_PROMPT_BEHIND$GIT_BEHIND%{${reset_color}%}"
	  fi
	  
    if [ "$GIT_AHEAD" -ne "0" ]; then
		  STATUS="$STATUS $ZSH_THEME_GIT_PROMPT_AHEAD$GIT_AHEAD%{${reset_color}%}"
	  fi
	  
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR"
    previousExists=0
	  
    if [ "$GIT_STAGED" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED%{${reset_color}%}"
      previousExists=1
	  fi
    
    if [ "$GIT_CONFLICTS" -ne "0" ]; then
      if [ "$previousExists" -ne "0" ]; then
        # Add a space between the elements
        STATUS="$STATUS "
      fi
      previousExists=1
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS$GIT_CONFLICTS%{${reset_color}%}"
	  fi
	  
    if [ "$GIT_CHANGED" -ne "0" ]; then
      if [ "$previousExists" -ne "0" ]; then
        # Add a space between the elements
        STATUS="$STATUS "
      fi
      previousExists=1
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED$GIT_CHANGED%{${reset_color}%}"
	  fi
	  
    if [ "$GIT_UNTRACKED" -ne "0" ]; then
      if [ "$previousExists" -ne "0" ]; then
        # Add a space between the elements
        STATUS="$STATUS "
      fi
      previousExists=1
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED$GIT_UNTRACKED%{${reset_color}%}"
	  fi
	  
    if [ "$GIT_CHANGED" -eq "0" ] && [ "$GIT_CONFLICTS" -eq "0" ] && [ "$GIT_STAGED" -eq "0" ] && [ "$GIT_UNTRACKED" -eq "0" ]; then
      if [ "$previousExists" -ne "0" ]; then
        # Add a space between the elements
        STATUS="$STATUS "
      fi
      previousExists=1
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
	  fi
	  
    STATUS="$STATUS%{${reset_color}%}$ZSH_THEME_GIT_PROMPT_SUFFIX"
    
    if [ "$GIT_STASHED" -ne "0" ]; then
      if [ "$previousExists" -ne "0" ]; then
        # Add a space between the elements
        STATUS="$STATUS "
      fi
      previousExists=1
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STASHED{$GIT_STASHED}%{${reset_color}%}"
    fi
	  echo "$STATUS"
	fi
}

# Default values for the appearance of the prompt. Configure at will.
ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_REMOTE="%F{70}"
ZSH_THEME_GIT_PROMPT_BRANCH="%F{70}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}%{S:%G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{✖%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%F{130}%{U:%G%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%F{70}%{↓%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%F{70}%{↑%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[red]%}%{?:%G%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{✔%G%}"
ZSH_THEME_GIT_PROMPT_STASHED="%F{70}"


