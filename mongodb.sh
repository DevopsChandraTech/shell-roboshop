#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0f5bdd34affdd5ed7"
HOSTZONE_ID="Z0502082140Q7QA6WMLFW"
DOMAIN_NAME="devaws.shop" 

for instance in $@;
do
    # create instance id
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend" ]; then
        # get private ip address
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME" # mysql.devaws.shop
    else
        # get public ip address
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME" # devaws.shop
    fi

    echo "$instance : $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'" # mongodb.devaws.shop
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }
    '
done

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
SCRIPT_NAME=$(echo $0 | cut -d "." -f2)
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








