#!/bin/bash

shell="/bin/bash"

userGen() {
    
    
    
    if [ $# -ne 2 ] ; then
        echo "Usage: userGen <USER> <PASSWD>";
        
        return 1
    fi

	echo "Group Creation"

    groupadd -f Core
    groupadd -f Mentors
	groupadd -f Mentees
	groupadd -f Webdev
	groupadd -f Appdev
	groupadd -f Sysad


    useradd -m -G Core,wheel -s "$shell" "$1"
    echo "$1:$2" | chpasswd

    Club_Admin="$1"
    export Club_Admin
	echo "Created user $Club_Admin successfully"


echo "Init Variables"
export HOME_C="/home/$Club_Admin"
export MENTEE="mentee_details.txt"
export MENTOR="mentor_details.txt"
export DOM="mentees_domain.txt"
export DOM_PREF="dom_pref.txt"
export TASK_D="task_done.txt"
export TASK_S="task_sub.txt"
export ALLOC="allocated_mentees.txt"
export SUB_TASK="submitted_tasks"
export CAP="mentee_cap.txt"
    
    read -r -p "Do you want to create Mentor's and Mentee's directories(y|n) ?" choice
    if [[ "$choice" == [yY] ]] ; then
    
		echo "Directory Creations 1"

    	mkdir -p "$HOME_C/Mentor"
    	mkdir -p "$HOME_C/Mentee"
		mkdir -p "/etc/.Config_Club"
    	
    	
    	
    	export DIR_MENTEE="$HOME_C/Mentee"
    	export DIR_MENTOR="$HOME_C/Mentor"
		export DIR_CONF="/etc/.Config_Club"

		mkdir -p "$DIR_MENTOR/WEBDEV"
		mkdir -p "$DIR_MENTOR/APPDEV"
		mkdir -p "$DIR_MENTOR/SYSAD"
	elif [[ "$choice" == [nN] ]] ; then

	return 1

	else

	return 1

	fi 

echo "Config File Creation"

cat <<EOF > "$DIR_CONF/$CAP"
# THIS IS MENTOR CAPACITY FILE
EOF

cat <<EOF > "$DIR_CONF/$MENTEE"
# THIS IS MENTEE DETAILS FILE
# FILL IN THE DETAILS IN THE FOLLOWING FORMAT:
    	
<MENTEE_USER_NAME> <PASSWD>
    	
#EDIT THE ABOVE LINE AND ADD SIMILAR LINES BELOW BASED ON NUMBER OF USERS TO BE CREATED
EOF

cat <<EOF > "$DIR_CONF/$MENTOR"
# THIS IS MENTOR DETAILS FILE
# FILL IN THE DETAILS IN THE FOLLOWING FORMAT:
    	
<MENTOR_USER_NAME> <PASSWD> <DOMAIN> <CAPACITY>
    	
# EDIT THE ABOVE LINE AND ADD SIMILAR LINES BELOW BASED ON NUMBER OF USERS TO BE CREATED
# DOMAIN CAN BE AMONG THREE OF THE CHOICES:
# WEBDEV
# APPDEV
# SYSAD 
EOF
cat <<EOF > "$DIR_CONF/$DOM"
# THIS IS MENTEE DOMAIN FILE
EOF

# Prompt and open the mentee details file in the editor
echo "Please fill in the Mentee details and save it to proceed."
$EDITOR "$DIR_CONF/$MENTEE"

# Prompt and open the mentor details file in the editor
echo "Please fill in the Mentor details and save it to proceed."
$EDITOR "$DIR_CONF/$MENTOR"

echo "Access Management"

chown -R "$Club_Admin":Core "$HOME_C"
chmod 770 "$HOME_C"  # Full access to owner and Core group, others have no access

chown "$Club_Admin":Mentees "$DIR_CONF/$DOM"
chmod 760 "$DIR_CONF/$DOM"

chgrp Mentees "$DIR_CONF"
chmod 750 "$HOME_C"


echo "Mentees Creations"

	while IFS=" " read -r user pass; do

		if [[ -z "$user" || "$user" =~ ^# ]]; then

			continue
		fi

		

		if id "$user" &>/dev/null; then

			echo "User $user already exists."
		else

			H_MENT="/home/$user"
			useradd -m -G Mentees -s "$shell" "$user"
			echo "$user:$pass" | chpasswd
			   
			ln -s "/home/$user" "$DIR_MENTEE/$user"

            setfacl -m g:core:rwx /home/$user
            setfacl -m g:mentee:rx /home/$user





cat <<EOF > "$H_MENT/$DOM_PREF"
# THIS IS DOMAIN PREFERENCE FILE



EOF


cat <<EOF > "$H_MENT/$TASK_D"
# THIS IS TASKS DONE FILE
			
EOF


cat <<EOF > "$H_MENT/$TASK_S"
# THIS IS TASKS SUBMITTED FILE
EOF

chown -R "$user" "$H_MENT"

		fi
	done < "$DIR_CONF/$MENTEE"


echo "Mentor Creations"
	while IFS=" " read -r user pass dom cap; do

		if [[ -z "$user" || "$user" =~ ^# ]]; then

			continue
		fi

		export GROUP=""

		case "$dom" in 
			WEBDEV)

			GROUP=Webdev
			echo "$user is in $dom will be added to $GROUP"

			;;
			APPDEV)

			GROUP=Appdev
			echo "$user is in $dom will be added to $GROUP"

			;;
			SYSAD)

			GROUP=Sysad
			echo "$user is in $dom will be added to $GROUP"

			;;
			*)

			echo "Skipping $user No domain selected Invalid domain: $dom"
			continue

			;;
		esac

		if id "$user" &>/dev/null; then

			echo "User $user already exists."
		else

			H_MENT="/home/$user"
			useradd -m -d "$H_MENT" -G $GROUP,Mentors -s "$shell" "$user"
			echo "$user:$pass" | chpasswd
			
			mkdir -p "$H_MENT/$SUB_TASK"

			ln -s "/home/$user" "$DIR_MENTOR/$dom/$user"

cat <<EOF > "$H_MENT/$ALLOC"
# THIS IS ALLOCATED MENTEES FILE
EOF

echo "$user $dom $cap" >> "$DIR_CONF/$CAP"


		fi
	done < "$DIR_CONF/$MENTOR"

echo "Exporting Env variables"

# Create env file
ENV_FILE="/etc/profile.d/club_env.sh"

echo "Exporting environment variables globally to $ENV_FILE"

cat <<EOF > "$ENV_FILE"
# Club Environment Variables
export Club_Admin="$Club_Admin"
export HOME_C="$HOME_C"
export MENTEE="$MENTEE"
export MENTOR="$MENTOR"
export DOM="$DOM"
export DOM_PREF="$DOM_PREF"
export TASK_D="$TASK_D"
export TASK_S="$TASK_S"
export ALLOC="$ALLOC"
export SUB_TASK="$SUB_TASK"
export CAP="$CAP"
export DIR_MENTEE="$DIR_MENTEE"
export DIR_MENTOR="$DIR_MENTOR"
export DIR_CONF="$DIR_CONF"
EOF

BASHRC=""
if [[ -f /etc/bash.bashrc ]]; then
  BASHRC="/etc/bash.bashrc"
elif [[ -f /etc/bashrc ]]; then
  BASHRC="/etc/bashrc"
fi

if [[ -n "$BASHRC" ]] && ! grep -q "club_env.sh" "$BASHRC"; then
  echo "[ -f /etc/profile.d/club_env.sh ] && source /etc/profile.d/club_env.sh" >> "$BASHRC"
  echo "Added sourcing to $BASHRC"
else
  echo "Already sourced or BASHRC not found"
fi

# Secure the env file
chmod 644 "$ENV_FILE"


}

domainpref() {


    if [[ $# -gt 3 || $# -lt 1 ]]; then
        echo "Must have atleast 1 or Maximum of 3 arguments"
		echo "Usage: domainpref <PREF1> <PREF2> <PREF3> "
        return 1
    fi

    user="$(whoami)"
    D1="${1:-NULL}"
	D2="${2:-NULL}"
	D3="${3:-NULL}"


    # Valid domain options
    VALID=("WEBDEV" "APPDEV" "SYSAD" "NULL")

    # Function to check if a domain is valid
    is_valid() {
        local value="$1"
        for v in "${VALID[@]}"; do
            [[ "$v" == "$value" ]] && return 0
        done
        return 1
    }

    # Ensure each input is valid
    for domain in "$D1" "$D2" "$D3"; do
        if ! is_valid "$domain"; then
            echo "Invalid domain: $domain. Allowed: WEBDEV, APPDEV, SYSAD"
            return 1
        fi
    done

    # Check for uniqueness
    if { [[ "$D1" == "$D2" && "$D1" != "NULL" ]]; } || \
   { [[ "$D1" == "$D3" && "$D1" != "NULL" ]]; } || \
   { [[ "$D2" == "$D3" && "$D2" != "NULL" ]]; }; then
    echo "All domain preferences must be unique (excluding NULL)."
    return 1
	fi


    {
        echo "Domain 1: $D1"
        echo "Domain 2: $D2"
        echo "Domain 3: $D3"
    } >> "$HOME/$DOM_PREF"

	echo "successfully written preferences into /$user/$DOM_PREF"

    echo "$user $D1 $D2 $D3" >> "$DIR_CONF/$DOM"

    echo "Preferences saved successfully for $user."

	for domain in "$D1" "$D2" "$D3"; do
    if [[ "$domain" != "NULL" ]]; then
        user_domain_dir="$HOME/$domain"
        mkdir -p "$user_domain_dir"
    fi
	done


	
}


mentorAlloc() {

    if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root or using sudo"
  echo "Usage: sudo club mentorAllocation"
  exit 1
    fi

    mentee_file="$DIR_CONF/$DOM"
    mentor_file="$DIR_CONF/$CAP"
    echo "$mentee_file $mentor_file"

    echo "$" >> "$mentee_file"

    declare -A mentor_cap
    declare -A domain_mentors
    declare -A mentor_domain

    echo "Reading mentor capacities from '$mentor_file'..."
    echo "---------------------------------------------"
    
    while IFS= read -r line; do
        # Skip empty and comment lines
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        read -r mentor domain capacity <<< "$line"
        echo "Mentor: $mentor | Domain: $domain | Capacity: $capacity"
        mentor_cap["$mentor"]=$capacity
        domain_mentors["$domain"]+="$mentor "
        mentor_domain["$mentor"]=$domain
    done < "$mentor_file"

    echo -e "\nMentor capacity load complete.\n"

    echo "Reading mentees from '$mentee_file'..."
    echo "---------------------------------------------"

    while IFS= read -r line; do
        # Stop reading if line contains only a single $
    if [[ "$line" == '$' ]]; then
        echo "Encountered EOF marker '\$' in mentee file. Stopping read."
        break
    fi

    # Skip empty and comment lines
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    read -r mentee pref1 pref2 pref3 <<< "$line"

        read -r mentee pref1 pref2 pref3 <<< "$line"

        # echo -e "\nProcessing mentee: $mentee"
        # echo "   Preferences: 1) $pref1  2) $pref2  3) $pref3"

        allocated=false

        for pref in "$pref1" "$pref2" "$pref3"; do
            [[ "$pref" == "NULL" ]] && continue
            # echo "   Checking domain: $pref"

            for mentor in ${domain_mentors[$pref]}; do
                # echo "      Trying mentor: $mentor (Remaining capacity: ${mentor_cap[$mentor]})"
                if (( mentor_cap["$mentor"] > 0 )); then
                    (( mentor_cap["$mentor"]-- ))
                    echo "Allocated $mentee to $mentor at domain $pref"
                    
                    # # Create mentor directory & log allocation
                    mentor_home="/home/$mentor"
                    # mkdir -p "$mentor_home"
                    echo "$mentee" >> "$mentor_home/$ALLOC"

                    allocated=true
                    break 2  # Break out of both loops
                fi
            done

            echo "No available mentors in $pref"
        done

        if [[ "$allocated" != true ]]; then
            echo "$mentee could not be allocated to any domain."
        fi

    done < "$mentee_file"

    echo -e "\nMentor allocation complete!"
    # echo "Check ~/MENTOR_NAME/allocatedMentees.txt files for final allocation results."
}







    	
