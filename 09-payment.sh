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


dnf install python3.14 python3.14-pip -y &>> $log_file
validate $? "Installing python"

python3.14 --version &>> $log_file 
validate $? "Verifying python version"

id "roboshop"
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    validate $? "Creating roboshop system user"
else 
    echo -e "$(timestamp) [INFO] Roboshop user already exist----${Y}SKIPPING${N}"

rm -rf /app
validate $? "removing old app directory"

mkdir /app
validate $? "Creating app dir"

curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip &>> $log_file
validate $? "Downloading payment"

cd /app
unzip /tmp/payment.zip &>> $log_file
validate $? "Unzipping payment"

python3.14 -m venv /app/.venv &>> $log_file
/app/.venv/bin/pip install -r requirements.txt &>> $log_file
validate $? "Installing python dependencies"

sed -i "/s/DOMAIN_NAME/$domain_name/g" "$script_dir/payment.service" 
cp payment.service /etc/systemd/system/payment.service &>> $log_file
validate $? "Copying the payment service file"

systemctl daemon-reload &>> $log_file
systemctl enable payment &>> $log_file
systemctl start payment &>> $log_file
validate $? "Enable and Restart the payment"

echo "$(timestamp) [INFO] Script ended in $SECONDS seconds"
echo "$(timestamp) [INFO] ========Script Execution Stopped==========" | tee -a $log_file