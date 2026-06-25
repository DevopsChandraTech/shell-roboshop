#!/bin/bash

echo "the script start executed in $(date)"
START_TIME=$(date +%s)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

set -euo pipefail # fails if any error comes into the script

trap 'the error of script line number is $LINENO and the erro command is $BASH_COMMAND' ERR # PRINT ERROR LINE NUMBER AND ERROR COMMAND
USERID=$(id -u) # show user id

if [ $USERID -ne 0 ]; then
    echo "Error:: run command with root user privilizes" | tee -a $LOG_FILE
    exit 1
fi

LOG_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$(echo $0 | awk -F "." '{print $1}')
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.devaws.shop"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER

###nodejs-setup###
dnf module disable nodejs -y &>> $LOG_FILE
dnf module enable nodejs:20 -y &>> $LOG_FILE

dnf install nodejs -y &>> $LOG_FILE


# systemuser creation
id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo -e "System user already exists $Y Skipping..!$N"
fi

mkdir -p /app &>> $LOG_FILE
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
rm -rf /app/*
cd /app 
unzip /tmp/catalogue.zip &>> $LOG_FILE
VALIDATE $? "Unzip the Code"
cd /app 
npm install &>> $LOG_FILE
cp /$SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
systemctl daemon-reload &>> $LOG_FILE
systemctl enable catalogue &>> $LOG_FILE
systemctl start catalogue &>> $LOG_FILE
cp /$SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>> $LOG_FILE
INDEX=$(mongosh mongodb.devaws.shop --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 1 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>> $LOG_FILE
else
    echo -e "Catalogue products already exist $Y Skipping $N"
fi

systemctl restart catalogue.service &>> $LOG_FILE

