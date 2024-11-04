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

Теперь выполните предыдущие шаги на всех остальных узлах, чтобы скопировать публичный ключ:

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
    
6. Убедитесь в том, что файл `workers` содержит имена ваших DataNode:
    
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
```

Проверьте статус запущенных процессов:

```bash
jps
```

Следует убедиться, что процессы NameNode, DataNode, ResourceManager и NodeManager запущены.

#### Шаг 9: Установка и настройка Nginx

1. Установите Nginx на jump ноде:
    
    ```bash
    sudo apt install nginx -y
    ```
    
2. Настройте конфигурацию Nginx для HDFS. Создайте файл конфигурации для HDFS:
    
    ```bash
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/hdfs
    sudo vim /etc/nginx/sites-available/hdfs
    ```
    
    Добавьте следующее:
    
    ```nginx
    server {
        listen 9870 default_server;
    
        location / {
            proxy_pass http://team-1-nn:9870;
        }
    }
    ```
    
    Создайте символическую ссылку:
    
    ```bash
    sudo ln -s /etc/nginx/sites-available/hdfs /etc/nginx/sites-enabled/
    ```
    
3. Перезапустите Nginx:
    

```bash
sudo systemctl restart nginx
```

#### Шаг 10: Проверка установки

Проверьте HDFS через веб-браузер по следующим адресам:

- HDFS: `http://176.109.91.26:9870`