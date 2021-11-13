# Update ~/.ssh/authorized_keys with Github public keys

A short bash script that pulls your public keys from `github.com/UserName.keys` and adds them to the ssh `authorized_keys` file of your current user.

## Usage

This script can be run with or without arguments.
`./updatekeys.sh` or `./updatekeys.sh username y`

Adding your GitHub _username_ and _y_ will allow cause this script to run without prompting the user, making it suitable for crontab or startup scripts.

> **Script not running?**
> Use `chmod +x ./updatekeys.sh` to give it executable permissions.

## How to run on the go

### Download with cURL and run

1. `curl -fsSL https://raw.githubusercontent.com/alexwiench/Update-Authorized_Keys/master/updatekeys.sh -o updatekeys.sh`
2. `bash ./updatekeys.sh`

> You can also use your username as a command line arugment for automating or quick usage.
> Example: `./updatekeys.sh username`

### Run without downloading

`bash <(curl -fsSL https://raw.githubusercontent.com/alexwiench/Update-Authorized_Keys/master/updatekeys.sh) username`

---

### Notes

#### Sudo

This script is only designed to modify the `authorized_keys` file in the `$HOME` directory of your **current user** and will abort if it detects `sudo`.
Use `su` to switch users if you must.
