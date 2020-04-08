#!/bin/bash


DATE=$(date +%H-%M-%S)
BACKUP=db-$DATE.sql
DB_HOST=$1
DB_PASSWORD=$2
DB_NAME=$3
BUCKET_NAME=$4

Help() 
{
        echo "usage: ./script.sh <db_host> <db_password> <db_name> <bucket_name>";
        echo "EXAMPLE:";
        echo "	./script.sh db_host 1234 dbname jenkins-mysqldv-xeon";
	exit 0;
}


case $1 in
  -[h?] | --help)
     Help
     exit;;
esac

mysqldump -u root -h $DB_HOST -p$DB_PASSWORD $DB_NAME 2>/dev/null || Help
mysqldump -u root -h $DB_HOST -p$DB_PASSWORD $DB_NAME > /tmp/db-$DATE.sql
echo "Uploading your db backup" &&\
aws s3 cp /tmp/db-$DATE.sql s3://$BUCKET_NAME/$BACKUP
