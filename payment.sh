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
MONGODB_HOST="mongodb.devaws.shop"
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
        echo -e "$2 ... $R Failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G Success $N" | tee -a $LOG_FILE
    fi
}

dnf install python3 gcc python3-devel -y
VALIDATE $? "Install Python"

id roboshop
if [ $id -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding System User"
else 
    echo "User already exist..! $Y SKIPPING $N"
fi


mkdir -p /app
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
cd /app 
rm -rf /app/*
unzip /tmp/payment.zip
VALIDATE $? "Download Code"

cd /app 
pip3 install -r requirements.txt
VALIDATE $? "Install requirments"

cp /$SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Copy Dependencies"

systemctl daemon-reload

systemctl enable payment 
VALIDATE $? "Enable Payment Serivce"

systemctl start payment
VALIDATE $? "Start Payment Serivce"


