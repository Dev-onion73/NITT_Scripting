#!/bin/bash

set -e

SCRIPT="Club_handler.sh"
DEST="/etc/profile.d"

WRAP_DEST="/usr/local/bin/club"

BASHRC=""
if [[ -f /etc/bash.bashrc ]]; then
  BASHRC="/etc/bash.bashrc"
elif [[ -f /etc/bashrc ]]; then
  BASHRC="/etc/bashrc"
fi

# Ensure running as root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root or using sudo"
  exit 1
fi
read -r -p "Do you confirm that you would like to remove the Club Management system (y|n) ?" choice

if [[ "$choice" == [yY] ]] ; then
    
    echo "Uninstalling Club Management system..."
		
	elif [[ "$choice" == [nN] ]] ; then

	echo "Cancelled the uninstallation"
    return 1

	else

    echo "Cancelled the uninstallation"
    echo "ERROR: Invalid input"
	return 1

	fi 



# 1. Remove Club_handler.sh from profile.d
if [[ -f "$DEST/$SCRIPT" ]]; then
  echo "Removing $DEST/$SCRIPT"
  rm -f "$DEST/$SCRIPT"
else
  echo "$DEST/$SCRIPT not found. Skipping."
fi

# 2. Remove CLI wrapper
if [[ -f "$WRAP_DEST" ]]; then
  echo "Removing $WRAP_DEST"
  rm -f "$WRAP_DEST"
else
  echo "$WRAP_DEST not found. Skipping."
fi

# 3. Remove sourcing line from bashrc
if [[ -n "$BASHRC" ]]; then
  if grep -q "$SCRIPT" "$BASHRC"; then
    echo "Cleaning up $BASHRC"
    sed -i.bak "/$SCRIPT/d" "$BASHRC"
    echo "Removed Club handler sourcing from $BASHRC (backup saved as $BASHRC.bak)"
  else
    echo "No reference to $SCRIPT found in $BASHRC"
  fi
else
  echo "No system bashrc file found to clean"
fi

echo "Club Management system has been successfully uninstalled."
echo "Changes will take place in next terminal session Onwards"
