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
MYSQL_HOST="mysql.devaws.shop"

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo "Error:: command not found" &>> $LOG_FILE
        exit 1
    else
        echo -e "$2 $G Success.$N" | tee -a $LOG_FILE
    fi
}

dnf install maven -y &>> $LOG_FILE
VALIDATE $? "Install maven"

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
else
    echo -e "roboshop user already exist $Y Skipping...!$N"
fi

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Create Directory"
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>> $LOG_FILE
VALIDATE $? "Download Code"
cd /app &>> $LOG_FILE
VALIDATE $? "Change Directory"
rm -rf /app/*
VALIDATE $? "removing inside the code"
unzip /tmp/shipping.zip &>> $LOG_FILE
VALIDATE $? "Unzip Code"
cd /app &>> $LOG_FILE
VALIDATE $? "Change Directory"
mvn clean package &>> $LOG_FILE
VALIDATE $? "Install Package" 
mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
VALIDATE $? "Move jar file"
cp /$SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>> $LOG_FILE
VALIDATE $? "Coping repo"
systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Daemon-reload"
systemctl enable shipping &>> $LOG_FILE
VALIDATE $? "Enable Shipping"
systemctl start shipping &>> $LOG_FILE
VALIDATE $? "Start Shipping"
dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Install mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>> $LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql  &>> $LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOG_FILE
else
    echo -e "shipping products already loaded $Y Skipping..! $N"
fi
systemctl restart shipping &>> $LOG_FILE
VALIDATE $? "Restart Service"
