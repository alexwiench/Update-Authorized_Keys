# Update-Public-Keys
A short bash script that pulls your public keys from Github and adds them to your ssh authorized_keys file.

## How to run

1. Download updatekeys.sh
2. Run `chmod +x updatekeys.sh`
3. Run `./updatekeys.sh`

You can also use your username as a command line arugment for automating or quick usage.

Example: `./updatekeys.sh username`

Run on the fly: `curl -fsSL https://raw.githubusercontent.com/alexwiench/Update-Public-Keys/master/updatekeys.sh | bash -s username`