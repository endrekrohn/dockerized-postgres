CONTAINER=$(docker ps --format "{{.Names}}" | grep postgres)
echo "Container: $CONTAINER"

(docker exec $CONTAINER pg_dumpall -c -U postgres | gzip > ./backups/backup_$(date +"%Y-%m-%d_%H_%M_%S").gz)
