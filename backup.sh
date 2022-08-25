export PATH=/bin:/usr/bin:/usr/local/bin

TODAY=`date +"%Y-%m-%d_%H:%M:%S"`

if [[ -z "${MONGO_PASSWD}" ]]; then
  AUTH_ENABLED=0
else
  AUTH_ENABLED=1
fi

if [[ -z "${MONGO_USER}" ]]; then
   echo 'user database not defined'
fi

if [[ -z "${MONGO_PASSWD}" ]]; then
   echo 'password database not defined'
fi
 
######################################################################
######################################################################

echo "Started backup script" "$(date +'%Y/%m/%d %H:%M:%S')"
 
mkdir -p ${DB_BACKUP_PATH}/${TODAY}

AUTH_PARAM=""

if [ ${AUTH_ENABLED} -eq 1 ]; then
	AUTH_PARAM=" --username ${MONGO_USER} --password ${MONGO_PASSWD} --authenticationDatabase ${AUTHENTICATION_DATABASE}"
fi

if [ ${DATABASE_NAMES} = "ALL" ]; then
	echo "You have choose to backup all databases"
	mongodump --host ${MONGO_HOST} --port ${MONGO_PORT} ${AUTH_PARAM} --out ${DB_BACKUP_PATH}/${TODAY}/
else
	echo "Running backup for selected databases"
	for DB_NAME in ${DATABASE_NAMES}
	do
		mongodump --host ${MONGO_HOST} --port ${MONGO_PORT} --db ${DB_NAME} ${AUTH_PARAM} --out ${DB_BACKUP_PATH}/${TODAY}/
	done
fi

 
######## Remove backups older than {BACKUP_RETAIN_DAYS} days  ########

find ${DB_BACKUP_PATH} -maxdepth 1 -mtime +${BACKUP_RETAIN_DAYS} |while read fname; do
  if [ ${fname} != ${DB_BACKUP_PATH} ]; then
    echo "$fname"  
  fi
done

echo "End backup script" "$(date +'%Y/%m/%d %H:%M:%S')"
 
######################### End of script ##############################
