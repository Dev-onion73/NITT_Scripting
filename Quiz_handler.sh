#!/bin/bash
MENTEES_ROOT="/home"
MENTORS_GROUP="Mentors"

# Ensure mentors group exists
if ! getent group "$MENTORS_GROUP" >/dev/null; then
    echo "Group '$MENTORS_GROUP' does not exist. Create it and add mentors."
    exit 1
fi

for mentee_home in "$MENTEES_ROOT"/*; do
    if [[ -d "$mentee_home" ]]; then
        mentee_user=$(basename "$mentee_home")
        quiz_dir="$mentee_home/quiz"
        mkdir -p "$quiz_dir"
        chown "$mentee_user":"$MENTORS_GROUP" "$quiz_dir"
        chmod 770 "$quiz_dir"
    fi
done
echo "Setup done. Mentors in group '$MENTORS_GROUP' can now write quizzes."
