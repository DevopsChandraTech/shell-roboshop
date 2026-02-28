#/bin/bash
USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
    echo "Error:: Run Command With Root User Privilizes."
    exit 1
fi

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
mkdir -p /var/log/shell-roboshop


VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R Failure $N"
        exit 1
    else
        echo -e "$2 ... $G Success $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? Adding Mongo Repo 

dnf install mongodb-org -y | tee -a $LOG_FILE 
VALIDATE $? Installing Mongo Repo

systemctl enable mongod | tee -a $LOG_FILE
VALIDATE $? Enable Mongo Repo

systemctl start mongod | tee -a $LOG_FILE
VALIDATE $? Start Mongo Repo








