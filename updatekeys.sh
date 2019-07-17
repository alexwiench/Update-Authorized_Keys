#!/bin/bash
IFS=$'\n'

#check for dependencies
dependencies=(echo read test grep curl)

for i in "${dependencies[@]}"; do
  if ! type $i >/dev/null 2>&1; then
  echo "Missing a dependency! Please install $i before using this script"
  dependencyfail="fails"
  fi
done

if [ "$dependencyfail" == "fails" ]; then
exit 1
fi

#Check for command line arugment
if [ "$1" != "" ]; then
  githubname="$1"
  
  else
  #Script start
  echo "What is your Github username?"
  read githubname

fi

#Gets Keys
pubkeys=$(curl -s https://github.com/$githubname.keys | grep "ssh-rsa")
#grep just protects from curl garbage if it returns an unuseful response

#Check username validity
if [ "$pubkeys" = "Not Found" ]; then
  echo "No keys found for $githubname."
  echo "Check your spelling or add public keys to Github here https://github.com/settings/keys"
  exit 1
fi

echo "Importing public keys from $githubname"

#find path to .ssh folder
numberofssh=$( find /home -name ".ssh" 2>/dev/null | grep -c '.ssh' ) 

echo $numberofssh

exit 0
#find out if there are multiple .ssh folders
if [ "$numberofssh" == 0 ]; then
  #create directory
  pathtossh="/home/${USER}/.ssh"
  echo "Can't find .ssh folder, will create one at "$pathtossh""
  mkdir $pathtossh

  elif [ "$numberofssh" == 1 ]; then
  #use directory
  pathtossh=$(find /home -name ".ssh" 2>/dev/null)

  else
  #pick directory
  echo "Which location do you want to add keys too? (type a number)"
    for sshlocation in $(find /home -name ".ssh" 2>/dev/null); do
    j=$(( $j + 1))
    echo "$j. "$sshlocation""
    done

  read sshlocationchoice

  #validate input or at least let it crash more gracefully
  if [ "$sshlocationchoice" -le "$j" ]; then
    echo ""
  else
    echo "Try typing a displayed number."
    exit 1
  fi
    #count up to picked directory
    for sshlocation in $(find /home -name ".ssh" 2>/dev/null); do
    k=$(( $k + 1))
      if [ $k == $sshlocationchoice ]; then
      pathtossh="$sshlocation"
      fi
    done

fi

authorized_keys="$pathtossh"/authorized_keys
keyalreadyexisted=0
keyadded=0

#Sees if authorized_key file exists
if ! test -e "$authorized_keys"; then
  touch "$authorized_keys"
fi

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
exit 0
