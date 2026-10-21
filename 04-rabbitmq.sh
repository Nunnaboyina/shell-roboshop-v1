#!/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo "Please run the script with sudo access...."
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



echo "$(timestamp) [INFO] ========Script Execution Started==========" | tee -a $log_file

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo 
validate $? "Adding RabbitMq repo"

dnf install erlang rabbitmq-server -y &>> $log_file
validate $? "Installing Rabbitmq server"

systemctl enable rabbitmq-server &>> $log_file
systemctl start rabbitmq-server &>> $log_file
validate $? "Starting and Enabling Rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $log_file
validate $? "Creating RabbitMq user for Roboshop"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $log_file
validate $? "Setting permission for Roboshop user"
#rabbitmqctl list_users | grep -qw "roboshop"
#if [ $? -ne 0 ]; then 
 #   rabbitmqctl add_user roboshop roboshop123 &>> $log_file
 #   rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $log_file
 #   validate $? "Creating RabbitMq user for Roboshop"
#else
 #   echo -e "RabbitMq user already exists-----${Y}SKIPPED${N}"
#fi


echo "$(timestamp) [INFO] Script ended in $SECONDS seconds"
echo "$(timestamp) [INFO] ========Script Execution Stopped==========" | tee -a $log_file
