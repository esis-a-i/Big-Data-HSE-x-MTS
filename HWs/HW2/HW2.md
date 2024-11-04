#### Шаг 1: Настройка yarn на name ноде
1. Настройте `yarn-site.xml`:

```xml
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value>
    </property>
</configuration>
```

2. Настройте `mapred-site.xml`:

```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
```
    
#### Шаг 2: Перенос настроек на все узлы

Скопируйте директорию Hadoop на все узлы. Вы можете использовать `scp` для этого:

```bash
scp -r /usr/local/hadoop hadoop@team-1-dn-0:/usr/local/
scp -r /usr/local/hadoop hadoop@team-1-dn-1:/usr/local/
```

#### Шаг 3: Запуск YARN

На узле NameNode запустите YARN:

```bash
sudo -u hadoop /usr/local/hadoop/sbin/start-yarn.sh
```

Проверьте статус запущенных процессов:

```bash
jps
```

Следует убедиться, что процессы NameNode, DataNode, ResourceManager и NodeManager запущены.

#### Шаг 4: Запуск History Server

```bash
mapred --daemon start historyserver
```

#### Шаг 5: Настройка Nginx YARN и History Server

    
1. Настройте конфигурацию Nginx для YARN. Создайте файл конфигурации для YARN:
    
    ```bash
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/yarn
    sudo vim /etc/nginx/sites-available/yarn
    ```
    
    Добавьте следующее:
    
    ```nginx
    server {
        listen 8088 default_server;
    
        location / {
            proxy_pass http://team-1-nn:8088;
        }
    }
    ```
    
    Создайте символическую ссылку:
    
    ```bash
    sudo ln -s /etc/nginx/sites-available/yarn /etc/nginx/sites-enabled/
    ```
    
2. Перезапустите Nginx:
    

```bash
sudo systemctl restart nginx
```

3. Настройте конфигурацию Nginx для History Server. Создайте файл конфигурации для History Server:
    
    ```bash
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/dh
    sudo vim /etc/nginx/sites-available/dh
    ```
    
    Добавьте следующее:
    
    ```nginx
    server {
        listen 19888 default_server;
    
        location / {
            proxy_pass http://team-1-nn:19888;
        }
    }
    ```
    
    Создайте символическую ссылку:
    
    ```bash
    sudo ln -s /etc/nginx/sites-available/dh /etc/nginx/sites-enabled/
    ```
    
4. Перезапустите Nginx:
    

```bash
sudo systemctl restart nginx
```

#### Шаг 6: Проверка установки

Проверьте YARN и History Server через веб-браузер по следующим адресам:

- YARN: `http://176.109.91.26:8088`
- HISTORY SERVER: `http://176.109.91.26:19888`
