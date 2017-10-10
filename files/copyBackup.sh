#!/bin/sh

#
# Mikrotik SSH Backup script v1.0
#

# Copyright 2017 Philip Kazmeier

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Backup configuration
BACKUP_PATH=/home/app/backup
CONF=/home/app/backup.conf
EXPFILE=config.rsc
BKPFILE=system.backup
CMD="/export file=$EXPFILE; /system backup save name=$BKPFILE;"

# SSH configuration
SSH_USER=backup
SSH_KEY=/home/app/private.key


# create backup path if it does not exist
if  [ ! -d "$BACKUP_PATH" ] ; then
    mkdir -p $BACKUP_PATH
fi

# make sure that configuration file is present and not empty
if [ ! -f "$CONF" ] 2>/dev/null ; then
    (>&2 echo "ERROR, Configuration file not found!")
    exit 1
fi


# function to create a backup of specific device
# parameters are the IP ($1) and the directory where the tar.gz will be saveds ($2)
function backup() {
    local IP=$1
    local DIR=$2

    ssh -i $SSH_KEY -o StrictHostKeyChecking=no $SSH_USER@$IP "$CMD" 

    if [[ $? != 0 ]]; then
        (>&2 echo "SSH failed for $IP")
    fi

    for FILE in $EXPFILE $BKPFILE
    do
        scp -i $SSH_KEY -o StrictHostKeyChecking=no $SSH_USER@$IP:$FILE .
        if [[ $? != 0 ]]; then
            (>&2 echo "SCP of $FILE for $IP failed!")
        fi
    done

    tar zvcf $DIR/$(date +%F_%H-%M-%S).tar.gz $EXPFILE $BKPFILE
    rm $EXPFILE $BKPFILE
}


while read -r line
do {
    line=`echo $line | grep :`

    if [ -n "$line" ] ; then
        if [ "${line:0:1}" != "#" ] ; then
            IP=`echo $line | cut -d: -f1 | tr -d " "`
            NAME=`echo $line | cut -d: -f2 | tr -d " "`
            if  [ ! -d "${BACKUP_PATH}/${NAME}" ] ; then
                mkdir -p ${BACKUP_PATH}/${NAME}
            fi
            backup "$IP" "${BACKUP_PATH}/${NAME}"

            # clean up old backups
            find ${BACKUP_PATH}/${NAME}/* -mtime +30 -exec rm {} \;
        fi
    fi
# fix error with ssh eating up the action list
} </dev/null    
done < $CONF
