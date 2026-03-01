#/bin/bash
#colours for script
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#log folder creation 
LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD #this is special variable for current Directory
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


dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disable nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enable nodejs"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Install nodejs"

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
    VALIDATE $? "Creating User"
else 
    echo -e "User Already Exist....! $Y SKIPPING $N" &>> $LOG_FILE
fi

mkdir -p /app  &>> $LOG_FILE
VALIDATE $? "Create Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
VALIDATE $? "Download Code"

cd /app
VALIDATE $? "Enter app Directory"

rm -rf /app/*
VALIDATE $? "Remove code"

unzip /tmp/catalogue.zip &>> $LOG_FILE
VALIDATE $? "Unzip Code"

npm install &>> $LOG_FILE
VALIDATE $? "Install Dependencies"

cp  $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "Creating Service"

systemctl daemon-reload
systemctl enable catalogue  &>> $LOG_FILE
VALIDATE $? "Enable Service"

systemctl start catalogue &>> $LOG_FILE
VALIDATE $? "Start Service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongodb repo"

dnf install mongodb-mongosh -y  &>> $LOG_FILE
VALIDATE $? "Install mongosh"

mongosh --host $HOST_IP </app/db/master-data.js &>> $LOG_FILE
VALIDATE $? "Load Products"

