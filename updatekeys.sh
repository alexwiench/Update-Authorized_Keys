#!/bin/bash

#what does this do?
IFS=$'\n'

_dependencyCheck () { 
  dependencies=( "read" "test" "type" "grep" "curl" "logname" "id" "touch")
  for i in "${dependencies[@]}"; do
    if ! type "$i" >/dev/null 2>&1; then
      echo "Missing a dependency! Please install $i before using this script."
      exit 1
    fi
  done
}

_isUserRoot() {
  if [ "$(id -un)" != "$(logname)" ]; then
      echo "This script is not designed to be run with sudo."
      exit 1
  fi
}

_sshLocation(){
  unset userinput
  if [ ! -f "$HOME/.ssh/authorized_keys" ]; then
      echo "$HOME/.ssh/authorized_keys does not exist. Create it? (Y/N)"
      read -n 1 -r userinput
      if [[ ! $userinput =~ ^[Yy]$ ]]; then
          echo "Can not add keys without creating $HOME/.ssh/authorized_keys. Script will exit now."
          exit 1
      else
          if [ ! -d "$HOME/.ssh/" ]; then
              mkdir "$HOME/.ssh/"
          fi
          touch "$HOME/.ssh/authorized_keys"
      fi
  fi
}

_githubUsername () {
  if [ "$1" != "" ]; then
    githubname="$1"
  else
    echo "What is your Github username?"
    read -r githubname
  fi
  #sanitize input
  githubname=${githubname//[^a-zA-Z0-9-]/}
}

#THIS IS THE ISSUE. SSH-RSA ISN'T SOMETHING I CAN ASSUME ANYMORE.
#Gets Keys
_downloadKeys () {
  pubkeys=$(curl -s https://github.com/$githubname.keys | grep "ssh-rsa")
  #grep just protects from curl garbage if it returns an unuseful response

  #Check username validity
  if [ "$pubkeys" = "Not Found" ]; then
    echo "No keys found for $githubname."
    echo "Check your spelling or add public keys to Github here https://github.com/settings/keys"
    exit 1
  fi

  echo "Importing public keys from $githubname"
}


_writeKeys() {
authorized_keys="$pathtossh"/authorized_keys
keyalreadyexisted=0
keyadded=0

for key in $pubkeys; do
  if grep -qxF "$key" "$authorized_keys"; then
  keyalreadyexisted=$(( $keyalreadyexisted + 1 ))

  else
  echo "$key" >> "$authorized_keys"
  keyadded=$(( $keyadded + 1 ))

  fi

done

#Status
echo "$keyadded keys were added to "$authorized_keys". $keyalreadyexisted keys already existed."
}
 
 _runscript(){
   _dependencyCheck
   _isUserRoot
   _sshLocation
   _githubUsername "$1"
   _downloadKeys 
   _writeKeys
 } 

 _runscript "$1"
 exit 0