# Yandex Cloud Terraform Example
Проект создания облачной инфраструктуры разработки для платформы Kubernetes в Яндекс Облаке.
Для автоматизации применяется Terraform.

Структура:
* doc/ - документация
* terraform/ - скрипты автоматизации

Проект разворачивает управляемый (managed) сервис Кубернетес со следующими параметрами:

Дополнительно создаются следующие ресурсы:
* виртуальная сеть с под-сетями
* виртуальная машина Linux для управления ресурсами в сети (jumphost)

Дополнительная информация доступна в файлах в doc/ и в файлах README в под-директориях.