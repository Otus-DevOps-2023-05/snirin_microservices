```
INSTANCE_NAME="docker-host";
yc compute instance create \
 --name $INSTANCE_NAME \
 --zone ru-central1-a \
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
 --ssh-key ~/.ssh/appuser.pub
 
INSTANCE_NAME="docker-host"; IP=$(yc compute instance get $INSTANCE_NAME --format json \
| jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address'); \
echo $IP; \
docker-machine create \
 --driver generic \
 --generic-ip-address=$IP \
 --generic-ssh-user yc-user \
 --generic-ssh-key ~/.ssh/appuser \
 $INSTANCE_NAME;
 
eval $(docker-machine env $INSTANCE_NAME);

ssh yc-user@$IP;
 
docker-machine ip $INSTANCE_NAME;

docker-compose -f docker-compose-initial.yml up -d;

```