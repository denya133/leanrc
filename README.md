FoxxMC
================================

FoxxMC is Model-Controller microframework like Rails (but without View)
and easy way to create APIs and simple web applications from
within ArangoDB. It is inspired by Rails, the classy Ruby web
framework.

It is based on ArangoDB Foxx framework.


ВНИМАНИЕ:
Скачать сервер ArangoDB можно с официального сайта:
https://www.arangodb.com/download/ubuntu/

Для однотипности ведения процесса разработки надо одинаково настраивать ArangoDB
на локальных компьютерах.
* пароль рута: `0000`
* создаем нужную базу данных `<имя базы данных>`
* точка монтирования для сервиса: `/api`

Удаляем пустое приложение
`sudo rm -rf /var/lib/arangodb3-apps/_db/<имя базы данных>/api/APP`

Вместо него создаем символьную ссылку
`sudo ln -s ~/repositories/<имя приложения>/ /var/lib/arangodb3-apps/_db/<имя базы данных>/api/APP`

Для автоматического релоада кода находясь в папке репозитория:
`gulp watch`

Для того, чтобы собрать дистрибутив, чтобы деплоить на продакшен:
`gulp build`

# !!! Для file and socket.io стриминга в режиме development
надо запускать:
```
cd ~/repositories/stream-server;
gulp web_start

```

# !!! Для работы с ембером в режиме development | В браузере эмбер должен быть открыт на http://127.0.0.1:4200/
`sudo nano /etc/arangodb3/arangod.conf`
и добавляем в конце файла
```
[http]
trusted-origin = *
```
или
```
[http]
trusted-origin = http://127.0.0.1:4200
```

# !!! Для работы с ембером на production
`sudo nano /etc/arangodb3/arangod.conf`
и добавляем в конце файла
```
[http]
trusted-origin = http://<домен на котором запущен сайт>
```


# Для импорта дампа с продакшена в битбакет надо залить дамп

с именем `<YYYYMMDD>.<имя базы данных>.tar.gz`

Распаковать можно командой
`tar -xvf <YYYYMMDD>.<имя базы данных>.tar.gz`

Востанавливаем командой (перед восстановлением надо в сервисе выполнить `teardown` скрипт)
`arangorestore --server.username root --server.password 0000 --server.database <имя базы данных> --input-directory "dump"`

После восстановления надо запустить из сервиса скрипт `migrate`
