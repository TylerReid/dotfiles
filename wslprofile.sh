# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/go/bin" ] ; then
    PATH="$HOME/go/bin:$PATH"
fi

export PATH=$PATH:/usr/local/go/bin

. ~/.loadshit.sh

export AWS_DEFAULT_REGION=us-east-1

alias awsclear="truncate -s 0 ~/.aws/credentials"
function awssamlauth {
  saml2aws login --session-duration=28800 --mfa='DUO'
}
function awsload {
  eval $($(which saml2aws) script --shell=bash)
}
function awslogin {
  awssamlauth && awsload
}

function kubelogin {
  if [ $# != 1 ]; then
    echo "usage: kubelogin [eks_cluster_name]"
    exit 1
  fi
  
  awslogin
  aws eks update-kubeconfig --name "eks-$1"
}

function decodejwt {
  sed 's/\./\n/g' <<< $(cut -d. -f1,2 <<< $1) | base64 --decode | jq
}

function git {
  if isWinDir
  then
    git.exe "$@"
  else
    /usr/bin/git "$@"
  fi
}

function dotnet {
  if isWinDir
  then
    dotnet.exe "$@"
  else
    /usr/bin/dotnet "$@"
  fi
}

function explorer {
  explorer.exe $(wslpath -w .);
}

function gp {
  if [ $# != 1 ]; then
    echo "usage: gp [branch name]"
    exit 1
  fi
  git co $1 && git pull
}

function newsln {
  if [ $# != 2 ]; then
    echo "usage: newsln [project_name] [template_type]"
    exit 1
  fi
  dotnet new sln --name $1
  dotnet new $2 --name $1 --output "./src/$1"
  dotnet sln add "./src/$1"
  dotnet restore
  dotnet build
}

function convertCore {
  if [ $# != 2 ]; then
    echo "usage: convertCore [sln] [tfm]"
    exit 1
  fi
  psh try-convert -w $1 -tfm $2 --no-backup
}

function rsln {
  $(rider64.exe *.sln &> /dev/null &)
}

# run a command in windows powershell, ex: `psh 'Write-Host "yep $env:computername"; pwd; cd ..; pwd;'`
function psh {
  pwsh.exe -c "$*"
}
#open vs code in native windows if in windows dir, otherwise use wsl integration
function vs {
  if isWinDir
  then
    psh code $(wslpath -w .)
  else
    code .
  fi
}

function isWinDir {
  case $PWD/ in
    /c/*) return $(true);;
    *) return $(false);;
  esac
}

function gitssh {
  old=$(git remote get-url origin)
  git remote set-url origin ${old/'https://git.kabbage.com/scm'/'ssh://git@git.kabbage.com:7999'}
}

SHOW_GIT_CHANGES=0
function togglegit {
  SHOW_GIT_CHANGES=$((1-SHOW_GIT_CHANGES))
}

export VIRTUAL_ENV_DISABLE_PROMPT=1

function _fancy_prompt {
  local RED="\[\033[01;31m\]"
  local GREEN="\[\033[01;32m\]"
  local YELLOW="\[\033[01;33m\]"
  local BLUE="\[\033[01;34m\]"
  local WHITE="\[\033[00m\]"
  local PURPLE="\[\033[01;35m\]"

  local PROMPT="$PURPLE┌──$BLUE["

  # Working directory
  PROMPT=$PROMPT"$GREEN\w$BLUE]"

  if isWinDir
  then
    git='psh git'
  else
    git=git
  fi

  # Git-specific
  local BRANCH=$($git branch --no-color 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/\1/")
  if [ -n "$BRANCH" ] # Are we in a git directory?
  then
    # Open paren
    PROMPT=$PROMPT"-$PURPLE("

    # Branch
    PROMPT=$PROMPT$BLUE$BRANCH

    # Warnings
    PROMPT=$PROMPT$WHITE

    if [ $SHOW_GIT_CHANGES == 0 ]
    then
      local GIT_STATUS=$($git status 2> /dev/null)
    else
      local GIT_STATUS='nothing to commit'      
    fi
    
    # Merging
    echo $GIT_STATUS | grep "Unmerged paths" > /dev/null 2>&1
    if [ "$?" -eq "0" ]
    then
      PROMPT=$PROMPT"|MERGING"
    fi

    # # Dirty flag
    echo $GIT_STATUS | grep "nothing to commit" > /dev/null 2>&1
    if [ "$?" -eq 0 ]
    then
      PROMPT=$PROMPT
    else
      PROMPT=$PROMPT"*"
    fi

    # Warning for no email setting
    # git config user.email | grep @ > /dev/null 2>&1
    # if [ "$?" -ne 0 ]
    # then
    #   PROMPT=$PROMPT" !!! NO EMAIL SET !!!"
    # fi

    # Closing paren
    PROMPT=$PROMPT"$PURPLE)"
  fi

  # Final $ symbol
  PROMPT=$PROMPT" \n$PURPLE└─$BLUE\$$WHITE "

  export PS1="\[\e]0;\W\a\]$PROMPT"
}

export PROMPT_COMMAND="_fancy_prompt"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias cd..="cd .."

alias g="git"
alias unfuckgit="git config core.autocrlf true && gitssh"

alias cls="clear"
alias explorer="explorer.exe ."
alias kbg="cd /c/Kabbage/Source/"

alias k="kubectl"

export PATH="$HOME/.cargo/bin:$PATH"
if [ -e /home/treid/.nix-profile/etc/profile.d/nix.sh ]; then . /home/treid/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
