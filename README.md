# Automatic RouterOS backup

This docker container will create perodic backups of your Mikrotik devices.
It is configured to backup the configuration and a whole system backup at 00:10 and 12:10.
The script will connect to all the devices using ssh with the user backup and a provided ssh private key.


## Docker args
| description          | required? | command                                         |
|----------------------|-----------|-------------------------------------------------|
| private key          | yes       | -v $PRIVATE_KEY:/home/app/private.key           |
| backup configuration | yes       | -v $LOCAL_DIR/backup.conf:/home/app/backup.conf |
| backup folder        | no        | -v $LOCAL_BKP_DIR:/home/app/backup              |

## Usage
```docker run -d -v $(pwd)/private.key:/home/app/private.key -v $(pwd)/backup.conf:/home/app/backup.conf philipkazmeier/routeros-backup:latest```
