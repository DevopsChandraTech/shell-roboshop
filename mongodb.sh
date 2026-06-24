#!/bin/bash

echo "the script start executed in $(date)"
START_TIME=$(date +%s)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


USERID=$(id -u) # show user id

if [ $USERID -ne 0 ]; then
    echo "Error:: run command with root user privilizes" | tee -a $LOG_FILE
    exit 1
fi

LOG_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$(echo $0 | awk -F "." '{print $1}')
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo "Error:: command not found" &>> $LOG_FILE
        exit 1
    else
        echo -e "$2 $G Success.$N" | tee -a $LOG_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
VALIDATE $? "Adding mongo repo"

dnf install mongodb-org -y  &>> $LOG_FILE
VALIDATE $? "Installing mongodb"

systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "Enable mongodb"

systemctl start mongod &>> $LOG_FILE
VALIDATE $? "Start mongodb" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongo.repo
VALIDATE $? "Alowing remote connections"

systemctl restart mongod 
VALIDATE $? "Restart mongod"
