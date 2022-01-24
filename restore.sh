echo "Starting backup prompt"
echo "What is the backup you want to use? [ex: filename.gz]"
read filename
(cd backups && gunzip < $filename | docker-compose exec -i db psql -U postgres) # -d your-db-name