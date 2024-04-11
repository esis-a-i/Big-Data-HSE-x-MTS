
# Инструкция по настройке Apache HIVE

## 1. Добавление пользователя для PostgreSQL на name node
Создайте пользователя `postgres`:
```bash
sudo adduser postgres
```

## 2. Установка PostgreSQL на name node
Установите PostgreSQL, если он еще не установлен:
```bash
sudo apt install postgresql
```

## 3. Переключение на пользователя `postgres`
Переключитесь на пользователя `postgres`:
```bash
sudo -i -u postgres
```

## 4. Настройка базы данных и пользователя Hive
Создайте базу данных и пользователя для Hive:
```bash
psql
CREATE DATABASE metastore;
CREATE USER hive WITH PASSWORD 'hadoop12';
GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;
ALTER DATABASE metastore OWNER TO hive;
```

## 5. Настройка конфигурации PostgreSQL
Откройте `postgresql.conf` для редактирования:
```bash
sudo vim /etc/postgresql/16/main/postgresql.conf
```
Измените строку:
```bash
listen_addresses = 'team-1-nn'
```

В `pg_hba.conf` настройте доступ:
```bash
sudo vim /etc/postgresql/16/main/pg_hba.conf
```
Добавьте:
```bash
host    metastore   hive    192.168.1.146/22    password
host    all         all     127.0.0.1/22      scram-sha-256
```

## 6. Перезапуск и проверка PostgreSQL
```bash
sudo systemctl restart postgresql
sudo systemctl status postgresql
```

## 7. Подключение к базе данных `metastore`
Подключитесь к базе данных:
```bash
psql -h team-1-nn -p 5432 -U hive -W -d metastore
```

## 8. Установка PostgreSQL клиента на jump-node
```bash
sudo apt install postgresql-client-16
psql -h team-1-nn -p 5432 -U hive -W -d metastore
```

## 9. Установка и настройка Hive
Переключитесь на пользователя `hadoop` и скачайте Hive:
```bash
sudo -i -u hadoop
wget https://dlcn.apache.org/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz
tar -xvzf apache-hive-4.0.1-bin.tar.gz
cd apache-hive-4.0.1-bin/
```

### Загрузка JDBC драйвера
```bash
wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
```

### Настройка файла `hive-site.xml`
Создайте `hive-site.xml` в папке `conf` и добавьте следующее:
```xml
<configuration>
    <property>
        <name>hive.server2.authentication</name>
        <value>NONE</value>
    </property>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>
    <property>
        <name>hive.server2.thrift.port</name>
        <value>5433</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://team-1-nn:5432/metastore</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.postgresql.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>hive</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>hiveMegaPass</value>
    </property>
</configuration>
```

### Настройка окружения Hive
В файл `~/.profile` добавьте:
```bash
export HIVE_HOME=/home/hadoop/apache-hive-4.0.1-bin
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
export PATH=$PATH:$HIVE_HOME/bin
```
Примените изменения:
```bash
source ~/.profile
hive --version
```

## 10. Подготовка HDFS
```bash
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod 777 /tmp
hdfs dfs -chmod 777 /user/hive/warehouse
```

## 11. Инициализация схемы Hive в PostgreSQL
```bash
bin/schematool -dbType postgres -initSchema
```

## 12. Подключение к Hive через Beeline
```bash
beeline -u jdbc:hive2://team-1-jn:5433
SHOW DATABASES;
CREATE DATABASE test;
```

## 13. Загрузка данных о вакансиях в Hive
Создайте таблицу с партиционированием по `area`:
```sql
CREATE TABLE IF NOT EXISTS test.vacancies (
    id INT,
    position_name STRING,
    employer_name STRING,
    area STRING,
    experience STRING,
    schedule STRING,
    employment STRING,
    professional_roles STRING,
    salary STRING,
    description STRING,
    key_skills ARRAY<STRING>
)
PARTITIONED BY (area STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',';
```

### Загрузка данных в таблицу
Данные доступны по ссылке: https://drive.google.com/file/d/13YU16b3A_25_0QmX1ZugJHjQ4iwSaipB/view?usp=drive_link
Загрузите файл `vacancies.csv` в HDFS и затем в Hive:
```bash
hdfs dfs -put vacancies.csv /input
LOAD DATA INPATH '/input/vacancies.csv' INTO TABLE test.vacancies;
```

### Тестирование запросов
```sql
SELECT COUNT(*) FROM test.vacancies;
SELECT * FROM test.vacancies LIMIT 10;
```
