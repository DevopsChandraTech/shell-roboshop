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

dnf module disable redis -y
VALIDATE $? "Disable Module"

dnf module enable redis:7 -y
VALIDATE $? "Enable Module"

dnf install redis -y 
VALIDATE $? "Install redis"

sed -i "/s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf
VALIDATE $? "Allow Remote Connection"

sed '/protected-mode/ c protected-mode no'
VALIDATE $? "Set Protected Mode No"



