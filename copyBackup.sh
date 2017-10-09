#!/bin/sh

#
# Mikrotik SSH Backup script v1.0
#


BACKUP_PATH=/home/app/backup
CONF=/home/app/backup.conf

EXPFILE=config.rsc
BKPFILE=system.backup
CMD="/export file=$EXPFILE; /system backup save name=$BKPFILE;"

SSH_USER=backup
SSH_KEY=/home/app/private.key

if [ ! -f "$CONF" ] 2>/dev/null ; then
    echo -e "\e[31m!!!ERROR\e[0m, Configuration file not found!"
    exit 1
fi

if  [ ! -d "$BACKUP_PATH" ] ; then
    mkdir -p $BACKUP_PATH
fi

LAST_CHAR=`tail -c 1 $CONF`
if [ "$LAST_CHAR" != "" ] ; then
    echo -e "" >> $CONF
fi


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
