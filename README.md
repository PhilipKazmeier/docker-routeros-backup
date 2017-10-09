# Automatic RouterOS backup

This docker container will create perodic backups of your Mikrotik devices.

It is configured to backup the configuration and a whole system backup at 00:10 and 12:10.

The script will connect to all the devices using ssh with the user backup and a provided ssh private key.


## Docker args (required)
-v $PRIVATE_KEY:/home/app/private.key

-v $LOCAL_DIR/backup.conf:/home/app/backup.conf

## Docker args (optional)
-v $LOCAL_BKP_DIR:/home/app/backup
