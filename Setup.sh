#!/bin/bash

set -e

SCRIPT="Club_handler.sh"
DEST="/etc/profile.d"

WRAP="wrapper"
W_DEST="/usr/local/bin/club"

# Ensure we're running as root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root or using sudo"
  exit 1
fi


read -r -p "Would you like to proceed to installation(y|n) ?" choice

if [[ "$choice" == [yY] ]] ; then
    
  echo "Setting up functions system-wide..."
		
	elif [[ "$choice" == [nN] ]] ; then

	echo "Cancelled the installation"
    return 1

	else

    echo "Cancelled the installation"
    echo "ERROR: Invalid input"
	return 1

	fi 



if [[ ! -f "$SCRIPT" ]]; then
  echo "Source file '$SCRIPT' not found."
  exit 1
fi

if [[ ! -f "$WRAP" ]]; then
  echo "Wrapper file '$WRAP' not found."
  exit 1
fi


echo "Copying $SCRIPT to $DEST"
cp "$SCRIPT" "$DEST/$SCRIPT"

chmod +x "$DEST/$SCRIPT"

echo "Copying $WRAP to $W_DEST"
cp "$WRAP" "$W_DEST"

chmod +x "$W_DEST"

BASHRC=""
if [[ -f /etc/bash.bashrc ]]; then
  BASHRC="/etc/bash.bashrc"
elif [[ -f /etc/bashrc ]]; then
  BASHRC="/etc/bashrc"
fi

if [[ -n "$BASHRC" ]] && ! grep -q "Club_handler.sh" "$BASHRC"; then
  echo "[ -f $DEST/$SCRIPT ] && source $DEST/$SCRIPT" >> "$BASHRC"
  echo "Added sourcing to $BASHRC"
else
  echo "Already sourced or BASHRC not found"
fi

echo "Club-Management functions are successfully setup to begin setting up run the command: userGen <ADMIN-NAME> <PASSWD> to create the ADMIN user and Member management"