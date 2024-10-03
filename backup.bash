#!/bin/bash
# Shell script to backup MySQL databases

MyUSER="<DB_USER>"     # USERNAME
MyPASS="<DB_PASSWORD>" # PASSWORD
MyHOST="<DB_HOST>"     # Hostname

# Linux bin paths, change this if necessary
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
CHOWN="$(which chown)"
CHMOD="$(which chmod)"
GZIP="$(which gzip)"

# Backup destination directory
DEST="<BACKUP_DIRECTORY>"

# Get hostname
HOST="$(hostname)"

# Get date in dd-mm-yyyy-HH-MM-SS format
NOW="$(date +"%d-%m-%Y-%H-%M-%S")"

# Main directory where backup will be stored
MBD="$DEST/$NOW"

# Databases to skip during backup
IGGY="anokha_2024 anokha_transactions_2024"

[ ! -d "$MBD" ] && mkdir -p "$MBD" || :

# Get the list of all databases
DBS="$($MYSQL -u $MyUSER -h $MyHOST -p$MyPASS -Bse 'show databases')"

for db in $DBS
do
    skipdb=-1
    if [ "$IGGY" != "" ]; then
        for i in $IGGY
        do
            if [ "$db" = "$i" ]; then
                skipdb=1
                break
            fi
        done
    fi

    if [ "$skipdb" -eq "-1" ]; then
        FILE="$MBD/$db.$HOST.$NOW.gz"
        $MYSQLDUMP -u $MyUSER -h $MyHOST -p$MyPASS $db | $GZIP -9 > "$FILE"
        if [ $? -ne 0 ]; then
            echo "Error backing up $db"
        else
            echo "Successfully backed up $db"
        fi
    fi
done
