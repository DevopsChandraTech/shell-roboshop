#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0f5bdd34affdd5ed7"

for instance in $@
do
    INSTANCE_ID=123

    if [ $instance != "frontend" ]; then
        IP=345
    else
        IP=$(aws ec2 describe-instances --instance-ids i-0bc3817e5c17034f1 --query 'Reservations[0].Instances[0]. \ PublicIpAddress' --output text)
    fi

    echo "instance: $IP"
done