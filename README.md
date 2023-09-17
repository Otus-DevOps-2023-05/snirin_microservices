# snirin_microservices
snirin microservices repository

ДЗ 17 docker-3
Сделано:
- Созданы и запущены образы трех микросервисов
- Образы оптимизированы через hadolint
- Образы ui и comment переделаны на alpine:3.5 и уменьшены до 60 мегабайт
- Исправлено несколько ошибок (ниже)

Ошибки:
1. При сборке образов на выполнении команды `apt-get update` возникала ошибка
   `Err http://deb.debian.org jessie-updates/main amd64 Packages 6.028   404  Not Found`
   Исправилась при замене базового образа с ruby:2.2 на ruby:2.5.5

2. В сервисе post была ошибка
```
docker logs 8976b096c803
Traceback (most recent call last):
  File "post_app.py", line 7, in <module>
    from flask import Flask, request, Response, abort, logging
  File "/usr/local/lib/python3.6/site-packages/flask/__init__.py", line 19, in <module>
    from jinja2 import Markup, escape
  File "/usr/local/lib/python3.6/site-packages/jinja2/__init__.py", line 8, in <module>
    from .environment import Environment as Environment
  File "/usr/local/lib/python3.6/site-packages/jinja2/environment.py", line 15, in <module>
    from markupsafe import Markup
ImportError: cannot import name 'Markup'
```
Исправилась вызовом `pip install --upgrade pip` c двойным вызовом `pip install -r /app/requirements.txt`
```
RUN apk --no-cache --update add build-base && \
    pip install --upgrade pip \
    pip install -r /app/requirements.txt && \
    pip install -r /app/requirements.txt && \
    apk del build-base
```

3. Для последней версии монго потребовалось поменять версию pymongo на 4.0.2
```
https://stackoverflow.com/questions/28981718/collection-object-is-not-callable-error-with-pymongo
```
И заменить вызов `insert` на `insert_one` в post_app.py

4. В Dockerfile сервиса ui
   добавил переменные окружения
```
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT
```
и удалил переменные
```
ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASECOMMENT_SERVICE_PORT comments
```

5. После обновления докер-файла для ui из https://raw.githubusercontent.com/express42/otus-snippets/master/hw-16/Сервис%20ui%20-%20улучшаем%20образ
   была ошибка
```
ERROR:  Error installing bundler:
	The last version of bundler (>= 0) to support your Ruby & RubyGems was 2.3.26. Try installing it with `gem install bundler -v 2.3.26`
	bundler requires Ruby version >= 2.6.0. The current ruby version is 2.5.0.
```
поправилось указанием старой версии bundler `1.17.3`:
```
RUN apt-get update \
    && apt-get install -y ruby-full ruby-dev build-essential \
    && gem install bundler -v 1.17.3 --no-ri --no-rdoc
```

Для себя
Список команд
```
docker network create reddit;
docker volume create reddit_db;

docker pull mongo:latest;
docker build -t snirinnn/post:1.0 ./post-py;
docker build -t snirinnn/comment:1.0 ./comment;
docker build -t snirinnn/ui:1.0 ./ui;

docker kill $(docker ps -q);

docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest;
docker run -d --network=reddit  --network-alias=post snirinnn/post:1.0;
docker run -d --network=reddit  --network-alias=comment snirinnn/comment:1.0;
docker run -d --network=reddit  -p 9292:9292 snirinnn/ui:1.0;
docker ps;

docker build --no-cache --progress=plain -t snirinnn/post:4.0 ./post-py; docker run --network=reddit  --network-alias=post -it snirinnn/post:4.0 bash;

apk add curl
apt install curl
curl 10bf69a8047d:5000/posts
curl post:5000/posts
```

ДЗ 16 docker-2
ERROR:  Error installing bundler:                                                                                                                                                                    
26.53   The last version of bundler (>= 0) to support your Ruby & RubyGems was 2.3.26. Try installing it with `gem install bundler -v 2.3.26`

Для себя
docker desktop
`docker run = docker create + docker start + docker attach`

Полезные команды
https://dockerlabs.collabnix.com/docker/cheatsheet/
https://raw.githubusercontent.com/sangam14/dockercheatsheets/master/dockercheatsheet8.png


Список команд
```
docker version
docker info
docker run hello-world
docker ps
docker ps -a
docker images
docker images -a
docker run -it ubuntu:18.04 /bin/bash
docker run -dt nginx:latest
exit
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
docker start ead70ea1fa33
docker attach ead70ea1fa33
docker exec -it ead70ea1fa33 bash
docker inspect 3fa7e364b9d8
docker ps -q

docker scan --severity high nginx

docker kill $(docker ps -q);
docker system df;
docker rm $(docker ps -a -q);
docker rmi $(docker images -q);

docker-machine create <имя>
eval $(docker-machine env <имя>
eval $(docker-machine env --unset)
docker-machine rm <имя>

yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/id_ed25519.pub

docker-machine create \
 --driver generic \
 --generic-ip-address=158.160.103.97 \
 --generic-ssh-user yc-user \
 --generic-ssh-key ~/.ssh/id_ed25519 \
 docker-host
 
docker-machine ls

eval $(docker-machine env docker-host)

docker run --rm -ti tehbilly/htop
docker run --rm --pid host -ti tehbilly/htop

docker build -t reddit:latest .
docker run --name reddit -d --network=host reddit:latest

docker login
docker tag reddit:latest snirinnn/otus-reddit:1.0
docker push snirinnn/otus-reddit:1.0
docker run --name reddit -d -p 9292:9292 snirinnn/otus-reddit:1.0

docker logs reddit -f
docker exec -it reddit bash
killall5 1

docker start reddit
docker stop reddit && docker rm reddit
docker run --name reddit --rm -it snirinnn/otus-reddit:1.0 bash

docker inspect snirinnn/otus-reddit:1.0
docker inspect snirinnn/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}'

docker exec -it reddit bash
mkdir /test1234
touch /test1234/testfile
rmdir /opt
exit
docker diff reddit
docker stop reddit && docker rm reddit
docker run --name reddit --rm -it /otus-reddit:1.0 bash
ls /

docker-machine rm docker-host
yc compute instance delete docker-host

sudo !!

source venv/bin/activate
ansible-inventory --list
ansible all -m ping -o

cd ../terraform/; terraform destroy -auto-approve; terraform apply -auto-approve; cd ../ansible/; ansible-playbook docker_install.yml
```
