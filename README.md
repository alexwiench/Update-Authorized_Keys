# Update ~/.ssh/authorized_keys with Github public keys

A short bash script that pulls your public keys from `github.com/UserName.keys` and adds them to the ssh `authorized_keys` file of your current user.

## How to run

### Download with cURL

1. `curl -fsSL https://raw.githubusercontent.com/alexwiench/Update-Public-Keys/master/updatekeys.sh -o updatekeys.sh`
2. `bash ./updatekeys.sh`

> You can also use your username as a command line arugment for automating or quick usage.
> Example: `./updatekeys.sh username`

### Run without downloading

`bash <(curl -fsSL https://raw.githubusercontent.com/alexwiench/Update-Public-Keys/master/updatekeys.sh) username`

> Script output is difficult to read due to cURL omitting newline characters while using this method.

---

### Notes

#### Sudo

This script is only designed to modify the `authorized_keys` file in the `$HOME` directory of your **current user** and will abort if it detects `sudo`.
Use `su` to switch users if you must.

#### Crontab

This script is not currently suitable for crontab usage. Script will hang in a situation where `~/.ssh/authorized_keys` does not yet exist for the current user.
