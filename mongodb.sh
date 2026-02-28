#/bin/bash
#colours for script

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#log folder creation 
LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
mkdir -p /var/log/shell-roboshop

# checks user with root priviliges or not
USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
    echo "Error:: Run Command With Root User Privilizes."
    exit 1
fi


VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R Failure $N"
        exit 1
    else
        echo -e "$2 ... $G Success $N"
    fi
}

#copy mongodb repo
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? Adding Mongo Repo 

#install mongodb
dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? Installing Mongo Repo

# enable mongodb
systemctl enable mongod | tee -a $LOG_FILE
VALIDATE $? Enable Mongo Repo

#start mongodb
systemctl start mongod | tee -a $LOG_FILE
VALIDATE $? Start Mongo Repo

# using sed update ip address for remote connection
sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? Adding Remote Connection

#restart mongodb service
systemctl restart mongod
VALIDATE $? Restart Mongodb Service







