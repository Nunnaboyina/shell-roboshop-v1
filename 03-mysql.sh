#!/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo "Please run the Script with sudo access..."
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
        echo -e "$(timestamp) [INFO] ${2} is ${G}SUCCESSFUL${N}" | tee -1 $log_file
    fi
}

echo "$(timestamp) [INFO] =========Script Execution started============" | tee -a $log_file

dnf module enable mysql:8.4 -y &>> $log_file
dnf install mysql-server -y &>> $log_file
validate $? "Installing mysql" 

systemctl enable mysqld &>> $log_file
systemctl start mysqld &>> $log_file
validate $? "Start and enable mysql"

mysql_secure_installation --set-root-pass RoboShop@1 
validate $? "Setting MySQL root password"

echo "$(timestamp) [INFO] script ended in $SECONDS seconds"
echo "$(timestamp) [INFO] ====== Script Execution Ended=====" | tee -a $log_file
