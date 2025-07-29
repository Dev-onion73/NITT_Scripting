#!/bin/bash

shell="/bin/bash"

userGen() {
    
    
    
    if [ $# -lt 2 ] ; then
        echo "Usage: userGen <USER> <PASSWD>";
        
        return 1
    fi



    groupadd -f Core
    groupadd -f Mentors
	groupadd -f Mentees
	groupadd -f Webdev
	groupadd -f Appdev
	groupadd -f Sysadmin


    useradd -m -G Core -s "$shell" "$1"
    echo "$1:$2" | chpasswd

    Club_Admin="$1"
    export Club_Admin
	echo "Created user $Club_Admin successfully"
	main
    
}


main() {

HOME_C="/home/$Club_Admin"
MENTEE="mentee_details.txt"
MENTOR="mentor_details.txt"
DOM="mentees_domain.txt"
DOM_PREF="dom_pref.txt"
TASK_D="task_done.txt"
TASK_S="task_sub.txt"
ALLOC="allocated_mentees.txt"
SUB_TASK="submitted_tasks"
    
    read -p -r "Do you want to create Mentor's and Mentee's directories(y|n) ?" choice
    if [[ "$choice" == [yY] ]] ; then
    
    	
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

	fi 

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

chown -R :Core "$HOME_C"
chmod -R 770 "$HOME_C"

chown "$Club_Admin":Mentee "$DIR_CONF/$DOM"
chmod 020 "$DIR_CONF/$DOM"


	while IFS=" " read -r user pass; do

		if [[ -z "$user" || "$user" =~ ^# ]]; then

			continue
		fi

		

		if id "$user" &>/dev/null; then

			echo "User $user already exists."
		else

			H_MENT="$DIR_MENTEE/$user"
			useradd -m -d "$DIR_MENTEE/$user" -G Mentee -s "$shell" "$user"
			echo "$user:$pass" | chpasswd


cat <<EOF > "$H_MENT/$DOM_PREF"
    		# THIS IS DOMAIN PREFERENCE FILE

			# UNCOMMENT ONE OF THE FOLLOWING DOMAIN CHOICES TO SELECT THE DOMAIN PREFERENCE:

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
    	
	while IFS=" " read -r user pass dom; do

		if [[ -z "$user" || "$user" =~ ^# ]]; then

			continue
		fi

		GROUP=""

		case "$dom" in 
			WEBDEV)

			GROUP=Webdev

			;;
			APPDEV)

			GROUP=Appdev

			;;
			SYSAD)

			GROUP=Sysad

			;;
			*)

			echo "Skipping $user No domain selected"
			continue

			;;
		esac

		if id "$user" &>/dev/null; then

			echo "User $user already exists."
		else

			H_MENT="$DIR_MENTOR/$user"
			useradd -m -d "$DIR_MENTOR/$dom/$user" -G $GROUP,Mentor -s "$shell" "$user"
			echo "$user:$pass" | chpasswd
			
			mkdir -p "$H_MENT/$SUB_TASK"

cat <<EOF > "$H_MENT/$ALLOC"
    		# THIS IS ALLOCATED MENTEES FILE
EOF

		fi
	done < "$DIR_CONF/$MENTOR"

}


    	
