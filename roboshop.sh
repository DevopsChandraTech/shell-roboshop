#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0f5bdd34affdd5ed7"
HOSTZONE_ID=""Z0502082140Q7QA6WMLFW
DOMAIN_NAME="devaws.shop"

for instance in $@;
do
    # Get instance Id from ec2 instance 
    # Give double quotes("") ResourceType
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress')
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress')
    fi

    echo "$instance : $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTZONE_ID \
    --change-batch '
    {
        "Comment": "Updating Records to Route53"
        ,"Changes": [{
        "Action"              : "UPSERT" #if not create,if exist update
        ,"ResourceRecordSet"  : {
            "Name"              : "'$instance.$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'" $IP "'"
            }]
        }
        }]
    }
    '
done


