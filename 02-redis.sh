#!/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then 
    echo "Please run this script with sudo access..."
    exit 1
fi

mkdir -p $log_folder


timestamp(){
    date +"%F %T"
}

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2} is ${R}FAILED${N}" | tee -a $log_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2} is ${G}SUCCESSFUL${N}" | tee -a $log_file
    fi
}

echo "$(timestamp) [INFO] =====Script Execution Started===" | tee -a $log_file

dnf module disable redis -y &>> $log_file
dnf module enable redis:7 -y &>> $log_file
dnf install redis -y &>> $log_file
validate $? "Installing redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "Allowing remote connections to Redis"

systemctl enable redis &>> $log_file
systemctl start redis
validate $? "Enabling and Starting redis"