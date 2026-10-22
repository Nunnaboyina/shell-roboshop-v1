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

dnf module disable nginx -y &>> $log_file
dnf module enable nginx:1.26 -y &>> $log_file
dnf install nginx -y &>> $log_file
validate $? "Installing nginx"

systemctl enable nginx &>> $log_file
systemctl start nginx &>> $log_file
validate $? "Enabling and Starting nginx"

rm -rf /usr/share/nginx/html/* &>> $log_file
validate $? "Deleting Default content"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $log_file
validate $? "Downloading frontend"

cd /usr/share/nginx/html &>> $log_file
unzip /tmp/frontend.zip &>> $log_file
validate $? "Unzipping frontend"

sed -i "/s/DOMAIN_NAME/$domain_name/" "$script_dir/roboshop.conf"
cp "$script_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf &>> $log_file
validate $? "copying the roboshop file"

nginx -t &>> $log_file
validate $? "Rechecking nginx"

systemctl restart nginx &>> $log_file
validate $? "Restarting the nginx"

echo "$(timestamp) [INFO] Script ended in $SECONDS seconds"
echo "$(timestamp) [INFO] ========Script Execution Stopped==========" | tee -a $log_file