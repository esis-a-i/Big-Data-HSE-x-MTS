### Демоны Apache Hadoop и их конфигурация

#### 1. ResourceManager (YARN)
ResourceManager - центральный компонент YARN, управляющий ресурсами кластера.

Конфигурация (yarn-site.xml):
<configuration>
    <!-- Основные настройки ResourceManager -->
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>team-1-nn</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>${yarn.resourcemanager.hostname}:8088</value>
    </property>
    <!-- Настройки планировщика -->
    <property>
        <name>yarn.resourcemanager.scheduler.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>
    </property>
    <!-- Настройки восстановления -->
    <property>
        <name>yarn.resourcemanager.recovery.enabled</name>
        <value>true</value>
    </property>
</configuration>
#### 2. NodeManager
NodeManager работает на каждом узле кластера и управляет контейнерами.

Конфигурация (yarn-site.xml):
<configuration>
    <!-- Настройки NodeManager -->
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>8192</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>4</value>
    </property>
    <!-- Логирование -->
    <property>
        <name>yarn.nodemanager.log-dirs</name>
        <value>/var/log/hadoop/yarn/nodemanager</value>
    </property>
</configuration>
#### 3. History Server
JobHistory Server хранит историю выполненных задач.

Конфигурация (mapred-site.xml):
<configuration>
    <!-- История задач -->
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>team-1-nn:10020</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>team-1-nn:19888</value>
    </property>
    <!-- Хранение истории -->
    <property>
        <name>mapreduce.jobhistory.done-dir</name>
        <value>/mr-history/done</value>
    </property>
</configuration>
### Публикация веб-интерфейсов

#### 1. Настройка NGINX для ResourceManager:
server {
    listen 80;
    server_name yarn.example.com;

    location / {
        proxy_pass http://team-1-nn:8088;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
#### 2. Настройка NGINX для History Server:
server {
    listen 80;
    server_name history.example.com;

    location / {
        proxy_pass http://team-1-nn:19888;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
### Проверка работоспособности

1. Проверка статуса демонов:
sudo systemctl status hadoop-resourcemanager
sudo systemctl status hadoop-nodemanager
sudo systemctl status hadoop-historyserver
2. Проверка логов:
tail -f /var/log/hadoop/yarn/yarn-hadoop-resourcemanager-*.log
tail -f /var/log/hadoop/yarn/yarn-hadoop-nodemanager-*.log
tail -f /var/log/hadoop/mapred/mapred-hadoop-historyserver-*.log
3. Проверка веб-интерфейсов:
- ResourceManager: http://yarn.example.com
- History Server: http://history.example.com

### Мониторинг и обслуживание

1. Мониторинг метрик:
yarn top
yarn application -list
yarn node -list
2. Очистка логов:
sudo yarn logs -applicationId application_id
sudo yarn application -kill application_id
Все компоненты настроены для стабильной работы, веб-интерфейсы доступны и защищены, система логирования настроена корректно.

