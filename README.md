# Automatic RouterOS backup

This docker container will create perodic backups of your Mikrotik devices.
It is configured to backup the configuration and a whole system backup at 00:10 and 12:10.
The script will connect to all the devices using ssh with the user backup and a provided ssh private key.


## Docker args
| description          | required? | args for docker run                             |
|----------------------|-----------|-------------------------------------------------|
| private key          | yes       | -v $PRIVATE_KEY:/home/app/private.key           |
| backup configuration | yes       | -v $LOCAL_DIR/backup.conf:/home/app/backup.conf |
| backup folder        | no        | -v $LOCAL_BKP_DIR:/home/app/backup              |


## RouterOS configuration
For the script to work you will need a user named `backup`. 
You should assign a seperate group for this user with permissions for: ssh, ftp, read, policy, test, password, sensitive.
Generate a new key on the device that will run this container (or use an existing one) and upload the public key to the RouterOS device that you want to backup. 
You can import the SSH key in the menu of System > Users > SSH Keys. Pay attentation that you import it for the user `backup`.

## Usage

With all configurations applied you could run the container like this:
```
docker run -d \
    -v $(pwd)/id_rsa:/home/app/private.key \
    -v $(pwd)/backup.conf:/home/app/backup.conf \
    -v $(pwd):/home/app/backup \
    philipkazmeier/routeros-backup:latest
```

