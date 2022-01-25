# https://gist.github.com/Tiim/5f85dbb907c5a251dd784e72985f73ac

BACKUP=$(cd backups && ls -tp | grep -v /$ | head -1)

if [ -z "$BACKUP" ]
then
  echo "No backup found!"
  exit 1
else
  echo "Backup: $BACKUP"
fi

BACKUP_PATH="./backups/$BACKUP"


CONTAINER=$(docker ps --format "{{.Names}}" | grep postgres)
echo "Container: $CONTAINER"

echo "Copy backup to container"
(docker cp $BACKUP_PATH $CONTAINER:/tmp)


CMD=$(echo $(cat << EOM
      echo "Disabling all connections to database" &&
      psql -U postgres -d db -c "SELECT pid, pg_terminate_backend(pid), datname FROM pg_stat_activity WHERE datname = current_database() AND pid <> pg_backend_pid();" &&
      echo "Recreating database" &&
      dropdb -U postgres --if-exists db &&
      createdb -U postgres db &&
      echo "Restoring database from backup" &&
      gunzip -c /tmp/$BACKUP | psql -U postgres db &&
      rm /tmp/$BACKUP
EOM
))

docker exec -d $CONTAINER sh -c "$CMD"
