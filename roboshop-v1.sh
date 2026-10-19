#!/bin/bash 

ami_id="ami-0eec78ea4cbaaf5bd"
instance_type="t3.micro"
domain_name="saidevops.shop"
hosted_zone_id="Z0858131H2G4LTDQGMIX"

for instance in $@
do
echo "Creating instance: $instance "
done