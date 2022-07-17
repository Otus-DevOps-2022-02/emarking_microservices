# Emarking_microservice:))

## Docker 1-2 HW

 Поработал с основными командами в Docker


``
*docker run
*docker create
*docker start
*docker attach
*docker exec
*docker images
*docker inspect
*docker ps
*docker kill
*docker system df
*docker rm
*docker rmi

`` 

###  Задание с Docker-Machine

1. Установка Docker-Machine:

Следуем иснструкции по установке:

```
https://github.com/docker/machine/releases/

```

После установки проверяем:

```
$ docker-machine -v
docker-machine version 0.16.2, build bd45ab13


```

2. Равертываем ВМ в YC:

Для этого немнрго модифицируем скрип разработанный на первых занятих  по  Packer и спользуем его для создания ВМ.

Срипт autodeploy.sh ***Не забываем модифицировать фаил metadata***

Запускаем скрипт ./autodelpoy.sh ждём создания инстанса.

***До выполнения скрипта yc  должен быть устновлен и инициализирован***


3. Подключаемся  Docker-Machine к удаленному инстансу

Для этого воспользуемся коммандой: (где параметр --generic-ip-address= меняете на ip созданного в  YC инстанса)


```
***$ docker-machine create --driver generic --generic-ip-address=51.250.65.30 --generic-ssh-user admin --generic-ssh-key ~/.ssh/admin docker-host***
Running pre-create checks...
Creating machine...
(docker-host) Importing SSH key...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with ubuntu(systemd)...
Installing Docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env docker-host

```
***НИКОГДА НЕ ЗАПУСКАЙТЕ docker-machine create от имени супер пользователя, возникнут пробелеммы  с активацией машины поробнее вот тут:***
***https://github.com/docker/machine/issues/3994***

Проверяем что Docker-Machine создался и активный:

```
***$docker-machine ls***
NAME          ACTIVE   DRIVER    STATE     URL                        SWARM   DOCKER      ERRORS
docker-host   -        generic   Running   tcp://51.250.12.197:2376           v20.10.16 

```

Как видми сейчас машина создана и запущенна, ошибок нет. Но Флаг  ACTIVE  дожн быть в значении * а не -

Убедимся что действительно машина не видит активных хостов:

```
$ docker-machine active
No active host found

```

Ведём команду для просмотра настроек окружения для управления созданным клиентом:

```
$docker-machine env docker-host
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://51.250.12.197:2376"
export DOCKER_CERT_PATH="/home/eugene/.docker/machine/machines/docker-host"
export DOCKER_MACHINE_NAME="docker-host"
# Run this command to configure your shell: 
# eval $(docker-machine env docker-host)

```
 
Вводим комманду для применеия переменныз окружения для управления созданным клиентом:

```
$eval $(docker-machine env docker-host)
$ ***успешно выполненная команда выполняется без аутпута***

```

Проверяем что клиент стал активным:

```
$ docker-machine active
docker-host
$ docker-machine ls
NAME          ACTIVE   DRIVER    STATE     URL                        SWARM   DOCKER      ERRORS
docker-host   *        generic   Running   tcp://51.250.12.197:2376           v20.10.16   

```

Как видно клиент стал активным, можно управлять.
***Все комманды docker  введённые в этом режиме будут выполненны на удалённом клиенте***

Для отключения от управления клиентом выполним комманду:

```
$eval $(docker-machine env --unset) 
$
***Убедимся что мы не управляем удалённым клиентом***
$docker-machine active
No active host found
$ docker-machine ls
NAME          ACTIVE   DRIVER    STATE     URL                        SWARM   DOCKER      ERRORS
docker-host   -        generic   Running   tcp://51.250.12.197:2376           v20.10.16   

```

4. Подготовка Dockerfile для запука его на удалённом клиенте.

Проделаем все шаги из методички по созданию Dockerfile.
После завершения работ по созданию. Выполним следющие комманды для запуска нашего контейнра на удаленном клиенте:

```
$eval $(docker-machine env docker-host)
$ docker build -t reddit:latest .
$ docker run --name reddit -d --network=host reddit:latest

``` 

После процедуры сборки образа можно проверить работспособность контейнера:

***Откройте в браузере ссылку http://<ваш_IP_адрес>:9292***

```
### Задание со :star:


1. Сначала созадим плейбуки для  Ansible 

-Для устновки Docker install_docker.yml
-Для запуска Docker  start_docker.yml

2. Создадим фаил для сбоки образа в Packer
  
-Испльзуем плейбук install_docker.yml в секции провижинионга в файле образа docker-host.json

-Запускаем Packer с опицями:

```
$ packer validate --var-file varibles.json docker-host.json 
The configuration is valid.

$ packer build --var-file varibles.json docker-host.json
***ждём окончания сборки образа***

```

-после созадния образа проверяем его наличие в нашейпапке на  YC:

```
$ yc compute image list
+----------------------+--------------------------+-------------+----------------------+--------+
|          ID          |           NAME           |   FAMILY    |     PRODUCT IDS      | STATUS |
+----------------------+--------------------------+-------------+----------------------+--------+
| fd8dafqhbrrqmkdraagg | docker-reddit-1652900310 | docker-base | f2eqeof0coae0e9odrns | READY  |
+----------------------+--------------------------+-------------+----------------------+--------+


```

***-id обараза мы будем использовать при сборке интанса в Terraform***


3. Создаём конфиграцию инстанса в терраформ и используем Ansible для разветрывания Docker  контейнера.

Орывки из фала  main.tf:

- Создание шаблона для автоматического создания инвентори файла для  Ansible

```
resource "local_file" "get_inst_data_stage" {

#Использем функцию templatefile

  content = templatefile("instapp.tpl", {

    instance_names_app_st = local.instance_na_app_st,
    ips_app_st            = local.instance_ips_app_st,
    envt                  = var.env_type

#Описываем переменные для создания templatefile
  })

#Фаил который мы хотим получить на выходе работы функции  templatefile

  filename = "inventory_${var.env_type}"

```

- Структура шаблоана *.tpl

```
[docker-${envt}]
%{for i in range(length(instance_names_app_st)) ~}
${instance_names_app_st[i]}  ansible_host=${ips_app_st[i]}
%{ endfor ~}

```

- Выходной фаил (создается полсе создания инстанса тераформом)

```
[docker-prod]
dockerhost-0  ansible_host=51.250.5.96
 
```
- Созадем правило удаления инвентори после уничтожения инстанса:

```
provisioner "local-exec" {

    when       = destroy
    command    = "mv inventory_${self.triggers.env_type} inventory_${self.triggers.env_type}.back"
    on_failure = continue

  }

```

- запускем  Ansible  после создания инстанса:

```
provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i inventory_${self.triggers.env_type} -e pub_key=${var.public_key_path} /home/eugene/lerning/prod/microservices/docker-monolith/infra/ansible/start_docker.yml"
  }

```

- Запускаем  Terraform:

```
$terraform plan
$terraform aplly 

```

- поле создания инстанса Terraform вернёт нам в консоль вызодную переменну с внешним ип адрессом инстанса
и так как в плейбуке который отвечает за запуск контейнера мы установили парметр port: 80:9292,  то проверить работоспособноть мы можем:***Откройте в браузере ссылку http://<ваш_IP_адрес_инстанса>:***


 
