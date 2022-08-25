FROM ubuntu
RUN apt-get -y update && apt-get -y install cron

RUN mkdir /backups
RUN mkdir /scripts

#mongo link url
ARG MONGODB_DB_TOOLS_URL="https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-x86_64-100.6.0.deb"

ADD ${MONGODB_DB_TOOLS_URL} /mongodb-tools.deb
RUN dpkg -i /mongodb-tools.deb
RUN rm /mongodb-tools.deb
ADD ./backup.sh /scripts/

ARG CRON
ARG MONGO_HOST="localhost"
ARG MONGO_PORT=27017
ARG MONGO_PASSWD=""
ARG MONGO_USER=""
ARG AUTHENTICATION_DATABASE=admin
ARG DB_BACKUP_PATH="/backups"

## Number of days to keep a local backup copy
ENV BACKUP_RETAIN_DAYS=30

# Set DATABASE_NAMES to "ALL" to backup all databases.
# or specify databases names separated with space to backup 
# specific databases only.
ENV DATABASE_NAMES="ALL"

ARG env_file="/scripts/env.sh"
ARG job_file="/scripts/job.sh"

#generate file to export environment vars
RUN touch ${env_file}
RUN echo "#!/bin/bash -l" >> ${env_file}
RUN echo "export MONGO_HOST=${MONGO_HOST}" >> ${env_file}
RUN echo "export MONGO_PORT=${MONGO_PORT}" >> ${env_file}
RUN echo "export MONGO_PASSWD=${MONGO_PASSWD}" >> ${env_file}
RUN echo "export MONGO_USER=${MONGO_USER}" >> ${env_file}
RUN echo "export AUTHENTICATION_DATABASE=${AUTHENTICATION_DATABASE}" >> ${env_file}
RUN echo "export DB_BACKUP_PATH=${DB_BACKUP_PATH}" >> ${env_file}
RUN echo "export DATABASE_NAMES=${DATABASE_NAMES}" >> ${env_file}
RUN echo "export BACKUP_RETAIN_DAYS=${BACKUP_RETAIN_DAYS}" >> ${env_file}

#union files
RUN cat ${env_file} /scripts/backup.sh > ${job_file}
RUN chmod +x ${job_file}

RUN (crontab -l ; echo "${CRON} ${job_file} > /proc/1/fd/1 2>/proc/1/fd/2") | crontab

CMD ["cron", "-f"]
