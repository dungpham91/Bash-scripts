#!/bin/bash
#
# Use: 
#   - Script use to backup data in server gitlab ce and move backup to amazon s3
#   - Tested in Ubuntu 18.04
# By:  Daniel Pham
# Website: https://devopslite.com
# Version: 1.0
# Date: 03-08-2020

# Function define variable
f_defineVariable () {
    # Temp backup folder
    folderBackup="/tmp/backupGitlab"

    # Get date, format YYYY_mm_dd
    currentDate=$(date +%Y_%m_%d)

    # Get server name
    serverName=$(hostname)

    # Get current folder
    currentFolder=$(pwd)

    # Folder gitlab config
    gitConfigFolder="/etc/gitlab"
}

# Function backup data
f_backupData () {
    # Create folder backup
    if [[ -d "$folderBackup" ]]; then
        rm -rf $folderBackup
    else
        mkdir -p $folderBackup
        mkdir -p $folderBackup/iptables
    fi

    # Call command gitlab backup to backup all data
    /usr/bin/gitlab-backup create

    # Find the `full name` of backup file
    backupFile=`find /var/opt/gitlab/backups | grep "$currentDate"`

    # Move/copy all needed data to backup file
    mv $backupFile $folderBackup/
    cp -rp $gitConfigFolder $folderBackup/

    # If you using IPtables in Ubuntu 18, uncomment 2 lines below
    #cp -rp /etc/iptables/default.rules $folderBackup/iptables/
    #cp -rp /etc/iptables/rules.v4 $folderBackup/iptables/
    
    # Create backup configuration file
    tar -cvzf $currentDate.$serverName.gitlab.tar.gz $folderBackup

    # Move backup file to s3 bucket
    aws s3 mv $currentFolder/$currentDate.$serverName.gitlab.tar.gz s3://your-s3-bucket-name/ --region your-s3-region
}

# Function clear backup files after move to s3 done
f_clearFile () {
    # Remove file backup
    if [[ -f "$currentDate.$serverName.gitlab.tar.gz" ]]; then
        rm -f $currentDate.$serverName.gitlab.tar.gz
    fi

    # Remove folder temp backup
    if [[ -d "$folderBackup" ]]; then
        rm -rf $folderBackup
    fi
}

# Function main
f_main () {
    f_defineVariable
    f_backupData
    f_clearFile
}
f_main

# Exit
exit
