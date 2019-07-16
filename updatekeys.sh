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

pathtossh=$(find ~ -name ".ssh")
authorized_keys=$pathtossh/authorized_keys
#authorized_keys="/home/${USER}/.ssh/authorized_keys"
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
echo "$keyadded keys were added. $keyalreadyexisted keys already existed"
exit 0
