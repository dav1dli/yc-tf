# Managed Service for Kubernetes
Этот документ объясняет создание облачных ресурсов, автоматизируемых с применением terraform.

## Предварительные требования
* Яндекс CLI `yc`
* Kubernetes CLI `kubectl`
* `terraform` CLI
* Доступ к Yandex Cloud

Создаваемые ресурсы:
* каталог
* виртуальная сеть
* подсети в зонах доступности
* сервисные эккаунты
* kubernetes managed service + workers node group

## Инструменты
### Yandex CLI
[Документация](https://cloud.yandex.ru/docs/cli/operations/install-cli)

Linux, Mac:
```
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```
Следуя инструкции получить OAuth token. Инициализировать yc cli: `yc init`. Ввести OAuth token. Выбрать существующий или создать новый каталог (devel id=b1grhaf66v577lrr6fes). Выбрать зону по умолчанию (ru-central1-a).

Проверить созданную конфигурацию: `yc config list`

### Kubernetes CLI
[Документация](https://kubernetes.io/docs/tasks/tools/#kubectl)

### Terraform CLI
[Документация](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

[Работа с terraform в Yandex Cloud](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart)

Создать ключ шифрования: 
```
yc kms symmetric-key create --name k8s_enc_key \
  --default-algorithm aes-256 --rotation-period 8760h
``` 
Зашифровать YC OAuth token: 
```
yc kms symmetric-crypto encrypt --name k8s_enc_key \
  --plaintext-file plaintext-file --ciphertext-file ciphertext-file
```
Документация рекомендует работать с сервисным эккаутом. Создать сервисный эккаут:
```
yc iam service-account create --name sa-terraform --description 'Terrafrom IaC service account'
```
Вывести id сервисных эккаунтов:
```
yc iam service-account list
```
Назначить [роли](https://cloud.yandex.ru/docs/iam/concepts/access-control/roles):
```
yc <service-name> <resource> add-access-binding <resource-name>|<resource-id> \
  --role <role-id> \
  --subject serviceAccount:<service-account-id>
```
Создать ключ:
```
yc iam key create \
  --service-account-id <идентификатор_сервисного_аккаунта> \
  --folder-name <имя_каталога_с_сервисным_аккаунтом> \
  --output key.json
```
Создать профиль CLI:
```
yc config profile create sa-terrafrom
```
Конфигурация параметров профиля:
```
yc config set service-account-key key.json
yc config set cloud-id <идентификатор_облака>
yc config set folder-id <идентификатор_каталога>  
```
Определить переменные окружения:
```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```
Сконфигурировать TF провайдер yandex в `terraform/config.tf`. Выполнить `terraform init`.

[Документация по TF провайдеру Yandex](https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs).

## Облачные Ресурсы
### Сети
Создать виртуальную сеть:
```
yc vpc network create \
  --name vnet-ITS-DEV \
  --description "Virtual private network"
```
Вывести виртуальные сети: `yc vpc network list`

### Под-сети
Создать подсеть виртуальной сети:
```
yc vpc subnet create \
  --name subnet-nodes \
  --description "Management Subnet" \
  --network-name vnet-ITS-DEV \
  --zone ru-central1-a \
  --range 192.168.1.0/24
```
Вывести подсети: `yc vpc subnet list --format yaml`

### Сервисные эккаунты
Роли:
* editor
* container-registry.images.puller
* alb.editor
* vpc.publicAdmin.
* certificate-manager.certificates.downloader.
* compute.viewer.

Сервисный эккаунт с ролью edit для создания ресурсов в каталоге:
```
yc iam service-account create --name sa-k8s-res-edit
RES_SA_ID=$(yc iam service-account get --name sa-k8s-res-edit --format json | jq .id -r)
yc resource-manager folder add-access-binding \
  --id $FOLDER_ID \
  --role editor \
  --subject serviceAccount:$RES_SA_ID
```
Сервисный эккаунт для скачивания образов контейнеров на узлах k8s кластера:
```
yc iam service-account create --name sa-k8s-img-pull
NODE_SA_ID=$(yc iam service-account get --name sa-k8s-img-pull --format json | jq .id -r)
yc resource-manager folder add-access-binding \
  --id $FOLDER_ID \
  --role container-registry.images.puller \
  --subject serviceAccount:$NODE_SA_ID
```
Сервисный эккаунт для ингресс контроллера:
```
yc iam service-account create --name sa-k8s-ic
IC_SA_ID=$(yc iam service-account get --name sa-k8s-ic --format json | jq .id -r)
yc resource-manager folder add-access-binding \
  --id $FOLDER_ID \
  --role alb.editor \
  --role vpc.publicAdmin \
  --role certificate-manager.certificates.downloader \
  --role compute.viewer \
  --subject serviceAccount:$IC_SA_ID
yc iam key create \
  --service-account-id $IC_SA_ID \
  --output sa-key.json
```

### Container Registry
Каталог образов контейнеров служит для хранения создаваемых образов контейнеров и других артефактов, из которого они разворачиваются на такие платформы как Кубернетес.

Создать каталог образов контейнеров:
```
yc container registry create --name cr
yc container registry configure-docker
```

Опубликовать локальный образ:
```
REGISTRY_ID=$(yc container registry get --name yc-auto-cr --format json | jq .id -r)
docker build . -t cr.yandex/$REGISTRY_ID/image_name:latest
docker push cr.yandex/$REGISTRY_ID/image_name:latest
```

Проверить: `yc container image list`

### Jumphost
Jumphost служит для доступа к облачным ресурсам, недоступным для внешнего доступа. Правильно сконфигурированный jumphost и правила доступа к нему повышают безопасность сетевой архитектуры.

Вывести доступные образы виртуальных машин: `yc compute image list --folder-id standard-images`

Создать ключи удаленного доступа: `ssh-keygen -t ed25519 -C "devops@mail.net" -f ~/.ssh/yctf_id_ed25519`

Создать VM в каталоге:
```
yc compute instance create \
  --name jumphost \
  --zone ru-central1-a \
  --network-interface subnet-name=subnet-nodes,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-22-04-lts \
  --ssh-key ~/.ssh/yctf_id_ed25519.pub
```
Админ пользователь, в который будет установлен SSH ключ: `ubuntu`.

Вывести публичный IP хоста: 
```
JHOST=$(yc compute instance  get --name jumphost --format json | \
  jq -r ".network_interfaces[].primary_v4_address.one_to_one_nat.address")
```
Подсоединиться к хосту: `ssh -i ~/.ssh/yctf_id_ed25519 ubuntu@$JHOST`

### Kubernetes Managed Service
Создать k8s кластер:
```
yc managed-kubernetes cluster create \
  --name k8s --network-name vnet-ITS-DEV \
  --zone ru-central1-a --subnet-name subnet-nodes \
  --public-ip \
  --service-account-name sa-k8s-res-edit \
  --node-service-account-name sa-k8s-img-pull
```

после завершения создания кластера создать рабочие узлы:
```
yc managed-kubernetes node-group create \
  --name k8s-workers \
  --cluster-name k8s \
  --platform standard-v3 \
  --public-ip \
  --cores 2 \
  --memory 4 \
  --core-fraction 50 \
  --disk-type network-ssd \
  --auto-scale min=1,max=3,initial=1 \
  --location subnet-name=subnet-nodes,zone=ru-central1-a \
  --node-labels role=user \
  --async
```
[Сконфигурировать](https://yandex.cloud/ru/docs/managed-kubernetes/operations/connect/#kubectl-connect) `kubectl`: `yc managed-kubernetes cluster get-credentials --name k8s --external`

В случае, когда кластер приватный: `yc managed-kubernetes cluster get-credentials k8s --internal`. В этом случае доступ к менеджменту кластера возможен только изнутри приватной виртуалъной сети, в которой сконфигурирован кластер.

Проверить работу `kubectl`: `kubectl get nodes`. Ожидаемый результат: список рабочих узлов кластера.

### Ingress: Yandex ALB
[Документация](https://cloud.yandex.ru/docs/managed-kubernetes/operations/applications/alb-ingress-controller)

## Terraform
Terraform описывает конфигурацию облачных ресурсов используя YAML файлы с [HCL синтаксисом](https://developer.hashicorp.com/terraform/language/syntax/configuration).
Конфигурации ресурсов находятся в директории `terraform/`. Параметры сред (таких как DEV или PRD например) находятся в директории `env/`. Параметры выбранной среды передаются с опцией `-var-file`.

Инициализация:
```
terraform -chdir=terraform init -var-file=../env/dev/env.tfvars
```
Создание плана:
```
terraform -chdir=terraform plan -var-file=../env/dev/env.tfvars -out=yc.tfplan
```
Применение плана:
```
terraform -chdir=terraform apply -input=false -auto-approve yc.tfplan
```
