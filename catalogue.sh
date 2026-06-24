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
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.devaws.shop"
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

###nodejs-setup###
dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disable nodejs"
dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enable nodejs"
dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Install nodejs"

# systemuser creation
id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo -e "System user already exists $Y Skipping..!$N"
fi

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Create Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
VALIDATE $? "Download code"
cd /app 
VALIDATE $? "Change Directory"
rm -rf /app/*
VALIDATE $? "Remove Content in App Directory"
unzip /tmp/catalogue.zip &>> $LOG_FILE
VALIDATE $? "Unzip the Code"

cd /app 
VALIDATE $? "Change Directory"
npm install &>> $LOG_FILE
VALIDATE $? "Install Dependencies"

cp /$SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl Service"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "daemon-reload"
systemctl enable catalogue &>> $LOG_FILE
VALIDATE $? "Enable Service" 
systemctl start catalogue &>> $LOG_FILE
VALIDATE $? "Start Service"

cp /$SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo repo service"

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "Install mongodb client"

mongosh --host $MONGODB_HOST </app/db/master-data.js &>> $LOG_FILE
VALIDATE $? "Create Schema"

systemctl restart catalogue.service &>> $LOG_FILE
VALIDATE $ "restart catalogue"
