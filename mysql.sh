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

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing MySql"
systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enable MySql"
systemctl start mysqld  &>> $LOG_FILE
VALIDATE $? "Start MySql Service"
mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE
VALIDATE $? "Setting root pasword"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))
echo "Script Executed in : $Y $TOTAL_TIME $N Secs."
