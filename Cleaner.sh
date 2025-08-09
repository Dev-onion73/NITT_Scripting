#!/bin/bash

# Load global env variables
source /etc/profile.d/club_env.sh

# Ensure run by root
if [[ "$EUID" -ne 0 ]]; then
    echo "❌ This script must be run as root."
    exit 1
fi

LOG_FILE="/var/log/club_daily_cleanup.log"
MENTEE_FILE="$DIR_CONF/$MENTEE"
DOMAIN_FILE="$DIR_CONF/$DOM"

echo "🔄 Running Daily Cleanup: $(date)" >> "$LOG_FILE"

# 1. Run checkstat to log submissions
echo "▶ Running checkstat..." >> "$LOG_FILE"
checkstat >> "$LOG_FILE" 2>&1

# 2. Detect full deregistrations
echo "🔍 Scanning for fully deregistered mentees..." >> "$LOG_FILE"

# Load list of mentees from mentee_details.txt
grep -v '^\s*#' "$MENTEE_FILE" | grep -v '^\s*$' | while read -r mentee _; do
    # Skip if home directory doesn't exist
    [[ ! -d "/home/$mentee" ]] && continue

    # Check if user is in Mentees group
    if ! id -nG "$mentee" | grep -qw "Mentees"; then
        continue
    fi

    # Get domain registration status
    line=$(grep -w "^$mentee" "$DOMAIN_FILE")
    [[ -z "$line" ]] && continue

    read -r _ d1 d2 d3 <<< "$line"
    active_domains=0
    for d in "$d1" "$d2" "$d3"; do
        [[ "$d" != "NULL" ]] && ((active_domains++))
    done

    if [[ "$active_domains" -eq 0 ]]; then
        echo "🗑️  Mentee $mentee has deregistered from all domains. Removing completely..." >> "$LOG_FILE"

        # Remove their home directory
        userdel -r "$mentee" &>> "$LOG_FILE"

        # Remove symlink from Club_Admin's Mentee directory
        rm -f "$DIR_MENTEE/$mentee" &>> "$LOG_FILE"

        # Remove from mentees_domain.txt
        sed -i "/^$mentee\b/d" "$DOMAIN_FILE"

        # Remove from every mentor's allocated_mentees.txt
        find /home -type f -name "$ALLOC" -exec sed -i "/^$mentee\b/d" {} +

    else
        echo "ℹ️  Mentee $mentee has partially deregistered. Updating mentor allocations..." >> "$LOG_FILE"

        # Check which domains were deregistered
        for dom in "WEBDEV" "APPDEV" "SYSAD"; do
            # If mentee doesn't have this domain directory, remove from relevant mentor's allocation
            if [[ ! -d "/home/$mentee/$dom" ]]; then
                find /home -type f -name "$ALLOC" -exec sed -i "/^$mentee\b/d" {} +
                echo "  ⏹️  Removed $mentee from $dom allocations." >> "$LOG_FILE"
            fi
        done
    fi
done

echo "✅ Daily Cleanup Complete: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
