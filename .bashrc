function s2a { eval $(echo "$(which saml2aws) script --shell=bash"); }
alias awslogin="saml2aws login --session-duration=28800 && s2a"

export VIRTUAL_ENV_DISABLE_PROMPT=1

function _fancy_prompt {
  local RED="\[\033[01;31m\]"
  local GREEN="\[\033[01;32m\]"
  local YELLOW="\[\033[01;33m\]"
  local BLUE="\[\033[01;34m\]"
  local WHITE="\[\033[00m\]"
  local PURPLE="\[\033[01;35m\]"

  local PROMPT=""

  # Working directory
  PROMPT=$PROMPT"$GREEN\w"

  # Git-specific
  local GIT_STATUS=$(git status 2> /dev/null)
  if [ -n "$GIT_STATUS" ] # Are we in a git directory?
  then
    # Open paren
    PROMPT=$PROMPT" $BLUE("

    # Branch
    PROMPT=$PROMPT$(git branch --no-color 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/\1/")

    # Warnings
    PROMPT=$PROMPT$YELLOW

    # Merging
    echo $GIT_STATUS | grep "Unmerged paths" > /dev/null 2>&1
    if [ "$?" -eq "0" ]
    then
      PROMPT=$PROMPT"|MERGING"
    fi

    # Dirty flag
    echo $GIT_STATUS | grep "nothing to commit" > /dev/null 2>&1
    if [ "$?" -eq 0 ]
    then
      PROMPT=$PROMPT
    else
      PROMPT=$PROMPT"*"
    fi

    # Warning for no email setting
    git config user.email | grep @ > /dev/null 2>&1
    if [ "$?" -ne 0 ]
    then
      PROMPT=$PROMPT" !!! NO EMAIL SET !!!"
    fi

    # Closing paren
    PROMPT=$PROMPT"$BLUE)"
  fi

  # Final $ symbol
  PROMPT=$PROMPT" $BLUE\$$WHITE "

  export PS1=$PROMPT
}

export PROMPT_COMMAND="_fancy_prompt"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias g="git"
alias cls="clear"

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

alias ls="command ls ${colorflag}"
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
