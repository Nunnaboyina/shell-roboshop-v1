#!/bin/bash 

ami_id="ami-0eec78ea4cbaaf5bd"
instance_type="t3.micro"
domain_name="saidevops.shop"
hosted_zone_id="Z0858131H2G4LTDQGMIX"

for instance in $@
do
echo "Creating instance: $instance "

instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type $instance_type \
	--security-groups "roboshop-common" "roboshop-$instance"\
	--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]"\
    --query 'Instances[0].InstanceId' \
    --output text
)

echo "Instance ID: $instance_id" 
done





