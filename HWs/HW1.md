### Инструкция по установке и настройке Apache Hadoop

#### Шаг 1: Установка Java

Установите Java на всех узлах (NameNode и DataNodes):

```bash
sudo apt update
sudo apt install openjdk-11-jdk -y
```

Проверьте установку Java:

```bash
java -version
```

#### Шаг 2: Создание пользователя Hadoop

Создайте пользователя `hadoop`, который будет запускать HDFS и YARN:

```bash
sudo adduser hadoop
```

#### Шаг 3: Генерация ключей SSH

На каждом узле (NameNode и DataNodes) выполните следующие команды для генерации SSH-ключей:

1. Войдите под пользователем `hadoop`:
    
    ```bash
    sudo -i -u hadoop
    ```
    
2. Генерируйте SSH-ключи:
    
    ```bash
    ssh-keygen
    ```
    
    Просто нажмите `Enter`, чтобы принять значения по умолчанию. Ключи будут сохранены в `~/.ssh/id_ed25519` и `~/.ssh/id_ed25519.pub`.
    
3. Добавьте публичный ключ в файл `authorized_keys`:
    
    ```bash
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    ```

Теперь выполните следующие шаги на всех остальных узлах, чтобы скопировать публичный ключ:

5. Скопируйте SSH-ключи на другие узлы (замените `team-1-xn` на соответствующие имена узлов):
    
    ```bash
    ssh-copy-id hadoop@team-1-nn
    ssh-copy-id hadoop@team-1-dn-0
    ssh-copy-id hadoop@team-1-dn-1
    ```
    

Теперь вы сможете подключаться к другим узлам по SSH без запроса пароля.

#### Шаг 4: Загрузка и установка Hadoop

1. Загрузите Hadoop на одном из узлов (обычно на NameNode):
    
    ```bash
    wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
    tar -xvzf hadoop-3.4.0.tar.gz
    sudo mv hadoop-3.4.0 /usr/local/hadoop
    ```
    
2. Настройте переменные окружения. Добавьте следующие строки в файл `.profile` пользователя `hadoop`:
    
    ```bash
    sudo vim /home/hadoop/.profile
    ```
    
    Добавьте:
    
    ```bash
    export HADOOP_HOME=/usr/local/hadoop
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
    ```
    
    Примените изменения:
    
    ```bash
    source /home/hadoop/.profile
    ```
    

#### Шаг 5: Настройка Hadoop

1. Восстановите разрешения на папки Hadoop:
    
    ```bash
    sudo chown -R hadoop:hadoop /usr/local/hadoop
    ```
    
2. Перейдите в директорию конфигурации Hadoop:
    
    ```bash
    cd /usr/local/hadoop/etc/hadoop
    ```
    
3. Отредактируйте файл `hadoop-env.sh`:
    
    ```bash
    vim hadoop-env.sh
    ```
    
    Убедитесь, что JAVA_HOME указан правильно:
    
    ```bash
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    ```
    
4. Настройте `core-site.xml`:
    
    ```xml
    <configuration>
        <property>
            <name>fs.defaultFS</name>
            <value>hdfs://team-1-nn:9000</value>
        </property>
    </configuration>
    ```
    
5. Настройте `hdfs-site.xml`:
    
    ```xml
    <configuration>
        <property>
            <name>dfs.replication</name>
            <value>3</value>
        </property>
    </configuration>
    ```
    
6. Настройте `yarn-site.xml`:

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

7. Настройте `mapred-site.xml`:

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
    
8. Убедитесь в том, что файл `workers` содержит имена ваших DataNode:
    
    ```bash
    vim workers
    ```
    
    Добавьте:
    
    ```bash
    team-1-dn-0
    team-1-dn-1
    ```
    

#### Шаг 6: Установка Hadoop на всех узлах

Скопируйте директорию Hadoop на все узлы. Вы можете использовать `scp` для этого:

```bash
scp -r /usr/local/hadoop hadoop@team-1-dn-0:/usr/local/
scp -r /usr/local/hadoop hadoop@team-1-dn-1:/usr/local/
```

#### Шаг 7: Форматирование NameNode

На узле NameNode выполните форматирование:

```bash
sudo -u hadoop hdfs namenode -format
```

#### Шаг 8: Запуск HDFS и YARN

На узле NameNode запустите HDFS и YARN:

```bash
sudo -u hadoop /usr/local/hadoop/sbin/start-dfs.sh
sudo -u hadoop /usr/local/hadoop/sbin/start-yarn.sh
```

Проверьте статус запущенных процессов:

```bash
jps
```

Следует убедиться, что процессы NameNode, DataNode, ResourceManager и NodeManager запущены.

#### Шаг 9: Установка и настройка Nginx

1. Установите Nginx:
    
    ```bash
    sudo apt install nginx -y
    ```
    
2. Настройте конфигурацию Nginx для YARN. Создайте файл конфигурации для YARN:
    
    ```bash
    sudo vim /etc/nginx/sites-available/yarn
    ```
    
    Добавьте следующее:
    
    ```nginx
    server {
        listen 80;
        server_name your_yarn_server_domain_or_ip;
    
        location / {
            proxy_pass http://localhost:8088;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    ```
    
    Создайте символическую ссылку:
    
    ```bash
    sudo ln -s /etc/nginx/sites-available/yarn /etc/nginx/sites-enabled/
    ```
    
3. Для HDFS создайте еще одну конфигурацию:
    
    ```bash
    sudo vim /etc/nginx/sites-available/hdfs
    ```
    
    Содержимое файла:
    
    ```nginx
    server {
        listen 80;
        server_name your_hdfs_server_domain_or_ip;
    
        location / {
            proxy_pass http://localhost:9870;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    ```
    
    Создайте символическую ссылку:
    
    ```bash
    sudo ln -s /etc/nginx/sites-available/hdfs /etc/nginx/sites-enabled/
    ```
    
4. Перезапустите Nginx:
    

```bash
sudo systemctl restart nginx
```

#### Шаг 10: Проверка установки

Проверьте YARN и HDFS через веб-браузер по следующим адресам:

- YARN: `http://your_yarn_server_domain_or_ip`
- HDFS: `http://your_hdfs_server_domain_or_ip`