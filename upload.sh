SERVER=""
SERVER_ADDR=""
ADDR=$SERVER@$SERVER_ADDR

echo "Address: $ADDR"

LOCAL_BACKUP_PATH="./backups/"
EXTERNAL_BACKUP_PATH="test-backups/"

rsync -e 'ssh -p 23' -a $LOCAL_BACKUP_PATH $ADDR:$EXTERNAL_BACKUP_PATH