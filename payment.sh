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

dnf install python3 gcc python3-devel -y
VALIDATE $? "Installing Python"
id roboshop
if [ $? -ne 0 ]; then   
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo "roboshop already exists $Y Skipping..!$N"
fi

mkdir /app 
VALIDATE $? "Create Directory"
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "Download Code"
cd /app 
VALIDATE $? "Change directory"
unzip /tmp/payment.zip
VALIDATE $? "Unzip code"
cd /app 
VALIDATE $? "Change app directory"
pip3 install -r requirements.txt
VALIDATE $? "Installing Requirments"
systemctl daemon-reload
VALIDATE $? "daemon-reload"
systemctl enable payment 
VALIDATE $? "Enable service"
systemctl start payment
VALIDATE $? "Start Service"