# snirin_microservices
snirin microservices repository

ДЗ monitoring-1
Сделано:
1. Основное задание
   Докер хаб - https://hub.docker.com/u/snirinnn

2. Задания со *
   - percona/mongodb_exporter
   - Blackbox exporter
   - Makefile

mongodb_exporter
https://github.com/percona/mongodb_exporter
Настройки монго экспортера
https://github.com/percona/mongodb_exporter/issues/621#issuecomment-1434669129

blackbox_exporter
https://github.com/prometheus/blackbox_exporter
https://prometheus.io/docs/guides/multi-target-exporter/
https://hub.docker.com/r/prom/blackbox-exporter/tags
http://158.160.125.10:9090/graph?g0.range_input=5m&g0.stacked=0&g0.expr=probe_http_duration_seconds&g0.tab=0
http://158.160.125.10:9090/graph?g0.range_input=5m&g0.stacked=0&g0.expr=probe_http_status_code&g0.tab=0

Список команд
```
yc compute instance create \
 --name docker-host \
 --zone ru-central1-a \
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
 --ssh-key ~/.ssh/appuser.pub
 

INSTANCE_NAME="docker-host"; IP=$(yc compute instance get $INSTANCE_NAME --format json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address'); ssh yc-user@$IP

INSTANCE_NAME="docker-host"; IP=$(yc compute instance get $INSTANCE_NAME --format json \
| jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address'); \
echo $IP; \
docker-machine create \
 --driver generic \
 --generic-ip-address=$IP \
 --generic-ssh-user yc-user \
 --generic-ssh-key ~/.ssh/appuser \
 docker-host
 
eval $(docker-machine env docker-host)

docker-machine ip docker-host

for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done

docker-compose -f docker-compose.yml up -d

curl ui:9292/metrics
curl comment:9292/metrics
curl post:5000/metrics
curl http://ui:9292/healthcheck
curl mongodb_exporter:9216/metrics

docker exec -it my_name_prometheus_1 sh

docker-compose stop post
docker-compose start post

docker-compose down; docker-compose -f docker-compose.yml up -d

docker build -t snirinnn/prometheus ../monitoring/prometheus; docker-compose -f docker-compose.yml up -d

docker-machine ssh docker-host
yes > /dev/null
```

Проверка монго-экспортера из контейнера post-py
```
apk add curl;
curl mongodb_exporter:9216/metrics;
```

Подключение к монго из контейнера post-py
```
echo 'http://dl-cdn.alpinelinux.org/alpine/v3.6/main' >> /etc/apk/repositories;
echo 'http://dl-cdn.alpinelinux.org/alpine/v3.6/community' >> /etc/apk/repositories;
apk update;
apk add mongodb=3.4.4-r0;
mongo --version;
mongo post_db/users_post;

db.runCommand( { collStats : "posts" } )
db.runCommand({ serverStatus: 1}).metrics.commands
```

http://158.160.125.10:9090/graph


Лекция 20
oci - опенсоурс спецификация докера 
containerd - аналог докера по спецификации с настройкой файервола между контейнерами
nerdctl - тоже аналог докера
snyk, Xray, Trivy, Sonarqube - анализ уязвимостей в образе и приложении
docker --cap-add --cap-drop
falco https://falco.org/about/ - собирает данные о событиях, например следит за докер контейнером (продвинутый strace)
docker scout, docker trust, sbom
harbor - зеркало
syft - анализ sbom

ДЗ 19 gitlab-ci-1
Сделано:
1. Основное задание
2. Два задания со * 2.7 и 10.2 - автоматическое развертывание гитлаба и раннеров через скрипт и ансибл.
   Пример запуска `./gitlab_full.sh gitlab-ci-vm`


Для себя
http://158.160.63.226/homework/example/-/settings/ci_cd
http://158.160.63.226/admin/runners

gitlab-runner запускает другие докер контейнеры.
Пример пулреквеста с настройками https://github.com/Otus-DevOps-2022-11/coolf124-vlab101_microservices/pull/4/files

