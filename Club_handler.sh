#!/bin/bash

shell="/bin/bash"

userGen() {
    
    
    
    if [ $# -lt 2 ] ; then
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
HOME_C="/home/$Club_Admin"
MENTEE="mentee_details.txt"
MENTOR="mentor_details.txt"
DOM="mentees_domain.txt"
DOM_PREF="dom_pref.txt"
TASK_D="task_done.txt"
TASK_S="task_sub.txt"
ALLOC="allocated_mentees.txt"
SUB_TASK="submitted_tasks"
    
    read -r -p "Do you want to create Mentor's and Mentee's directories(y|n) ?" choice
    if [[ "$choice" == [yY] ]] ; then
    
		echo "Directory Creations 1"

    	mkdir -p "$HOME_C/Mentor"
    	mkdir -p "$HOME_C/Mentee"
		mkdir -p "$HOME_C/.Config_Club"
    	
    	
    	
    	DIR_MENTEE="$HOME_C/Mentee"
    	DIR_MENTOR="$HOME_C/Mentor"
		DIR_CONF="$HOME_C/.Config_Club"

		mkdir -p "$DIR_MENTOR/WEBDEV"
		mkdir -p "$DIR_MENTOR/APPDEV"
		mkdir -p "$DIR_MENTOR/SYSAD"
	elif [[ "$choice" == [nN] ]] ; then

	return 1

	else

	return 1

	fi 

echo "Config File Creation"

cat <<EOF > "$DIR_CONF/$MENTEE"
# THIS IS MENTEE DETAILS FILE
# FILL IN THE DETAILS IN THE FOLLOWING FORMAT:
    	
<MENTEE_USER_NAME> <PASSWD>
    	
#EDIT THE ABOVE LINE AND ADD SIMILAR LINES BELOW BASED ON NUMBER OF USERS TO BE CREATED
EOF

cat <<EOF > "$DIR_CONF/$MENTOR"
# THIS IS MENTOR DETAILS FILE
# FILL IN THE DETAILS IN THE FOLLOWING FORMAT:
    	
<MENTOR_USER_NAME> <PASSWD> <DOMAIN>
    	
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
chmod 720 "$DIR_CONF/$DOM"

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


cat <<EOF > "$H_MENT/$DOM_PREF"
# THIS IS DOMAIN PREFERENCE FILE

# ARRANGE THE FOLLOWING DOMAIN CHOICES IN ORDER 
# TOPMOST - HIGHEST PRIORITY AND BOTTOM-MOST - LOWEST PRIORITY
# TO SELECT THE DOMAIN PREFERENCE:

# WEBDEV 
# APPDEV
# SYSAD 

EOF


cat <<EOF > "$H_MENT/$TASK_D"
# THIS IS TASKS DONE FILE
			
EOF


cat <<EOF > "$H_MENT/$TASK_S"
# THIS IS TASKS SUBMITTED FILE
EOF

		fi
	done < "$DIR_CONF/$MENTEE"


echo "Mentor Creations"
	while IFS=" " read -r user pass dom; do

		if [[ -z "$user" || "$user" =~ ^# ]]; then

			continue
		fi

		GROUP=""

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

			echo "Skipping $user No domain selected"
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

		fi
	done < "$DIR_CONF/$MENTOR"

}

domainpref() {

	
}




    	
