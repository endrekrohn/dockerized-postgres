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



exec () {
    (docker exec -d $CONTAINER  \
    $1)
}

echo "Remove all active sessions"
(docker exec -d $CONTAINER psql -U postgres -d db -c "SELECT pid, pg_terminate_backend(pid), datname FROM pg_stat_activity WHERE datname = current_database() AND pid <> pg_backend_pid();")

echo "Drop database and create new"
exec "dropdb -U postgres --if-exists db"
exec "createdb -U postgres db"

echo "Loading database backup"
(docker exec -d $CONTAINER sh -c "gunzip -c /tmp/$BACKUP | psql -U postgres db")
exec "rm /tmp/$BACKUP"

