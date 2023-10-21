#!/bin/bash

if [ -z "$1" ]
then
  printf "Instance name should be passed, example: \n./gitlab_full.sh gitlab-ci-vm1\n"
  exit
fi

INSTANCE_NAME=$1;

echo "Removing old instance"
yc compute instance delete $INSTANCE_NAME

echo "Creating new instance"
yc compute instance create \
  --name $INSTANCE_NAME \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=50 \
  --memory 8 \
  --ssh-key ~/.ssh/appuser.pub

IP=$(yc compute instance get $INSTANCE_NAME --format json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address');
echo $IP

cd ansible

while [ -z "$(ansible all -i $IP, -m ping | grep pong)" ]; do
    echo "Connecting to instance"
    sleep 5;
done;

echo "Launching ansible"
ansible-playbook -i $IP, gitlab_full.yml -e instance_ip=$IP -v
