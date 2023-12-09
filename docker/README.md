Запуск чистого приложения без логирования в облаке Яндекса
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

cd ../src-initial;
cd ui; docker build -t snirinnn/ui:1.0 .; docker push snirinnn/ui:1.0; cd ..; 
cd post-py; docker build -t snirinnn/post:1.0 .; docker push snirinnn/post:1.0; cd ..; 
cd comment; docker build -t snirinnn/comment:1.0 .; docker push snirinnn/comment:1.0; cd ..;
cd ../docker;

docker-compose -f docker-compose-initial.yml up -d; 
```
