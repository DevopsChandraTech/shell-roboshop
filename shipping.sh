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

echo "the script executed at $(date)"
dnf install maven -y &>>LOG_FILE
VALIDATE $? "Installing Maven"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding System User"

mkdir -p /app
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
cd /app 
unzip /tmp/shipping.zip
VALIDATE $? "Extract Code"

cd /app 
mvn clean package 
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Install Dependencies"

cp /$SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copy Code"

systemctl daemon-reload

systemctl enable shipping 
VALIDATE $? "Enable Shipping Service"

systemctl start shipping
VALIDATE $? "Start Shipping Service"

dnf install mysql -y 
VALIDATE $? "Installing MySql Client"

mysql -h mysql.devaws.shop -uroot -pRoboShop@1 < /app/db/schema.sql
VALIDATE $? "Create Schema MySql"

mysql -h mysql.devaws.shop -uroot -pRoboShop@1 < /app/db/app-user.sql 
VALIDATE $? "Crate App User"

mysql -h mysql.devaws.shop -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "Load Master Data"

systemctl restart shipping
VALIDATE $? "Restart Shipping Service"
