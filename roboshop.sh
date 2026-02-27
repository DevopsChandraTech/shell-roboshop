#!/bin/bash

for instance in $@;
do
    # Get instance Id from ec2 instance 
    # Give double quotes("") ResourceType
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro --security-group-ids sg-0f5bdd34affdd5ed7 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend" ]; then
        PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress')
    else
        PUBLICE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress')
    fi

    echo "$PUBLIC_IP:$instance"
    echo "$PRIVATE_IP:$instance"

done


