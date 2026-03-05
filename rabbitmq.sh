#/bin/bash
#colours for script
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#log folder creation 
LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOG_FOLDER

# checks user with root priviliges or not
USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
    echo "Error:: Run Command With Root User Privilizes."
    exit 1
fi


VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R Failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G Success $N" | tee -a $LOG_FILE
    fi
}

echo "the script execution started at $(date)"

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Install rabbitmq"

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Install rabbitmq"

systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Install rabbitmq"

rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "Add User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "Set Permissions"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo "the script executed time $TOTAL_TIME seconds."