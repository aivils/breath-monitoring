# Target

These scripts are designed to handle measurements remotely.

# Install

## Installing NVM on Ubuntu

A shell script is available for the installation of nvm on the Ubuntu 20.04
Linux system. Open a terminal on your system or connect a remote system using
SSH. Use the following commands to install curl on your system, then run the
nvm installer script.

```sh
sudo apt install curl
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
```

The nvm installer script creates an environment entry to the login script of
the current user. You can either log out and log in again to load the
environment.

## Installing Node using NVM

```sh
nvm install v18.5
```

## Set up script

choose folder

```sh
cd scripts/process-remote
```

choose node

```sh
nvm use
```

should see similar output "Now using node v18.5.0"

Install modules

```sh
npm install
```

# Run the script

```sh
export ANSHEALTH_APIKEY=change-me
./process-remote.js
```

Statistical file processing takes place in the process-local.r file, which
receives data from STDIN and outputs the result to STDOUT. process-local.r
outputs tuning statements to STDERR.
