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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Install rabbitmq"

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Install rabbitmq"

systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Install rabbitmq"

rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "Added User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Set Permissions"