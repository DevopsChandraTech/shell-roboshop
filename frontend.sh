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

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y

systemctl enable nginx 
systemctl start nginx 
rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
systemctl restart nginx 