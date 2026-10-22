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

dnf module enable maven:3.9 -y &>> $log_file
dnf install maven java-25-openjdk-devel -y &>> $log_file
validate $? "Installing Java and maven"

alternatives --set java /usr/lib/jvm/java-25-openjdk/bin/java &>> $log_file
validate $? "setting Java 25 as default version"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh &>> $log_file
source /etc/profile.d/java.sh &>> $log_file
echo $JAVA_HOME &>> $log_file
validate $? "Setting JAVA_HOME for maven"

id "roboshop"
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
   validate $? "Creating roboshop system user" 
else
    echo -e "$(timestamp) [INFO] System roboshop user already exists...${Y}SKIPPING${N}"
fi


rm -rf /app 
validate $? "Removing old code"

mkdir -p /app
validate $? "creating application directory"

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip &>> $log_file
validate $? "Downloading shipping"

cd /app
unzip /tmp/shipping.zip
validate $? "unzipping shipping"

mvn clean package &>> $log_file
validate $? "Installing dependencies"

mv target/shipping.jar shipping.jar &>> $log_file
validate $? "Moving shipping jar files"

#dnf install mysql -y &>> $log_file
#validate $? "Installing mysql client"

#count=$(mysql -h "myslq.$domain_name" -u root -pRoboShop@1 -NB -e "SELECT COUNT(*) FROM cities.cities;" 2>> $log_file)
#if [ -z "$count" ] || [ "$count" -eq 0 ]; then
#    mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $log_file
#    validate $? "Loading shipping data"
#else
#    echo "$(timestamp) [INFO] Shipping data already exist...${Y}SKIPPINNG${N}"

#mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $log_file
#validate $? ""

#sed -i "s/DOMAIN_NAME/$domain_name/" "$script_dir/shipping.service"
#cp "$script_dir/shipping.service" /etc/systemd/system/shipping.service &>> $log_file
#validate $? "Copying the service file"

systemctl daemon-reload &>> $log_file
systemctl enable shipping &>> $log_file
systemctl start shipping &>> $log_file
validate $? "Restarting shipping"


echo "$(timestamp) [INFO] Script ended in $SECONDS seconds"
echo "$(timestamp) [INFO] ========Script Execution Stopped==========" | tee -a $log_file