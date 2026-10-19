#!/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
R="\e[31m"
Y="\e[33m"
G="\e[32m"
N="\e[0m"

if [ user_id -ne 0 ]; then 
    echo "Please run this script with sudo access..."
    exit 1
fi

mkdir -p $log_folder

echo "Script started executing at $(date +"%F %T")" &>>log_file

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "${2} is ${R}FAILED${N}" | tee -a $log_file
    else
        echo -e "${2} is ${G}SUCCESSFUL${N}" | tee -a $log_file
    fi
}


cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Copying Repo"

dnf install mongodb-org -y &>> log_file
validate $? "Installing mongodb"

systemctl enable mongod &>>log_file
systemctl start mongod &>>log_file
validate $? "Starting and Enabling mongodb"