# TranzAxis окружение для разработки

Этот проект создан для упрощения разворачивания локального TX, работующего в контейнерах docker.

## Getting Started

### Prerequisites

Для сборки образов в наличии должны быть следующие инструменты и дистрибутивы:
* [Docker](https://docs.docker.com/get-docker/)
* [Packer](https://www.packer.io/downloads)
* Unzip. Есть у [git for windows](https://git-scm.com/download/win)
* Bash. Есть у [git for windows](https://git-scm.com/download/win)
* Zip-файлы дистрибутива TranzAxis
* Zip-файл дистрибутива Oracle Database `linuxx64_12201_database.zip`

### Подготовка
1. Положить в папку `db/docker-images-master/OracleDatabase/SingleInstance/dockerfiles/12.2.0.1` файл `linuxx64_12201_database.zip`
2. Положить в папку `distribs` zip-файлы дистрибутива TranzAxis
3. Отредактировать файл `.env`. Желательно отредактировать `VERSION_TAG` прописав версию TX для которой 
   собираются образы. Этим тэгом будут помечаться собранные образы. Так же поменять `PKR_VAR_dist_uri` на URI загружаемого 
   дистрибутива
4. Отредактировать файл `config/manager/build.manager.conf`
5. В настройках docker RAM установить не менее 6Гб и для диска желательно не менее 80Гб
   
### Создание образов
* Запустить скрипт `build_oracle_db_base_image.bat` и ждем завершения его работы
* Запустить скрипт `build.bat`
* Ждём около 2 часов
* В папке `for_users` получаем всё необходимое
## Authors

* **Сергей Иванов** - *Initial work* - sv.ivanov@compassplus.comf