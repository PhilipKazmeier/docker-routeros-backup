FROM alpine:latest

WORKDIR /home/app

RUN apk update && apk add openssh && rm -rf /var/cache/apk/* 

COPY copyBackup.sh /home/app/

# Add crontab file in the cron directory
ADD crontab /var/spool/cron/crontabs/root
 
# Give execution rights on the cron job
RUN chmod 0600 /var/spool/cron/crontabs/root
 
# Run the command on container startup
CMD crond -l 2 -f