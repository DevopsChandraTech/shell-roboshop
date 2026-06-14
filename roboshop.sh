#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0f5bdd34affdd5ed7"

for instance in $@
do
    INSTANCE_ID=123

    if [ $instance != "frontend" ]; then
        IP=345
    else
        IP=123
    fi

    echo "instance: $IP"
done