
# Инструкция по настройке PostgreSQL и подключению в среде Hadoop с двумя узлами (nn и jn)

## 1. Добавьте пользователя для PostgreSQL
Выполните команду для добавления пользователя `postgres`:
```bash
sudo adduser postgres
```

## 2. Установите PostgreSQL
Установите PostgreSQL, если он еще не установлен:
```bash
sudo apt install postgresql
```

## 3. Переключитесь на пользователя `postgres`
Переключитесь на пользователя `postgres` для выполнения последующих действий:
```bash
sudo -i -u postgres
```

## 4. Настройка конфигурации PostgreSQL
Отредактируйте файл конфигурации PostgreSQL:
```bash
sudo vim /etc/postgresql/16/main/postgresql.conf
```

Также откройте файл `pg_hba.conf` для настройки доступа:
```bash
sudo vim /etc/postgresql/16/main/pg_hba.conf
```

## 5. Перезапустите PostgreSQL
После изменения конфигурации перезапустите сервер PostgreSQL:
```bash
sudo systemctl restart postgresql
```

## 6. Проверьте статус службы PostgreSQL
Убедитесь, что PostgreSQL запущен:
```bash
sudo systemctl status postgresql
```

## 7. Подключение к базе данных `metastore`
Для подключения к базе данных `metastore` с сервера `tmpl-nn` выполните команду:
```bash
psql -h tmpl-nn -p 5432 -U hive -W -d metastore
```
Введите пароль пользователя `hive` при запросе.

## 8. Тестирование соединения
Проверьте доступность узла с помощью команды `ping`:
```bash
ping tmpl-nn
```

Повторите шаги 4 и 5, если потребуется внести изменения в конфигурацию PostgreSQL.