Список команд
```
yc compute instance create \
  --name gitlab-ci-vm1 \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=50 \
  --memory 4 \
  --ssh-key ~/.ssh/appuser.pub

ansible all -i 158.160.99.113, -m ping
ansible-playbook -i 158.160.99.113, docker_install.yml
ansible-playbook -i 158.160.99.113, gitlab_container.yml
ansible-playbook -i 158.160.99.113, gitlab_full.yml

IP=$(yc compute instance get gitlab-ci-vm --format json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address'); ssh yc-user@$IP

INSTANCE_NAME="gitlab-ci-vm"; IP=$(yc compute instance get $INSTANCE_NAME --format json \
| jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address'); ssh yc-user@$IP
```

Раннеры
```
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlabrunner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest

gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"

token=$(docker exec -it gitlab_web_1 gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"); echo $token

docker exec -it gitlab-runner gitlab-runner register \
 --url http://<your-ip>/ \
 --non-interactive \
 --locked=false \
 --name DockerRunner \
 --executor docker \
 --docker-image alpine:latest \
 --registration-token <your-token> \
 --tag-list "linux,xenial,ubuntu,docker" \
 --run-untagged
 
 docker exec -it gitlab-runner gitlab-runner unregister -u http://158.160.49.228 -n DockerRunner
 
 docker exec -it gitlab-runner gitlab-runner register --help
```
Начальный пароль для root в gitlab
`cat /etc/gitlab/initial_root_password`
`sudo cat /srv/gitlab/config/initial_root_password`

Postgres в gitlab
```
gitlab-psql -d gitlabhq_production
\dt
select * from users;
```

Redis в gitlab
```
cat /etc/gitlab/gitlab.rb - настройки

gitlab-redis-cli
SCAN 0 COUNT 1000
```

ДЗ 18 docker-4
Сделано:
1. Запустите несколько раз (2-4)
   `docker run --network host -d nginx`
   Каков результат? Что выдал docker ps? Как думаете почему?
   Ответ: запущен только один контейнер, второй не смог начать слушать по адресу 0.0.0.0:80
```
docker logs 78b72144cecd
[emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
```

2. Повторите запуски контейнеров с использованием драйверов none и host и посмотрите, как меняется список namespace-ов
```
sudo ip netns
9425bce62756
default
```

3. Узнайте как образуется базовое имя проекта. Можно ли его задать? Если можно то как?
   Ответ: берется из названия папки проекта, можно переопределить через ключ -p (`docker-compose -p my_name up -d`)
   или переменную окружения COMPOSE_PROJECT_NAME в файле .env

4. Для задания со * cоздан файл `docker-compose.override.yml`

Ошибки:
1. Для работы сервиса комментариев в исходном docker-compose.yml добавил алиас для монго - `comment_db`
```
networks:
  reddit:
    aliases:
      - comment_db
```


Для себя
Список команд
```
docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
docker run --network host -d nginx

sudo ln -s /var/run/docker/netns /var/run/netns
sudo ip netns 

docker network create reddit --driver bridge 
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest;
docker run -d --network=reddit --network-alias=post snirinnn/post:1.0;
docker run -d --network=reddit --network-alias=comment  snirinnn/comment:1.0;
docker run -d --network=reddit -p 9292:9292 snirinnn/ui:1.0;

docker network create back_net --subnet=10.0.2.0/24;
docker network create front_net --subnet=10.0.1.0/24;

docker kill $(docker ps -q);
docker run -d --network=front_net -p 9292:9292 --name ui  snirinnn/ui:1.0;
docker run -d --network=back_net --name comment  snirinnn/comment:1.0;
docker run -d --network=back_net --name post  snirinnn/post:1.0;
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest;
docker network connect front_net post;
docker network connect front_net comment; 

docker-machine ssh docker-host;
sudo apt-get update && sudo apt-get install bridge-utils;
docker network ls;
ifconfig | grep br;
brctl show br-131b597ea8fa;
sudo iptables -nL -t nat -v;
ps ax | grep docker-proxy;

export USERNAME=snirinnn;
docker kill $(docker ps -q); docker-compose up -d; docker-compose ps;

Запускать локально
docker kill $(docker ps -q); docker-compose -f docker-compose.override.yml up -d; docker-compose ps;
```

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
echo $?

source venv/bin/activate
ansible-inventory --list
ansible all -m ping -o

cd ../terraform/; terraform destroy -auto-approve; terraform apply -auto-approve; cd ../ansible/; ansible-playbook docker_install.yml
```

Старая страница курса
https://otus.ru/learning/41310/
