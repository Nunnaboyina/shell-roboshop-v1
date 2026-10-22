#!/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
domain_name="saidevops.shop"
script_dir=$(dirname "$(realpath "$0")") 

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

dnf module disable nodejs -y &>> $log_file
dnf module enable nodejs:24 -y &>> $log_file
dnf install nodejs -y &>> $log_file
validate $? "Installing nodejs"

id "roboshop" &>> $log_file
if [ $? -eq 0 ]; then 
    echo -e "$(timestamp) [INFO] System roboshop User already exists---${Y}SKIPPED${N}"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    validate $? "Creating System User"
fi


rm -rf /app
mkdir -p /app 
validate $? "Creating app directory"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> $log_file
validate $? "Downloading Catalogue"


cd /app
unzip /tmp/catalogue.zip
validate $? "unzipping the catalogue"


npm install &>> $log_file
validate $? "Installing dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/" "$script_dir/catalogue.service"
cp $script_dir/catalogue.service /etc/systemd/system/catalogue.service
validate $? "copying the catalogue service file"

systemctl daemon-reload &>> $log_file
systemctl enable catalogue &>> $log_file
systemctl start catalogue &>> $log_file
validate $? "Starting catalogue"

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
validate $? "copying mongodb repo file"

dnf install mongodb-mongosh -y &>> $log_file
validate $? "Installing mongodb mongosh"

#mongosh --host mongodb.$domain_name --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()'
#if [$? -eq 0]; then
#    mongosh --host <MONGODB-SERVER-IPADDRESS> </app/db/master-data.js
#    validate $? "Loading the data"
#else 
#    echo -e "Products already added --- {Y}SKIPPED{N}"
#fi


echo "$(timestamp) [INFO] Script ended in $SECONDS seconds"
echo "$(timestamp) [INFO] ========Script Execution Stopped==========" | tee -a $log_file