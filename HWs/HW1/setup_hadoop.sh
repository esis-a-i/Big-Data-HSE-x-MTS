#!/bin/bash

# Файл конфигурации Hadoop
HADOOP_CONF_DIR="/usr/local/hadoop/etc/hadoop"

# Настройка hadoop-env.sh
echo "Настройка hadoop-env.sh..."
sudo bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' > $HADOOP_CONF_DIR/hadoop-env.sh"

# Настройка core-site.xml
echo "Настройка core-site.xml..."
sudo bash -c "cat <<EOF > $HADOOP_CONF_DIR/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://team-1-nn:9000</value>
    </property>
</configuration>
EOF"

# Настройка hdfs-site.xml
echo "Настройка hdfs-site.xml..."
sudo bash -c "cat <<EOF > $HADOOP_CONF_DIR/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>3</value>
    </property>
</configuration>
EOF"

# Настройка yarn-site.xml
echo "Настройка yarn-site.xml..."
sudo bash -c "cat <<EOF > $HADOOP_CONF_DIR/yarn-site.xml
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
EOF"

# Настройка mapred-site.xml
echo "Настройка mapred-site.xml..."
sudo bash -c "cat <<EOF > $HADOOP_CONF_DIR/mapred-site.xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>\$HADOOP_HOME/share/hadoop/mapreduce/*:\$HADOOP_HOME/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
EOF"

# Настройка workers
echo "Настройка файла workers..."
sudo bash -c "cat <<EOF > $HADOOP_CONF_DIR/workers
team-1-dn-0
team-1-dn-1
EOF"

# Форматирование NameNode
echo "Форматирование NameNode..."
sudo -u hadoop hdfs namenode -format

# Запуск HDFS и YARN
echo "Запуск HDFS и YARN..."
sudo -u hadoop /usr/local/hadoop/sbin/start-dfs.sh
sudo -u hadoop /usr/local/hadoop/sbin/start-yarn.sh

echo "Hadoop успешно настроен и запущен."