

# WardenSh – Club Administration Shell Tool

WardenSh is a simple club management system written in shell allowing streamlined handling of Members (Mentees), Mentors, domains, task assignments, quizzes, and access control—all via easy-to-use command-line functions.

*⚠️ Project is still at testing phase and is prone to bugs 🪲*

## Installation, Update & Removal

**1. Install or Set Up**

    git clone https://github.com/Dev-onion73/WardenSh.git

    cd WardenSh

    sudo ./Setup.sh

	sudo club userGen <ADMIN> <PASWD>

This will create the admin user, essential groups, configuration directories (/etc/.Config_Club), environment variables, and set the system environment globally.

**2. Uninstall**
Run

    sudo ./Uninstall.sh

Removes all installed files, environment configurations, users, and directories.

**3. Update WardenSh**

    git pull origin main
    sudo ./Setup.sh

Pulls the latest changes and reapplies setup.



## Usage – Available Functions

### USER GEN

Once installed, these commands are available via the main script or your shell (if exported in club_env.sh):

    sudo club userGen <USER> <PASSWD>

Initializes the club system:

Creates default groups: Core, Mentors, Mentees, Webdev, Appdev, Sysad.

Sets up the Club Admin.

Creates directories for mentors/mentees, configuration files, and global environment exports.

Populates sample files (mentee_details.txt, mentor_details.txt, etc.) for entering user info.

### DOMAIN PREFERENCE

    domainpref <PREF1> [PREF2] [PREF3]

Let mentees set up to 3 unique domain preferences (WEBDEV, APPDEV, SYSAD). Preferences are recorded in:

User-specific file (~/dom_pref.txt)

Central configuration file (mentees_domain.txt)
Creates personal directories for each selected domain.

### MENTOR ALLOCATION

    sudo club mentorAlloc

Allocates mentees to mentors based on domain preferences and mentor capacities, updating:

Mentors' Allocated_Mentees files

Directory structure for task assignments
### SUBMIT TASK
    submitTask 

***For Mentees:***

 - Submit tasks by entering a task name, ID, and domain.
 -  Creates task files and updates the user's task_sub.txt

***For Mentors:***

Scans their allocated_mentees.txt.

Links all submitted tasks into the mentor’s own submitted_tasks directory and logs completed tasks.

### TASK ALLOC

    taskalloc [mentor_username]

*Only available to mentors:*

Assigns tasks (with ID and name) to all allocated mentees.

Creates task folders in mentees' home directories and ensures correct permissions.

### CHECK STAT

    checkstat [DOMAIN]

Allows the admin (or root):

Checks task submission statistics.

Shows recently completed tasks and summary by domain.

Uses .last_checkstat to track new submissions.

### DEREGISTER

    deregister

Allows a mentee to opt out of a selected domain:

Removes that domain's folder.

Updates both mentees_domain.txt and their personal dom_pref.txt.

### CRONJOB

    cronjob {enable|disable|status}

Enable or disable a scheduled cleanup job at 2 AM via cron. Useful for automating maintenance scripts like Cleaner.sh.

### SETQUIZ

    setQuiz

For mentors to create and distribute quizzes:

Collects questions interactively.

Saves them into quiz/questions.txt for each allocated mentee.

Sets permissions so mentees can read their quizzes.

### ANSWER QUIZ

    answerQuiz

Used by mentees to answer assigned quizzes:

Reads questions from their quiz/questions.txt.

Collects answers and saves them to quiz/answers.txt with secure permissions.

## FUNCTIONS TABLE - A Summary
| Function      | Role          | Purpose                      |
| ------------- | ------------- | ---------------------------- |
| `userGen`     | Admin (root)  | Initializes club environment |
| `domainpref`  | Mentee        | Set domain preferences       |
| `mentorAlloc` | Admin (root)  | Allocate mentees to mentors  |
| `submitTask`  | Mentee/Mentor | Submit and track tasks       |
| `taskalloc`   | Mentor        | Assign tasks                 |
| `checkstat`   | Admin/root    | View submission statistics   |
| `deregister`  | Mentee        | Leave a domain               |
| `cronjob`     | System        | Toggle automated cleanup     |
| `setQuiz`     | Mentor        | Distribute quizzes           |
| `answerQuiz`  | Mentee        | Submit quiz answers          |



## Final Notes

You must run certain commands with appropriate privileges (e.g., userGen, mentorAlloc, checkstat require root or Club Admin).

Ensure permissions and ownerships are properly managed, especially for quiz, tasks, and allocated_mentees.txt.

Environment variables are globally loaded via /etc/profile.d/club_env.sh.

> *This is my first structured project to utilise git effectively with tracking numbers and stuff :)*\n
> \- Dev-Onion

