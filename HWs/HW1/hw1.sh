#!/bin/bash

HADOOP_VERSION="3.4.0"
HADOOP_URL="https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"
HADOOP_HOME="/usr/local/hadoop"
JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
NAMENODE="team-1-nn"
DATANODES=("team-1-dn-0" "team-1-dn-1")
JUMP_NODE="176.109.91.26"

sudo apt update
sudo apt install openjdk-11-jdk -y

sudo adduser --disabled-password --gecos "" hadoop

sudo -i -u hadoop bash << EOF
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
EOF

for node in ${DATANODES[@]} $NAMENODE; do
  ssh-copy-id hadoop@$node
done

sudo -u hadoop bash << EOF
wget $HADOOP_URL
tar -xvzf hadoop-$HADOOP_VERSION.tar.gz
sudo mv hadoop-$HADOOP_VERSION $HADOOP_HOME
EOF

echo "export HADOOP_HOME=$HADOOP_HOME" | sudo tee -a /home/hadoop/.profile
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /home/hadoop/.profile
echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" | sudo tee -a /home/hadoop/.profile
source /home/hadoop/.profile

sudo chown -R hadoop:hadoop $HADOOP_HOME
cd $HADOOP_HOME/etc/hadoop

sudo -u hadoop bash << EOF
echo 'export JAVA_HOME=$JAVA_HOME' >> hadoop-env.sh
EOF

sudo -u hadoop bash << EOF
cat << EOL > core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://$NAMENODE:9000</value>
    </property>
</configuration>
EOL

cat << EOL > hdfs-site.xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>${#DATANODES[@]}</value>
    </property>
</configuration>
EOL

echo "${DATANODES[@]}" | tr ' ' '\n' > workers
EOF

for node in ${DATANODES[@]}; do
  scp -r $HADOOP_HOME hadoop@$node:/usr/local/
done

sudo -u hadoop hdfs namenode -format

sudo -u hadoop $HADOOP_HOME/sbin/start-dfs.sh

sudo apt install nginx -y

cat << EOL | sudo tee /etc/nginx/sites-available/hdfs
server {
    listen 9870 default_server;

    location / {
        proxy_pass http://$NAMENODE:9870;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/hdfs /etc/nginx/sites-enabled/
sudo systemctl restart nginx

echo "Проверьте HDFS через веб-браузер по адресу: http://$JUMP_NODE:9870"