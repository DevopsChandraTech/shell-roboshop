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
        echo -e "$2 ... $R Failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G Success $N" | tee -a $LOG_FILE
    fi
}

echo "the script executed time at $(date)"

dnf module disable nginx -y &>>LOG_FILE
VALIDATE $? "Disable Nginx Server"

dnf module enable nginx:1.24 -y &>>LOG_FILE
VALIDATE $? "Enable Nignx Server"

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "Install Nginx Server"

systemctl enable nginx &>>LOG_FILE
VALIDATE $? "Enable Nginx Server"

systemctl start nginx &>>LOG_FILE
VALIDATE $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>>LOG_FILE
VALIDATE $? "Remove Default Directory"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>LOG_FILE
VALIDATE $? "Download code from repo"

cd /usr/share/nginx/html &>>LOG_FILE
VALIDATE $? "Enter default Directory"

unzip /tmp/frontend.zip &>>LOG_FILE
VALIDATE $? "Unzip code"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>LOG_FILE
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx &>>LOG_FILE
VALIDATE $? "Restart Nginx Server"

