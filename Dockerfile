FROM ubuntu
RUN apt-get -y update && apt-get -y install cron

RUN mkdir /backups
RUN mkdir /scripts
RUN mkdir /tools

#mongo link url
ARG MONGODB_DB_TOOLS_URL="https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-x86_64-100.6.0.deb"

ADD ${MONGODB_DB_TOOLS_URL} /mongodb-tools.deb
RUN dpkg -i /mongodb-tools.deb
RUN rm /mongodb-tools.deb

ADD ./backup.sh /scripts/

RUN chmod +x /scripts/backup.sh

ENV MONGO_HOST localhost
ENV MONGO_PORT 27017
ENV MONGO_PASSWD ''
ENV MONGO_USER ''
ENV AUTHENTICATION_DATABASE admin
ENV DB_BACKUP_PATH /backups

## Number of days to keep a local backup copy
ENV BACKUP_RETAIN_DAYS=30

# Set DATABASE_NAMES to "ALL" to backup all databases.
# or specify databases names separated with space to backup 
# specific databases only.
ENV DATABASE_NAMES="ALL"

RUN (crontab -l ; echo "* * * * * /scripts/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2") | crontab

CMD ["cron", "-f"]
