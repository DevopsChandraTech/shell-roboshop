#/bin/bash
#colours for script
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#log folder creation 
LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
SCRIPT_DIR=$pwd
HOST_IP="mongodb.devaws.shop"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
mkdir -p /var/log/shell-roboshop

# checks user with root priviliges or not
USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
    echo "Error:: Run Command With Root User Privilizes."
    exit 1
fi

# validation for script exist or not
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R Failure $N"
        exit 1
    else
        echo -e "$2 ... $G Success $N"
    fi
}


dnf module disable nodejs -y | tee -a $LOG_FILE
VALIDATE $? "Disable Nodejs Module"

dnf module enable nodejs:20 -y | tee -a $LOG_FILE
VALIDATE $? "Enable Nodejs Module"

dnf install nodejs -y | &>>$LOG_FILE
VALIDATE $? "Install Nodejs"

#check here user exist or not
id roboshop
if [ id -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating User"
else 
    echo -e "User already exist... $Y SKIPPING $N"
fi

mkdir -p /app | &>>$LOG_FILE
VALIDATE $? "Create Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Code"

cd /app &>>$LOG_FILE
VALIDATE $? "Change Directory"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzip Code in tmp"

cd $SCRIPT_DIR/app  &>>$LOG_FILE
VALIDATE $? "Change Directory"

npm install  &>>$LOG_FILE
VALIDATE $? "Install Dependencies"

systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enable Catalogue"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "Start Catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Copy Code"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install mongodb Client"

mongosh --host $HOST_IP </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Load Products"

systemctl restart catalogue &>>$LOG_FILE
VALIDATE $? "Restart Service"

