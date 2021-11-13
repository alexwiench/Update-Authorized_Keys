#!/bin/bash

IFS=$'\n'

_dependencyCheck() {
  dependencies=("read" "test" "type" "grep" "curl" "logname" "id" "touch")
  for i in "${dependencies[@]}"; do
    if ! type "$i" >/dev/null 2>&1; then
      echo "Missing a dependency! Please install $i before using this script. "
      exit 1
    fi
  done
}

_isUserRoot() {
  if [ "$(id -un)" != "$(logname)" ]; then
    echo "This script is not designed to be run with sudo. "
    exit 1
  fi
}

_checkForYesArgument() {
  unset argYes
  if [[ "$2" =~ ^[Yy]$ ]]; then
    argYes="y"
  fi
}

_sshLocation() {
  unset userinput
  if [ ! -f "$HOME/.ssh/authorized_keys" ]; then
    echo "$HOME/.ssh/authorized_keys does not exist. Create it? (Y/N) "
    if [[ "$argYes" =~ ^[Yy]$ ]]; then
      userinput="y"
    else
      read -n 1 -r userinput
      echo
    fi
    if [[ ! $userinput =~ ^[Yy]$ ]]; then
      echo "Can not add keys without creating $HOME/.ssh/authorized_keys. Script will exit now. "
      exit 1
    else
      if [ ! -d "$HOME/.ssh/" ]; then
        mkdir "$HOME/.ssh/"
      fi
      touch "$HOME/.ssh/authorized_keys"
    fi
  fi
}

_githubUsername() {
  if [ "$1" != "" ]; then
    githubname="$1"
  else
    echo "What is your Github username? (No spaces) "
    read -r githubname
  fi
  #sanitize input
  githubname=${githubname//[^a-zA-Z0-9-]/}
}

_downloadKeys() {
  githubResponse=$(curl -s https://github.com/"$githubname".keys)

  #Check username validity
  if [ "$githubResponse" = "Not Found" ] || [ "$githubResponse" = "" ]; then
    echo "No keys found for $githubname. "
    echo "Check your spelling or add public keys to Github here https://github.com/settings/keys "
    exit 1
  else
    githubResponse=$(echo "$githubResponse" | grep -E "ssh|ecdsa")
  fi
}

_writeKeys() {
  authorized_keys="$HOME/.ssh/authorized_keys"
  keyalreadyexisted=0
  keyadded=0

  for key in $githubResponse; do
    if grep -qxF "$key" "$authorized_keys"; then
      keyalreadyexisted=$((keyalreadyexisted + 1))

    else
      echo "$key" >>"$authorized_keys"
      keyadded=$((keyadded + 1))

    fi
  done

  echo "$keyadded keys were added to $authorized_keys. $keyalreadyexisted keys already existed."
}

_runscript() {
  _dependencyCheck
  _isUserRoot
  _checkForYesArgument "$1" "$2"
  _sshLocation
  _githubUsername "$1"
  _downloadKeys
  _writeKeys
}

_runscript "$1" "$2"
exit 0
