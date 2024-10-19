#!/bin/bash

# Установка Java
echo "Установка Java..."
sudo apt update
sudo apt install openjdk-11-jdk -y

# Проверка установки Java
java -version

# Создание пользователя Hadoop
if id "hadoop" &>/dev/null; then
    echo "Пользователь hadoop уже существует."
else
    echo "Создание пользователя hadoop..."
    sudo adduser hadoop --disabled-password --gecos ""
fi

# Генерация ключей SSH
echo "Генерация SSH-ключей..."
sudo -i -u hadoop bash <<EOF
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
EOF

# Установка Hadoop
echo "Загрузка и установка Hadoop..."
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
tar -xvzf hadoop-3.4.0.tar.gz
sudo mv hadoop-3.4.0 /usr/local/hadoop

# Настройка переменных окружения
echo "Настройка переменных окружения Hadoop..."
sudo bash -c 'cat <<EOF >> /home/hadoop/.profile
export HADOOP_HOME=/usr/local/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
EOF'

# Применяем изменения
source /home/hadoop/.profile

# Восстановление прав на папки Hadoop
echo "Восстановление прав на папки Hadoop..."
sudo chown -R hadoop:hadoop /usr/local/hadoop

echo "Установка завершена. Пожалуйста, используйте скрипт для настройки Hadoop."