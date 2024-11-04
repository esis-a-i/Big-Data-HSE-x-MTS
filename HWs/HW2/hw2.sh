#!/bin/bash

echo "Configuring yarn-site.xml..."
cat <<EOL > /usr/local/hadoop/etc/hadoop/yarn-site.xml
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
EOL

echo "Configuring mapred-site.xml..."
cat <<EOL > /usr/local/hadoop/etc/hadoop/mapred-site.xml
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
EOL

echo "Copying Hadoop configuration to worker nodes..."
for node in team-1-dn-0 team-1-dn-1; do
    echo "Copying to ${node}..."
    scp -r /usr/local/hadoop hadoop@"${node}":/usr/local/
done

echo "Starting YARN..."
sudo -u hadoop /usr/local/hadoop/sbin/start-yarn.sh

echo "Checking running processes..."
jps | grep -E "NameNode|DataNode|ResourceManager|NodeManager"

echo "Starting History Server..."
mapred --daemon start historyserver

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/yarn

echo "Configuring Nginx for YARN..."
sudo bash -c 'cat <<EOL > /etc/nginx/sites-available/yarn
server {
    listen 8088 default_server;

    location / {
        proxy_pass http://team-1-nn:8088;
    }
}
EOL'

sudo ln -s /etc/nginx/sites-available/yarn /etc/nginx/sites-enabled/yarn

echo "Restarting Nginx..."
sudo systemctl restart nginx

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/dh

echo "Configuring Nginx for History Server..."
sudo bash -c 'cat <<EOL > /etc/nginx/sites-available/dh
server {
    listen 19888 default_server;

    location / {
        proxy_pass http://team-1-nn:19888;
    }
}
EOL'

sudo ln -s /etc/nginx/sites-available/dh /etc/nginx/sites-enabled/dh

echo "Restarting Nginx..."
sudo systemctl restart nginx

echo "Setup completed."
echo "Verify the following URLs in your browser:"
echo "YARN: http://176.109.91.26:8088"
echo "History Server: http://176.109.91.26:19888"