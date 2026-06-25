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

dnf install maven -y
VALIDATE $? "Install maven"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo -e "roboshop user already exist $Y Skipping...!$N"
fi

mkdir /app 
VALIDATE $? "Create Directory"
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "Download Code"
cd /app 
VALIDATE $? "Change Directory"
unzip /tmp/shipping.zip
VALIDATE $? "Unzip Code"
cd /app 
VALIDATE $? "Change Directory"
mvn clean package 
VALIDATE $? "Install Package"
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Move jar file"
cp /$SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Coping repo"
systemctl daemon-reload
VALIDATE $? "Daemon-reload"
systemctl enable shipping 
VALIDATE $? "Enable Shipping"
systemctl start shipping
VALIDATE $? "Start Shipping"
dnf install mysql -y 
VALIDATE $? "Install mysql"

INDEX=$(mongosh mongodb.devaws.shop --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
else
    echo -e "shipping products already loaded $Y Skipping..! $N"
fi
systemctl restart shipping
VALIDATE $? "Restart Service"
